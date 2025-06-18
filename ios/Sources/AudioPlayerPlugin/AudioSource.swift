import AVFoundation
import Capacitor
import MediaPlayer

public class AudioSource: NSObject, AVAudioPlayerDelegate {
    let STANDARD_SEEK_IN_SECONDS: Int = 5

    var id: String
    var source: String
    var audioMetadata: AudioMetadata
    var useForNotification: Bool
    var isBackgroundMusic: Bool

    var onPlaybackStatusChangeCallbackId: String = ""
    var onReadyCallbackId: String = ""
    var onEndCallbackId: String = ""

    private var pluginOwner: AudioPlayerPlugin
    @objc private var playerItem: AVPlayerItem!
    private var player: AVPlayer!
    @objc private var playerQueue: AVQueuePlayer!
    private var playerLooper: AVPlayerLooper!
    private var nowPlayingArtwork: MPMediaItemArtwork?

    private var loopAudio: Bool
    private var isPaused: Bool = false
    private var showSeekBackward: Bool
    private var showSeekForward: Bool

    private var audioReadyObservation: NSKeyValueObservation?
    private var audioOnEndObservation: Any?

    public init(
        pluginOwner: AudioPlayerPlugin,
        id: String,
        source: String,
        audioMetadata: AudioMetadata,
        useForNotification: Bool,
        isBackgroundMusic: Bool,
        loopAudio: Bool,
        showSeekBackward: Bool,
        showSeekForward: Bool
    ) {
        self.pluginOwner = pluginOwner
        self.id = id
        self.source = source
        self.audioMetadata = audioMetadata
        self.useForNotification = useForNotification
        self.isBackgroundMusic = isBackgroundMusic
        self.loopAudio = loopAudio
        self.showSeekBackward = showSeekBackward
        self.showSeekForward = showSeekForward

        super.init()

        self.audioMetadata.setPluginOwner(pluginOwner: pluginOwner).setUpdateCallback(
            callback: self.updateMetadata
        )
    }

    func initialize() throws {
        isPaused = false
        playerItem = try createPlayerItem()

        if loopAudio {
            playerQueue = AVQueuePlayer()
            playerLooper = AVPlayerLooper.init(
                player: playerQueue,
                templateItem: playerItem
            )
            observeAudioReady()
        } else {
            observeAudioReady()
            player = AVPlayer.init(playerItem: playerItem)

            setupInterruptionNotifications()
        }
    }

    func changeAudioSource(newSource: String) throws {
        audioReadyObservation?.invalidate()
        audioReadyObservation = nil

        removeOnEndObservation()

        source = newSource
        playerItem = try createPlayerItem()

        if loopAudio {
            playerQueue.removeAllItems()
            playerLooper = AVPlayerLooper.init(
                player: playerQueue,
                templateItem: playerItem
            )
            observeAudioReady()
        } else {
            observeAudioReady()
            player.replaceCurrentItem(with: playerItem)
        }
    }

    func changeMetadata(metadata: AudioMetadata) {
        audioMetadata.update(metadata: metadata)
        nowPlayingArtwork = nil

        updateMetadata()
    }

    func getDuration() -> TimeInterval {
        if loopAudio {
            return -1
        }

        if player.currentItem?.duration == CMTime.indefinite {
            return -1
        }

        return player.currentItem?.duration.seconds ?? -1
    }

    func getCurrentTime() -> TimeInterval {
        if loopAudio {
            return -1
        }

        return player.currentTime().seconds
    }

    func play() {
        if loopAudio {
            playerQueue.play()
        } else {
            player.play()
        }

        if !isPaused {
            setupNowPlaying()
            setupRemoteTransportControls()
        } else {
            setNowPlayingCurrentTime()
        }

        isPaused = false
        setNowPlayingPlaybackState(state: .playing)

        if useForNotification {
            audioMetadata.startUpdater()
        }
    }

    func pause() {
        if loopAudio {
            playerQueue.pause()
        } else {
            player.pause()
        }

        isPaused = true
        setNowPlayingPlaybackState(state: .paused)
        audioMetadata.stopUpdater()

    }

    func seek(timeInSeconds: Int64, fromUi: Bool = false) {
        if loopAudio {
            return
        }

        player.seek(to: getCmTime(seconds: timeInSeconds))

        if fromUi {
            removeRemoteTransportControls()
            removeNowPlaying()

            setupNowPlaying()
            setupRemoteTransportControls()
        } else {
            setNowPlayingCurrentTime()
        }
    }

    func stop() {
        if loopAudio {
            playerQueue.pause()
            playerQueue.seek(to: getCmTime(seconds: 0))
        } else {
            player.pause()
            player.seek(to: getCmTime(seconds: 0))
        }

        isPaused = false
        setNowPlayingPlaybackState(state: .stopped)
        removeRemoteTransportControls()
        removeNowPlaying()
        audioMetadata.stopUpdater()
    }

    func setVolume(volume: Float) {
        if loopAudio {
            playerQueue.volume = volume
        } else {
            player.volume = volume
        }
    }

