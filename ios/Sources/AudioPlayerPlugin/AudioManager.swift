import Foundation
import AVFoundation
import MediaPlayer

public class AudioManager {
    private var audioSources: [AudioSource] = []
    private var currentIndex: Int = 0
    private let audioPlayer = AVPlayer()
    private var audioPlayerVolume: Float = 1.0
    static let eventEmitter = EventEmitter()
    private var airplayEnabled: Bool = false
    
    // Global Callbacks
    var onAudioEnd: (() -> Void)?
    var onPlaybackStatusChange: ((Bool) -> Void)?
    var onPlayNext: (() -> Void)?
    var onPlayPrevious: (() -> Void)?
    var onSeek: ((Double) -> Void)?
    
    init() {
        configureAudioSession()
        configureRemoteCommands()
        observeAudioInterruptions()
        observePlaybackEnd()
    }
    
    // MARK: - Audio Source Management
    
    func addAudioSource(_ source: AudioSource) throws {
        guard !audioSources.contains(where: { $0.audioId == source.audioId }) else {
            throw AudioPlayerError.runtimeError("Audio source with the same ID already exists")
        }
        print("Appended \(source.audioId)")
        audioSources.append(source)
    }
    
    func addAudioSources(_ sources: [AudioSource]) throws {
        for source in sources {
            try addAudioSource(source)
        }
    }
    
    func setAudioSources(_ sources: [AudioSource]) throws {
        // Stop current playback and clear existing sources
        audioSources.removeAll()
        
        // Add new sources
        try addAudioSources(sources)
        currentIndex = 0 // Reset to the first source
        
        print("Audio sources updated successfully")
    }
    
    func replaceAudioSource(withId audioId: String, newSource: AudioSource) throws {
        guard let index = audioSources.firstIndex(where: { $0.audioId == audioId }) else {
            throw AudioPlayerError.runtimeError("Audio source with ID \(audioId) not found")
        }
        audioSources[index] = newSource
        if currentIndex == index {
            try play(newSource)
        }
    }
    
    func getCurrentAudioSource() -> AudioSource? {
        guard currentIndex >= 0 && currentIndex < audioSources.count else { return nil }
        return audioSources[currentIndex]
    }
    
    func getAllAudioSources() -> [AudioSource] {
        return audioSources
    }
    
    // MARK: - Playback Controls
    
    private var playerItemStatusObserver: NSKeyValueObservation?
    
    func play(_ source: AudioSource? = nil) throws {
        // Check if the provided source is nil, and if so, attempt to resume the current item
        if source == nil {
            guard let currentItem = audioPlayer.currentItem else {
                throw AudioPlayerError.runtimeError("No current item to resume playback")
            }
            
            if audioPlayer.timeControlStatus == .playing {
                print("Audio is already playing.")
                return
            } else {
                print("Resuming playback")
                audioPlayer.play()
                updateNowPlayingInfo()
                onPlaybackStatusChange?(true)
                if let currentSource = getCurrentAudioSource() {
                    AudioManager.eventEmitter.emit(event: "playbackStatusChange", data: ["audioId": currentSource.audioId, "isPlaying": true])
                }
                return
            }
        }

        guard let source = source else {
            throw AudioPlayerError.runtimeError("No source provided and no current item available")
        }

        // Check if the currently playing item matches the specified source
        if let currentItem = audioPlayer.currentItem,
           let currentURL = (currentItem.asset as? AVURLAsset)?.url.absoluteString,
           currentURL == source.source {
            if audioPlayer.timeControlStatus == .playing {
                print("Audio is already playing.")
                return
            } else {
                print("Resuming playback for \(source.title)")
                audioPlayer.play()
                updateNowPlayingInfo()
                onPlaybackStatusChange?(true)
                AudioManager.eventEmitter.emit(event: "playbackStatusChange", data: ["audioId": source.audioId, "isPlaying": true])
                return
            }
        }

        // If the currently playing item doesn't match the specified source, find the matching source in the playlist
        if let matchingSource = audioSources.first(where: { $0.audioId == source.audioId }) {
            guard let url = URL(string: matchingSource.source) else {
                throw AudioPlayerError.invalidPath
            }

            let playerItem = AVPlayerItem(url: url)
            audioPlayer.replaceCurrentItem(with: playerItem)

            // Observe the status of the player item
            playerItemStatusObserver = playerItem.observe(\.status, options: [.new, .initial]) { [weak self] item, _ in
                guard let self = self else { return }
                if item.status == .readyToPlay {
                    print("Player item is ready to play")
                    self.updateNowPlayingInfo()
                } else if item.status == .failed {
                    print("Failed to load player item: \(String(describing: item.error))")
                }
            }

            if let index = audioSources.firstIndex(where: { $0.audioId == matchingSource.audioId }) {
                currentIndex = index
            } else {
                throw AudioPlayerError.runtimeError("Audio source not found in the playlist")
            }

            audioPlayer.play()
            onPlaybackStatusChange?(true)
            AudioManager.eventEmitter.emit(event: "playbackStatusChange", data: ["audioId": matchingSource.audioId, "isPlaying": true])

            print("Now playing: \(matchingSource.title)")
        } else {
            throw AudioPlayerError.runtimeError("Matching audio source not found in the playlist")
        }
    }
    
