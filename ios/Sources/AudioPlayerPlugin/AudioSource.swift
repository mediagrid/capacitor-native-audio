import AVFoundation
import Capacitor
import MediaPlayer

public class AudioSource: NSObject, AVAudioPlayerDelegate {
    let STANDARD_SEEK_IN_SECONDS: Int = 5

    var assetId: String
    var source: String
    var friendlyTitle: String
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
    private var loopAudio: Bool
    private var isPaused: Bool = false

    private var audioReadyObservation: NSKeyValueObservation?
    private var audioOnEndObservation: Any?

    public init(
        pluginOwner: AudioPlayerPlugin,
        id: String,
        source: String,
        friendlyTitle: String,
        useForNotification: Bool,
        isBackgroundMusic: Bool,
        loopAudio: Bool
    ) {
        self.pluginOwner = pluginOwner
        self.assetId = id
        self.source = source
        self.friendlyTitle = friendlyTitle
        self.useForNotification = useForNotification
        self.isBackgroundMusic = isBackgroundMusic
        self.loopAudio = loopAudio
    }

    func initialize() throws {
        isPaused = false
        playerItem = try createPlayerItem()

        if (loopAudio) {
            playerQueue = AVQueuePlayer()
            playerLooper = AVPlayerLooper.init(player: playerQueue, templateItem: playerItem)
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

        if (loopAudio) {
            playerQueue.removeAllItems()
            playerLooper = AVPlayerLooper.init(player: playerQueue, templateItem: playerItem)
            observeAudioReady()
        } else {
            observeAudioReady()
            player.replaceCurrentItem(with: playerItem)
        }
    }

    func getDuration() -> TimeInterval {
        if (loopAudio) {
            return -1
        }

        if (player.currentItem?.duration == CMTime.indefinite) {
           return -1
        }

        return player.currentItem?.duration.seconds ?? -1
    }

    func getCurrentTime() -> TimeInterval {
        if (loopAudio) {
            return -1
        }

        return player.currentTime().seconds
    }

    func play() {
        if (loopAudio) {
            playerQueue.play()
        } else {
            player.play()
        }

        if (!isPaused) {
            setupNowPlaying()
            setupRemoteTransportControls()
        } else {
            setNowPlayingCurrentTime()
        }
        
        isPaused = false
        setNowPlayingPlaybackState(state: .playing)
    }

    func pause() {
        if (loopAudio) {
            playerQueue.pause()
        } else {
            player.pause()
        }
        
        isPaused = true
        setNowPlayingPlaybackState(state: .paused)
    }

    func seek(timeInSeconds: Int64, fromUi: Bool = false) {
        if (loopAudio) {
            return
        }

        player.seek(to: getCmTime(seconds: timeInSeconds))
        
        if (fromUi) {
            removeRemoteTransportControls()
            removeNowPlaying()
            
            setupNowPlaying()
            setupRemoteTransportControls()
        } else {
            setNowPlayingCurrentTime()
        }
    }
    
    func stop() {
        if (loopAudio) {
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
    }

    func setVolume(volume: Float) {
        if (loopAudio) {
            playerQueue.volume = volume
        } else {
            player.volume = volume
        }
    }

    func setRate(rate: Float) {
        if (loopAudio) {
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
        if (loopAudio) {
            return playerQueue.rate > 0
            || playerQueue.timeControlStatus == AVPlayer.TimeControlStatus.playing
            || playerQueue.timeControlStatus == AVPlayer.TimeControlStatus.waitingToPlayAtSpecifiedRate
        }

        return player.rate > 0
        || player.timeControlStatus == AVPlayer.TimeControlStatus.playing
        || player.timeControlStatus == AVPlayer.TimeControlStatus.waitingToPlayAtSpecifiedRate
    }

    func destroy() {
        removeOnEndObservation()
        isPaused = false
        removeRemoteTransportControls()
        removeNowPlaying()
    }

    private func createPlayerItem() throws -> AVPlayerItem {
        let url = URL.init(string: source)

        if (url == nil) {
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
    
    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
            }
        
        if (type == .began) {
            print("Audio interruption has begun")
            pause()

            makePluginCall(callbackId: onPlaybackStatusChangeCallbackId, data: [
                "status": "paused"
            ])
        }
        
        if (type == .ended) {
            print("Audio interruption has ended")
            play()
            
            makePluginCall(callbackId: onPlaybackStatusChangeCallbackId, data: [
                "status": "playing"
            ])
        }
    }

    private func observeAudioReady() {
        if (onReadyCallbackId == "") {
            return
        }

        if (loopAudio) {
            audioReadyObservation = observe(
                \.playerQueue?.currentItem?.status
            ) { object, change in
                if (self.playerQueue.currentItem?.status == AVPlayerItem.Status.readyToPlay) {
                    self.makePluginCall(callbackId: self.onReadyCallbackId)
                    self.observeOnEnd()
                }
            }
        } else {
            audioReadyObservation = observe(
                \.playerItem?.status
            ) { object, change in
                if (self.playerItem.status == AVPlayerItem.Status.readyToPlay) {
                    self.makePluginCall(callbackId: self.onReadyCallbackId)
                    self.observeOnEnd()
                }
            }
        }
    }

    private func observeOnEnd() {
        if (onEndCallbackId == "") {
            return
        }

        if (loopAudio) {
            return
        }

        if (player.currentItem?.duration == CMTime.indefinite) {
           return
        }

        var times = [NSValue]()
        times.append(NSValue(time: player.currentItem?.duration ?? getCmTime(seconds: 0)))

        audioOnEndObservation = player.addBoundaryTimeObserver(
            forTimes: times,
            queue: .main
        ) {
            [weak self] in
                self?.stop()
                self?.makePluginCall(callbackId: self?.onEndCallbackId ?? "")
        }
    }
    
    private func removeOnEndObservation() {
        if (audioOnEndObservation == nil) {
            return
        }
        
        player.removeTimeObserver(audioOnEndObservation as Any)
        audioOnEndObservation = nil
    }

    private func setupRemoteTransportControls() {
        if (!useForNotification) {
            return
        }
        
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [unowned self] event -> MPRemoteCommandHandlerStatus in
            if (!self.isPlaying()) {
                self.play()

                self.makePluginCall(callbackId: self.onPlaybackStatusChangeCallbackId, data: [
                    "status": "playing"
                ])

                return .success
            }

            return .commandFailed
        }

        commandCenter.pauseCommand.addTarget { [unowned self] event -> MPRemoteCommandHandlerStatus in
            print("Pause rate: " + String(self.player.rate))
            
            if (self.isPlaying()) {
                self.pause()

                self.makePluginCall(callbackId: self.onPlaybackStatusChangeCallbackId, data: [
                    "status": "paused"
                ])

                return .success
            }

            return .commandFailed
        }

        commandCenter.skipBackwardCommand.addTarget { [unowned self] event -> MPRemoteCommandHandlerStatus in
            var seekTime = floor(self.getCurrentTime() - Double(self.STANDARD_SEEK_IN_SECONDS))

            if (seekTime < 0) {
                seekTime = 0
            }

            self.seek(timeInSeconds: Int64(seekTime))

            return .success
        }
        
        commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber.init(value: self.STANDARD_SEEK_IN_SECONDS)]

        commandCenter.skipForwardCommand.addTarget { [unowned self] event -> MPRemoteCommandHandlerStatus in
            var seekTime = ceil(self.getCurrentTime() + Double(self.STANDARD_SEEK_IN_SECONDS))
            var duration = floor(self.getDuration())

            duration = duration < 0 ? 0 : duration

            if (seekTime > duration) {
                seekTime = duration
            }

            self.seek(timeInSeconds: Int64(seekTime))

            return .success
        }
        
        commandCenter.skipForwardCommand.preferredIntervals = [NSNumber.init(value: self.STANDARD_SEEK_IN_SECONDS)]
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.seekBackwardCommand.isEnabled = false
        commandCenter.seekForwardCommand.isEnabled = false
    }

    private func removeRemoteTransportControls() {
        if (!useForNotification) {
            return
        }

        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.removeTarget(nil)
        commandCenter.pauseCommand.removeTarget(nil)
        commandCenter.skipBackwardCommand.removeTarget(nil)
        commandCenter.skipForwardCommand.removeTarget(nil)
    }

    private func setupNowPlaying() {
        if (!useForNotification) {
            return
        }

        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = [String : Any]()

        nowPlayingInfo[MPMediaItemPropertyTitle] = friendlyTitle
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = getDuration()
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = getCurrentTime()
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate

        if let image = UIImage(named: "NowPlayingIcon") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
                MPMediaItemArtwork(boundsSize: image.size) { size in
                    return image
                }
            }

        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
    private func setNowPlayingCurrentTime() {
        if (!useForNotification) {
            return
        }
        
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        
        if (nowPlayingInfo == nil) {
            return
        }
        
        nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = getCurrentTime()

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    private func removeNowPlaying() {
        if (!useForNotification) {
            return
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    private func setNowPlayingPlaybackState(state: MPNowPlayingPlaybackState) {
        if (!useForNotification) {
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
        if (callbackId == "") {
            return
        }

        let call = pluginOwner.bridge?.savedCall(withID: callbackId)

        if (data.isEmpty) {
            call?.resolve()
        } else {
            call?.resolve(data)
        }
    }
}