    func setRate(rate: Float) {
        if loopAudio {
            return
        }

        player.rate = rate
    }

    func setOnReady(callbackId: String) {
        onReadyCallbackId = callbackId
    }

    func setOnEnd(callbackId: String) {
        onEndCallbackId = callbackId
    }

    func setOnPlaybackStatusChange(callbackId: String) {
        onPlaybackStatusChangeCallbackId = callbackId
    }

    func isPlaying() -> Bool {
        if loopAudio {
            return playerQueue.rate > 0
                || playerQueue.timeControlStatus
                == AVPlayer.TimeControlStatus.playing
                || playerQueue.timeControlStatus
                == AVPlayer.TimeControlStatus.waitingToPlayAtSpecifiedRate
        }

        return player.rate > 0
            || player.timeControlStatus == AVPlayer.TimeControlStatus.playing
            || player.timeControlStatus
            == AVPlayer.TimeControlStatus.waitingToPlayAtSpecifiedRate
    }

    func destroy() {
        audioMetadata.stopUpdater()
        removeOnEndObservation()
        isPaused = false
        removeRemoteTransportControls()
        removeNowPlaying()
        removeInterruptionNotifications()
    }

    private func createPlayerItem() throws -> AVPlayerItem {
        let url = URL.init(string: source)

        if url == nil {
            throw AudioPlayerError.invalidPath
        }

        let player = AVPlayerItem.init(url: url.unsafelyUnwrapped)

        return player
    }

    private func setupInterruptionNotifications() {
        let notificationCenter = NotificationCenter.default

        notificationCenter.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    private func removeInterruptionNotifications() {
        let notificationCenter = NotificationCenter.default

        notificationCenter.removeObserver(
            self,
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey]
                as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue)
        else {
            return
        }

        if type == .began {
            print("Audio interruption has begun")
            pause()

            makePluginCall(
                callbackId: onPlaybackStatusChangeCallbackId,
                data: [
                    "status": "paused"
                ]
            )
        }

        if type == .ended {
            print("Audio interruption has ended")
            play()

            makePluginCall(
                callbackId: onPlaybackStatusChangeCallbackId,
                data: [
                    "status": "playing"
                ]
            )
        }
    }

    private func observeAudioReady() {
        if onReadyCallbackId == "" {
            return
        }

        if loopAudio {
            audioReadyObservation = observe(
                \.playerQueue?.currentItem?.status
            ) { _, _ in
                if self.playerQueue.currentItem?.status
                    == AVPlayerItem.Status.readyToPlay {
                    self.makePluginCall(callbackId: self.onReadyCallbackId)
                    self.observeOnEnd()
                }
            }
        } else {
            audioReadyObservation = observe(
                \.playerItem?.status
            ) { _, _ in
                if self.playerItem.status == AVPlayerItem.Status.readyToPlay {
                    self.makePluginCall(callbackId: self.onReadyCallbackId)
                    self.observeOnEnd()
                }
            }
        }
    }

    private func observeOnEnd() {
        if loopAudio {
            return
        }

        if player.currentItem?.duration == CMTime.indefinite {
            return
        }

        var times = [NSValue]()
        times.append(
            NSValue(time: player.currentItem?.duration ?? getCmTime(seconds: 0))
        )

        audioOnEndObservation = player.addBoundaryTimeObserver(
            forTimes: times,
            queue: .main
        ) {
            [weak self] in
            self?.stop()
            self?.audioMetadata.stopUpdater()

            self?.makePluginCall(callbackId: self?.onEndCallbackId ?? "")
        }
    }

    private func removeOnEndObservation() {
        if audioOnEndObservation == nil {
            return
        }

        player.removeTimeObserver(audioOnEndObservation as Any)
        audioOnEndObservation = nil
    }

    private func setupRemoteTransportControls() {
        if !useForNotification {
            return
        }

        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget {
            [unowned self] _ -> MPRemoteCommandHandlerStatus in
            if !self.isPlaying() {
                self.play()

                self.makePluginCall(
                    callbackId: self.onPlaybackStatusChangeCallbackId,
                    data: [
                        "status": "playing"
                    ]
                )

                return .success
            }

            return .commandFailed
        }

        commandCenter.pauseCommand.addTarget {
            [unowned self] _ -> MPRemoteCommandHandlerStatus in
            print("Pause rate: " + String(self.player.rate))

            if self.isPlaying() {
                self.pause()

                self.makePluginCall(
                    callbackId: self.onPlaybackStatusChangeCallbackId,
                    data: [
                        "status": "paused"
                    ]
                )

                return .success
            }

            return .commandFailed
        }

        if showSeekBackward {
            commandCenter.skipBackwardCommand.addTarget {
                [unowned self] _ -> MPRemoteCommandHandlerStatus in
                var seekTime = floor(
                    self.getCurrentTime()
                        - Double(self.STANDARD_SEEK_IN_SECONDS)
                )

                if seekTime < 0 {
                    seekTime = 0
                }

                self.seek(timeInSeconds: Int64(seekTime))

                return .success
            }

            commandCenter.skipBackwardCommand.preferredIntervals = [
                NSNumber.init(value: self.STANDARD_SEEK_IN_SECONDS)
            ]
        }

        if showSeekForward {
            commandCenter.skipForwardCommand.addTarget {
                [unowned self] _ -> MPRemoteCommandHandlerStatus in
                var seekTime = ceil(
                    self.getCurrentTime()
                        + Double(self.STANDARD_SEEK_IN_SECONDS)
                )
                var duration = floor(self.getDuration())

                duration = duration < 0 ? 0 : duration

                if seekTime > duration {
                    seekTime = duration
                }

                self.seek(timeInSeconds: Int64(seekTime))

                return .success
            }

            commandCenter.skipForwardCommand.preferredIntervals = [
                NSNumber.init(value: self.STANDARD_SEEK_IN_SECONDS)
            ]
        }

        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.skipBackwardCommand.isEnabled = showSeekBackward
        commandCenter.skipForwardCommand.isEnabled = showSeekForward
        commandCenter.seekBackwardCommand.isEnabled = false
        commandCenter.seekForwardCommand.isEnabled = false
    }

