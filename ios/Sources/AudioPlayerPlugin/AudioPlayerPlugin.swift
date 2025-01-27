import AVFAudio
import Capacitor
import Foundation
import AVFoundation
import MediaPlayer

@objc(AudioPlayerPlugin)
public class AudioPlayerPlugin: CAPPlugin {
    let audioManager = AudioManager()
    let audioSession = AVAudioSession.sharedInstance()
    var onGainsFocusCallbackIds: [String: String] = [:]
    var onLosesFocusCallbackIds: [String: String] = [:]

    override public func load() {
        super.load()
        configuredCallbacks()
    }

    // MARK: - Plugin Methods

    @objc func create(_ call: CAPPluginCall) {
        do {
            let sourceId = try audioId(call)

            if audioManager.getAllAudioSources().contains(where: { $0.audioId == sourceId }) {
                call.reject("An audio source with the ID \(sourceId) already exists")
                return
            }

            guard let source = call.getString("audioSource") else {
                throw AudioPlayerError.invalidPath
            }

            let audioSource = AudioSource(
                audioId: sourceId,
                source: source,
                title: call.getString("title") ?? "",
                artist: call.getString("artist") ?? "",
                albumTitle: call.getString("albumTitle") ?? "",
                artworkSource: call.getString("artworkSource") ?? ""
            )

            try audioManager.addAudioSource(audioSource)
            call.resolve()
        } catch {
            call.reject("There was an issue creating the audio player", nil, error)
        }
    }

    @objc func createMultiple(_ call: CAPPluginCall) {
        do {
            guard let sources = call.getArray("audioSources", JSObject.self) else {
                throw AudioPlayerError.invalidSource
            }

            var createdSources: [AudioSource] = []

            for source in sources {
                guard let audioId = source["audioId"] as? String,
                      let audioPath = source["source"] as? String else {
                    throw AudioPlayerError.invalidAudioId
                }

                let audioSource = AudioSource(
                    audioId: audioId,
                    source: audioPath,
                    title: source["title"] as? String ?? "",
                    artist: source["artist"] as? String ?? "",
                    albumTitle: source["albumTitle"] as? String ?? "",
                    artworkSource: source["artworkSource"] as? String ?? ""
                )

                createdSources.append(audioSource)
            }

            try audioManager.addAudioSources(createdSources)
            call.resolve(["createdSourcesCount": createdSources.count])
        } catch let error {
            let detailedError = "Error in createMultiple function: \(error.localizedDescription)\nDetails: \(error)"
            call.reject(detailedError)
        }
    }
    