    func resume() {
        audioPlayer.play()
        onPlaybackStatusChange?(true)
        if let currentSource = getCurrentAudioSource() {
            AudioManager.eventEmitter.emit(event: "playbackStatusChange", data: ["audioId": currentSource.audioId, "isPlaying": true])
        }
    }
    
    func pause() {
        audioPlayer.pause()
        onPlaybackStatusChange?(false)
        if let currentSource = getCurrentAudioSource() {
            AudioManager.eventEmitter.emit(event: "playbackStatusChange", data: ["audioId": currentSource.audioId, "isPlaying": false])
        }
    }
    
    func stop() {
        audioPlayer.pause()
        audioPlayer.replaceCurrentItem(with: nil)
        updateNowPlayingInfo()
        print("Playback stopped and player reset")
    }
    
    func playNext() throws {
        onPlayNext?()
        print("onPlayNext callback triggered")
    }
    
    func playPrevious() throws {
        onPlayPrevious?()
        print("onPlayPrevious callback triggered")
    }
    
    func seek(to seconds: Double) throws {
        guard let duration = audioPlayer.currentItem?.duration else {
            throw AudioPlayerError.runtimeError("Unable to get the duration of the current audio source")
        }
        
        let targetTime = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        if targetTime >= .zero && targetTime <= duration {
            audioPlayer.seek(to: targetTime) { completed in
                if completed {
                    print("Seeked to \(seconds) seconds")
                    self.updateNowPlayingInfo()
                    
                    // Trigger the onSeek callback
                    self.onSeek?(seconds)
                    print("onSeek callback triggered with time: \(seconds)")
                }
            }
        } else {
            throw AudioPlayerError.runtimeError("Seek time \(seconds) is out of range (0 - \(CMTimeGetSeconds(duration)))")
        }
    }
    