    private func removeRemoteTransportControls() {
        if !useForNotification {
            return
        }

        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.removeTarget(nil)
        commandCenter.pauseCommand.removeTarget(nil)
        commandCenter.skipBackwardCommand.removeTarget(nil)
        commandCenter.skipForwardCommand.removeTarget(nil)
    }

    private func updateMetadata() {
        nowPlayingArtwork = nil

        setupNowPlaying()
    }

    private func setupNowPlaying() {
        if !useForNotification {
            return
        }

        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = [String: Any]()

        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = audioMetadata.albumTitle
        nowPlayingInfo[MPMediaItemPropertyArtist] = audioMetadata.artistName
        nowPlayingInfo[MPMediaItemPropertyTitle] = audioMetadata.songTitle
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = getDuration()
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] =
            getCurrentTime()
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate

        let artwork = getNowPlayingArtwork()

        if artwork != nil {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }

        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }

    private func setNowPlayingInfoKey(for key: String, value: Any?) {
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo

        if nowPlayingInfo == nil {
            return
        }

        nowPlayingInfo![key] = value

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    private func getNowPlayingArtwork() -> MPMediaItemArtwork? {
        if nowPlayingArtwork != nil {
            return nowPlayingArtwork
        }

        if !audioMetadata.artworkSource.isEmpty {
            downloadNowPlayingIcon()
        } else {
            if let image = UIImage(named: "NowPlayingIcon") {
                nowPlayingArtwork = MPMediaItemArtwork(boundsSize: image.size) {
                    _ in
                    return image
                }
            }
        }

        return nowPlayingArtwork
    }

    private func downloadNowPlayingIcon() {
        guard
            var artworkSourceUrl = URL.init(string: audioMetadata.artworkSource)
        else {
            print(
                "Error: artworkSource '" + audioMetadata.artworkSource
                    + "' is invalid (1)"
            )
            return
        }

        if artworkSourceUrl.scheme != "https" {
            guard
                let baseAppPath = pluginOwner.bridge?.config.appLocation
                    .absoluteString,
                let baseAppPathUrl = URL.init(string: baseAppPath)
            else {
                print("Error: Cannot find base path of application")
                return
            }

            artworkSourceUrl = baseAppPathUrl.appendingPathComponent(
                artworkSourceUrl.absoluteString
            )
        }

        URLSession.shared.dataTask(
            with: artworkSourceUrl
        ) { data, _, _ in
            guard let imageData = data, let image = UIImage(data: imageData)
            else {
                print(
                    "Error: artworkSource data is invalid - "
                        + artworkSourceUrl.absoluteString
                )
                return
            }

            DispatchQueue.main.async {
                self.nowPlayingArtwork = MPMediaItemArtwork(
                    boundsSize: image.size
                ) { _ in image }
                self.setNowPlayingInfoKey(
                    for: MPMediaItemPropertyArtwork,
                    value: self.nowPlayingArtwork
                )
            }
        }.resume()
    }

    private func setNowPlayingCurrentTime() {
        if !useForNotification {
            return
        }

        setNowPlayingInfoKey(
            for: MPNowPlayingInfoPropertyElapsedPlaybackTime,
            value: getCurrentTime()
        )
    }

    private func removeNowPlaying() {
        if !useForNotification {
            return
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    private func setNowPlayingPlaybackState(state: MPNowPlayingPlaybackState) {
        if !useForNotification {
            return
        }

        MPNowPlayingInfoCenter.default().playbackState = state
    }

    private func getCmTime(seconds: Int64) -> CMTime {
        return CMTimeMake(value: seconds, timescale: 1)
    }

    private func makePluginCall(callbackId: String) {
        makePluginCall(callbackId: callbackId, data: [:])
    }

    private func makePluginCall(callbackId: String, data: PluginCallResultData) {
        if callbackId == "" {
            return
        }

        let call = pluginOwner.bridge?.savedCall(withID: callbackId)

        if data.isEmpty {
            call?.resolve()
        } else {
            call?.resolve(data)
        }
    }
}