    @objc func setAudioSources(_ call: CAPPluginCall) {
        guard let sourcesArray = call.getArray("audioSources") as? [[String: Any]] else {
            call.reject("Invalid or missing audio sources")
            return
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: sourcesArray, options: [])
            let audioSources = try JSONDecoder().decode([AudioSource].self, from: jsonData)

            try audioManager.setAudioSources(audioSources)
            call.resolve(["message": "Audio sources updated successfully"])
        } catch {
            print("Error decoding audio sources:", error)
            call.reject("Failed to decode audio sources: \(error.localizedDescription)")
        }
    }

    @objc func play(_ call: CAPPluginCall) {
        do {
            let audioSource = tryGetAudioSource(call)
            try audioManager.play(audioSource)
            call.resolve()
        } catch let error {
            call.reject("There was an issue playing the audio \(error.localizedDescription)")
        }
    }

    @objc func pause(_ call: CAPPluginCall) {
        audioManager.pause()
        call.resolve()
    }

    @objc func stop(_ call: CAPPluginCall) {
        audioManager.stop()
        call.resolve()
    }

    @objc func seek(_ call: CAPPluginCall) {
        do {
            guard let timeInSeconds = call.getInt("timeInSeconds") else {
                throw AudioPlayerError.invalidSeekTime
            }

            try audioManager.seek(to: Double(timeInSeconds))
            call.resolve()
        } catch {
            call.reject("There was an issue seeking the audio", nil, error)
        }
    }

    @objc func next(_ call: CAPPluginCall) {
        do {
            try audioManager.playNext()
            call.resolve()
        } catch {
            call.reject("There was an issue playing the next audio", nil, error)
        }
    }

    @objc func previous(_ call: CAPPluginCall) {
        do {
            try audioManager.playPrevious()
            call.resolve()
        } catch {
            call.reject("There was an issue playing the previous audio", nil, error)
        }
    }

    @objc func setVolume(_ call: CAPPluginCall) {
        guard let volume = call.getFloat("volume") else {
            call.reject("Volume parameter is missing or invalid")
            return
        }

        if volume < 0.0 || volume > 1.0 {
            call.reject("Volume must be between 0.0 and 1.0")
            return
        }

        audioManager.setVolume(volume)
    }

    @objc func setRate(_ call: CAPPluginCall) {
        guard let rate = call.getFloat("rate") else {
            call.reject("Rate parameter is missing or invalid")
            return
        }

        audioManager.setRate(rate: rate)
        call.resolve()
    }

    @objc func getCurrentTime(_ call: CAPPluginCall) {
        let currentTime = audioManager.getCurrentTime()
        call.resolve(["currentTime": currentTime])
    }
    
    @objc func isPlaying(_ call: CAPPluginCall) {
        let isPlaying = audioManager.isPlaying()
        call.resolve(["isPlaying": isPlaying])
    }
    
    @objc func getCurrentAudio(_ call: CAPPluginCall) {
        guard let currentAudioSource = audioManager.getCurrentAudioSource() else {
            call.reject("No current audio source")
            return
        }

        call.resolve([
            "audioId": currentAudioSource.audioId,
            "title": currentAudioSource.title,
            "artist": currentAudioSource.artist,
            "albumTitle": currentAudioSource.albumTitle,
            "artworkSource": currentAudioSource.artworkSource,
            "duration": audioManager.getCurrentDuration(),
            "currentTime": audioManager.getCurrentTime(),
            "isPlaying": audioManager.isPlaying()
        ])
    }

    @objc func getDuration(_ call: CAPPluginCall) {
        let duration = audioManager.getCurrentDuration()
        call.resolve(["duration": duration])
    }
    
    @objc func showAirPlayMenu(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            // Create a temporary MPVolumeView
            let volumeView = MPVolumeView(frame: .zero)
            volumeView.showsVolumeSlider = false
            volumeView.showsRouteButton = true

            // Add the volumeView to the current view hierarchy
            self.bridge?.viewController?.view.addSubview(volumeView)

            // Simulate a tap on the AirPlay button
            if let routeButton = volumeView.subviews.first(where: { $0 is UIButton }) as? UIButton {
                routeButton.sendActions(for: .touchUpInside)
                call.resolve(["success": true])
            } else {
                call.reject("AirPlay menu could not be displayed")
            }

            // Remove the volumeView after the menu is displayed
            volumeView.removeFromSuperview()
        }
    }

    // MARK: - Configure Remote Commands

    private func configuredCallbacks() {
        let commandCenter = MPRemoteCommandCenter.shared()

        // Hook into AudioManager's callbacks
        audioManager.onPlayNext = {
            print("Native onPlayNext should be triggered")
            self.notifyListeners("onPlayNext", data: [:])
        }

        audioManager.onPlayPrevious = {
            print("Native onPlayPrevious should be triggered")
            self.notifyListeners("onPlayPrevious", data: [:])
        }

        audioManager.onSeek = { time in
            print("Native onSeek should be triggered")
            self.notifyListeners("onSeek", data: ["time": time])
        }

        audioManager.onPlaybackStatusChange = { isPlaying in
            print("Native onPlaybackStatusChange should be triggered")
            self.notifyListeners("onPlaybackStatusChange", data: ["isPlaying": isPlaying])
        }
        
        audioManager.onAudioEnd = {
            print("Native onAudioEnd should be triggered")
            self.notifyListeners("onAudioEnd", data: [:])
        }

        audioManager.onAirPlayActiveChange = { isEnabled in
            print("Native onAirPlayEnabled should be triggered with state: \(isEnabled)")
            self.notifyListeners("onAirPlayEnabled", data: ["isEnabled": isEnabled])
        }
    }

    @objc func handleAppToBackground() {
        print("App moved to background")
        makeFocusChangeCallbackCalls(callbackIds: onLosesFocusCallbackIds)
    }

    @objc func handleAppToForeground() {
        print("App moved to foreground")
        makeFocusChangeCallbackCalls(callbackIds: onGainsFocusCallbackIds)
    }

    // MARK: - Helper Methods

    private func audioId(_ call: CAPPluginCall) throws -> String {
        guard let audioId = call.getString("audioId") else {
            throw AudioPlayerError.invalidAudioId
        }
        return audioId
    }

    private func getAudioSource(_ call: CAPPluginCall) throws -> AudioSource {
        let audioId = try audioId(call)
        guard let source = audioManager.getAllAudioSources().first(where: { $0.audioId == audioId }) else {
            throw AudioPlayerError.missingAudioSource
        }
        return source
    }
    
    private func tryGetAudioSource(_ call: CAPPluginCall) -> AudioSource? {
        guard let audioId = call.getString("audioId") else {
            return nil
        }

        guard let source = audioManager.getAllAudioSources().first(where: { $0.audioId == audioId }) else {
            return nil
        }

        return source
    }

    private func makeFocusChangeCallbackCalls(callbackIds: [String: String]) {
        for callbackId in callbackIds.values {
            bridge?.savedCall(withID: callbackId)?.resolve()
        }
    }
}