    func seekForward(by seconds: Double = 10) throws {
        guard let currentItem = audioPlayer.currentItem else {
            throw AudioPlayerError.runtimeError("No active audio source to seek forward")
        }
        
        let currentTime = audioPlayer.currentTime()
        let newTime = CMTimeGetSeconds(currentTime) + seconds
        let duration = CMTimeGetSeconds(currentItem.duration)
        
        if newTime <= duration {
            audioPlayer.seek(to: CMTime(seconds: newTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
            print("Seeked forward by \(seconds) seconds")
            updateNowPlayingInfo()
            
            // Trigger the onSeek callback
            self.onSeek?(newTime)
            print("onSeek callback triggered with time: \(newTime)")
        } else {
            print("Seek forward time exceeds duration")
        }
    }
    
    func seekBackward(by seconds: Double = 10) throws {
        let currentTime = audioPlayer.currentTime()
        let newTime = max(CMTimeGetSeconds(currentTime) - seconds, 0)
        
        audioPlayer.seek(to: CMTime(seconds: newTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        print("Seeked backward by \(seconds) seconds")
        updateNowPlayingInfo()
        
        // Trigger the onSeek callback
        self.onSeek?(newTime)
        print("onSeek callback triggered with time: \(newTime)")
    }
    
    func setVolume(_ volume: Float) {
        guard volume >= 0.0 && volume <= 1.0 else {
            print("Volume must be between 0.0 and 1.0")
            return
        }
        audioPlayer.volume = volume
        audioPlayerVolume = volume
        print("Volume set to \(volume)")
    }
    
    func setRate(rate: Float) {
        audioPlayer.rate = rate
        print("Playback rate set to \(rate)")
    }
    
    func isPlaying() -> Bool {
        return audioPlayer.rate != 0 && audioPlayer.error == nil
    }
    
    // MARK: - Playback Information
    
    func getCurrentDuration() -> Double {
        guard let currentItem = audioPlayer.currentItem else {
            print("No active audio source.")
            return 0.0
        }
        
        if currentItem.status == .readyToPlay {
            let duration = currentItem.asset.duration
            return duration.isNumeric ? CMTimeGetSeconds(duration) : 0.0
        }
        
        // Wait for the player item to become ready
        let semaphore = DispatchSemaphore(value: 0)
        var duration: Double = 0.0
        
        let observer = currentItem.observe(\.status, options: [.new]) { item, _ in
            if item.status == .readyToPlay {
                let itemDuration = item.asset.duration
                duration = itemDuration.isNumeric ? CMTimeGetSeconds(itemDuration) : 0.0
                semaphore.signal()
            }
        }
        
        semaphore.wait() // Blocks the current thread
        observer.invalidate() // Clean up the observer
        return duration
    }
    
    func getCurrentTime() -> Double {
        guard let currentItem = audioPlayer.currentItem else {
            print("No active audio source.")
            return 0.0
        }
        
        if currentItem.status == .readyToPlay {
            let currentTime = audioPlayer.currentTime()
            return currentTime.isNumeric ? CMTimeGetSeconds(currentTime) : 0.0
        }
        
        // Wait for the player item to become ready
        let semaphore = DispatchSemaphore(value: 0)
        var time: Double = 0.0
        
        let observer = currentItem.observe(\.status, options: [.new]) { item, _ in
            if item.status == .readyToPlay {
                let itemTime = self.audioPlayer.currentTime()
                time = itemTime.isNumeric ? CMTimeGetSeconds(itemTime) : 0.0
                semaphore.signal()
            }
        }
        
        semaphore.wait() // Blocks the current thread
        observer.invalidate() // Clean up the observer
        return time
    }
    
    // MARK: - Metadata Updates
    
    private func updateNowPlayingInfo() {
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo: [String: Any] = [:]
                
        guard let audioSource = self.getCurrentAudioSource() else {
            print("No audio source available. Skipping Now Playing Info update.")
            return
        }
        
        // Set metadata fields
        nowPlayingInfo[MPMediaItemPropertyTitle] = audioSource.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = audioSource.artist
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = audioSource.albumTitle
        
        // Fetch and set artwork if available
        if let artworkSource = audioSource.artworkSource, let artworkUrl = URL(string: artworkSource) {
            fetchArtwork(from: artworkUrl) { artwork in
                if let artwork = artwork {
                    nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                    DispatchQueue.main.async {
                        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
                        print("Now playing info updated with artwork")
                    }
                }
            }
        } else {
            print("No artwork available, setting now playing info without artwork")
            DispatchQueue.main.async {
                nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
            }
        }
        
        // Set playback duration and elapsed time
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.getCurrentDuration()
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.getCurrentTime()
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
        
        // Update Now Playing Info
        DispatchQueue.main.async {
            nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
            print("Now playing info updated: \(nowPlayingInfo)")
        }
        
        
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
    private func fetchArtwork(from url: URL, completion: @escaping (MPMediaItemArtwork?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching artwork: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                completion(artwork)
            } else {
                print("Failed to create artwork from data")
                completion(nil)
            }
        }.resume()
    }
    
    private func configureRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Next Track Command
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            do {
                try self.playNext()
                print("Next track command executed")
                return .success
            } catch {
                print("Failed to play next track: \(error)")
                return .commandFailed
            }
        }
        
        // Previous Track Command
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            do {
                try self.playPrevious()
                print("Previous track command executed")
                return .success
            } catch {
                print("Failed to play previous track: \(error)")
                return .commandFailed
            }
        }
        
        // Disable Skip Forward Command
        commandCenter.skipForwardCommand.isEnabled = false
        
        // Disable Skip Backward Command
        commandCenter.skipBackwardCommand.isEnabled = false
        
        // Play Command
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self = self, let currentSource = self.getCurrentAudioSource() else {
                print("No current audio source available to play")
                return .commandFailed
            }
            
            do {
                try self.play(currentSource)
                return .success
            } catch {
                print("Failed to play audio: \(error)")
                return .commandFailed
            }
        }
        
        // Pause Command
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
    }
    
    private func updateCurrentMetadata() {
        guard let currentSource = self.getCurrentAudioSource() else {
            print("No current audio source available")
            return
        }
        updateNowPlayingInfo()
    }
    
    // MARK: - Background Audio
    
    func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowAirPlay])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("Audio session configured for background playback")
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    private func observeAudioInterruptions() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }

    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let interruptionType = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else {
            return
        }
        
        switch interruptionType {
        case AVAudioSession.InterruptionType.began.rawValue:
            print("Audio interruption began")
            audioPlayer.pause()
        case AVAudioSession.InterruptionType.ended.rawValue:
            print("Audio interruption ended")
            let options = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt
            if options == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
                audioPlayer.play()
            }
        default:
            break
        }
    }
    
    
    
    // MARK: - AirPlay Support
    
    func enableAirPlay() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .moviePlayback, options: [.allowAirPlay])
            try audioSession.setActive(true)
            airplayEnabled = true
            print("AirPlay enabled")
        } catch {
            airplayEnabled = false
            print("Failed to enable AirPlay: \(error)")
        }
    }
    
    func isAirPlayActive() -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        return audioSession.currentRoute.outputs.contains { $0.portType == .airPlay }
    }
    
    // MARK: - Callbacks
    
    private func observePlaybackEnd() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioEnd), // Updated to match the function name for clarity
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }

    @objc private func handleAudioEnd() {
        print("Audio playback ended")
        onAudioEnd?()
    }
}
