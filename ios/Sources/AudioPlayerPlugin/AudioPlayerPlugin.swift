import Foundation
import AVFAudio
import Capacitor

@objc(AudioPlayerPlugin)
public class AudioPlayerPlugin: CAPPlugin, CAPBridgedPlugin {
    let audioSession = AVAudioSession.sharedInstance()
    var audioSources: [String : AudioSource] = [:]
    var onGainsFocusCallbackIds: [String : String] = [:]
    var onLosesFocusCallbackIds: [String : String] = [:]

    override public func load() {
        super.load()

        do {
            try audioSession.setCategory(
                AVAudioSession.Category.playback,
                mode: AVAudioSession.Mode.spokenAudio
            )

            try audioSession.setActive(false)
        } catch {
            print("Failed to set audio session category")
        }

        print("Listening to app background/foreground event changes")

        let notificationCenter = NotificationCenter.default

        notificationCenter.addObserver(
            self,
            selector: #selector(handleAppToBackground),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )

        notificationCenter.addObserver(
            self,
            selector: #selector(handleAppToForeground),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc func create(_ call: CAPPluginCall) {
        do {
            let sourceId = try audioId(call)
            guard let source = call.getString("audioSource") else { throw AudioPlayerError.invalidPath }
            guard let friendlyTitle = call.getString("friendlyTitle") else { throw AudioPlayerError.invalidFriendlyName }

            let audioSource = AudioSource(
                pluginOwner: self,
                id: sourceId,
                source: source,
                friendlyTitle: friendlyTitle,
                useForNotification: call.getBool("useForNotification", false),
                isBackgroundMusic: call.getBool("isBackgroundMusic", false),
                loopAudio: call.getBool("loop", false)
            )

            audioSources[sourceId] = audioSource

            call.resolve()
        } catch AudioPlayerError.missingAudioSource {
            return
        } catch {
            call.reject("There was an issue creating the audio player.", nil, error)
        }
    }

    @objc func initialize(_ call: CAPPluginCall) {
        do {
            try getAudioSource(methodName: "initialize", call: call).initialize()

            call.resolve()
        } catch AudioPlayerError.missingAudioSource {
            return
        } catch {
            call.reject("There was an issue initializing the audio player.", nil, error)
        }
    }

    @objc func changeAudioSource(_ call: CAPPluginCall) {
        do {
            guard let newSource = call.getString("source") else { throw AudioPlayerError.invalidSource }

            try getAudioSource(methodName: "changeAudioSource", call: call).changeAudioSource(newSource: newSource)

            call.resolve()
        } catch AudioPlayerError.missingAudioSource {
            return
        } catch {
            call.reject("There was an issue changing the audio source.", nil, error)
        }
    }

    @objc func getDuration(_ call: CAPPluginCall) {
        do {
            let duration = try getAudioSource(methodName: "duration", call: call).getDuration()

            call.resolve(["duration": duration])
        } catch AudioPlayerError.missingAudioSource {
            return
        } catch {
            call.reject("There was an issue getting the duration for the audio source.", nil, error)
        }
    }

    @objc func getCurrentTime(_ call: CAPPluginCall) {
        do {
            let currentTime = try getAudioSource(methodName: "currentTime", call: call).getCurrentTime()

            call.resolve(["currentTime": currentTime])
        } catch AudioPlayerError.missingAudioSource {
            return
        } catch {
            call.reject("There was an issue getting the current time for the audio source.", nil, error)
        }
    }

    @objc func play(_ call: CAPPluginCall) {
        do {
            let audioSource = try getAudioSource(methodName: "play", call: call)

            if (audioSource.useForNotification) {
                try audioSession.setActive(true)
            }

            audioSource.play()

            call.resolve()
        } catch AudioPlayerError.missingAudioSource {
            return
        } catch {
            call.reject("There was an issue playing the audio.", nil, error)
        }
    }

    @objc func pause(_ call: CAPPluginCall) {
        do {
            try getAudioSource(methodName: "pause", call: call).pause()

            call.resolve()
        } catch AudioPlayerError.missingAudioSource {
            return
        } catch {
            call.reject("There was an issue pausing the audio.", nil, error)
        }
    }

    @objc func seek(_ call: CAPPluginCall) {
        do {
            guard let timeInSeconds = call.getInt("timeInSeconds") else {throw AudioPlayerError.invalidSeekTime }

            try getAudioSource(methodName: "seek", call: call).seek(timeInSeconds: Int64(timeInSeconds), fromUi: true)

            call.resolve()
        } catch AudioPlayerError.missingAudioSource {
            return
        } catch {
            call.reject("There was an issue seeking the audio.", nil, error)
        }
    }

    @objc func stop(_ call: CAPPluginCall) {
        do {
            let audioSource = try getAudioSource(methodName: "stop", call: call)

            audioSource.stop()

            if (audioSource.useForNotification) {
                try audioSession.setActive(false)
            }

            call.resolve()
        } catch AudioPlayerError.missingAudioSource {
            return
        } catch {
            call.reject("There was an issue stopping the audio.", nil, error)
        }
    }

    @objc func setVolume(_ call: CAPPluginCall) {
        do {
            guard let volume = call.getFloat("volume") else {throw AudioPlayerError.invalidSeekTime }

            try getAudioSource(methodName: "setVolume", call: call).setVolume(volume: volume)

            call.resolve()
        } catch AudioPlayerError.missingAudioSource {
            return
        } catch {
            call.reject("There was an issue setting the audio volume.", nil, error)
        }
    }

    @objc func setRate(_ call: CAPPluginCall) {
        do {
            guard let rate = call.getFloat("rate") else {throw AudioPlayerError.invalidRate }

            try getAudioSource(methodName: "setRate", call: call).setRate(rate: rate)

            call.resolve()
        } catch AudioPlayerError.missingAudioSource {
            return
        } catch {
            call.reject("There was an issue setting the rate of the audio.", nil, error)
        }
    }

    @objc func isPlaying(_ call: CAPPluginCall) {
        do {
            let isPlaying = try getAudioSource(methodName: "isPlaying", call: call).isPlaying()

            call.resolve(["isPlaying": isPlaying])
        } catch AudioPlayerError.missingAudioSource {
            return
        } catch {
            call.reject("There was an issue getting the playing status of the audio.", nil, error)
        }
    }

    @objc func destroy(_ call: CAPPluginCall) {
        do {
            let audioSource = try getAudioSource(methodName: "destroy", call: call)

            if (audioSource.useForNotification) {
                try audioSession.setActive(false)
            }

            audioSource.stop()
            audioSource.destroy()

            let audioId = try audioId(call)

            audioSources.removeValue(forKey: audioId)
            onLosesFocusCallbackIds.removeValue(forKey: audioId)
            onGainsFocusCallbackIds.removeValue(forKey: audioId)

            call.resolve()
        } catch AudioPlayerError.missingAudioSource {
            return
        } catch {
            call.reject("There was an issue cleaning up the audio player.", nil, error)
        }
    }

    @objc func onAppGainsFocus(_ call: CAPPluginCall) {
        do {
            call.keepAlive = true
            bridge?.saveCall(call)

            onGainsFocusCallbackIds[try audioId(call)] = call.callbackId
        } catch {
            call.reject("There was an issue registering onAppGainsFocus", nil, error)
        }
    }

    @objc func onAppLosesFocus(_ call: CAPPluginCall) {
        do {
            call.keepAlive = true
            bridge?.saveCall(call)

            onLosesFocusCallbackIds[try audioId(call)] = call.callbackId
        } catch {
            call.reject("There was an issue registering onAppLosesFocus", nil, error)
        }
    }

    @objc func onAudioReady(_ call: CAPPluginCall) {
        call.keepAlive = true
        bridge?.saveCall(call)

        do {
            try getAudioSource(methodName: "onAudioReady", call: call).setOnReady(callbackId: call.callbackId)
        } catch AudioPlayerError.missingAudioSource {
            return
        } catch {
            call.reject("There was an issue initializing audio ready.", nil, error)
        }
    }

    @objc func onAudioEnd(_ call: CAPPluginCall) {
        call.keepAlive = true
        bridge?.saveCall(call)

        do {
            try getAudioSource(methodName: "onAudioEnd", call: call).setOnEnd(callbackId: call.callbackId)
        } catch AudioPlayerError.missingAudioSource {
            return
        } catch {
            call.reject("There was an issue initializing audio end.", nil, error)
        }

    }

    @objc func onPlaybackStatusChange(_ call: CAPPluginCall) {
        call.keepAlive = true
        bridge?.saveCall(call)

        do {
            try getAudioSource(methodName: "onPlaybackStatusChange", call: call)
                .setOnPlaybackStatusChange(callbackId: call.callbackId)
        } catch AudioPlayerError.missingAudioSource {
            return
        } catch {
            call.reject("There was an issue initializing playback status change.", nil, error)
        }
    }

    @objc func handleAppToBackground() {
        print("Going to background")

        makeFocusChangeCallbackCalls(callbackIds: onLosesFocusCallbackIds)
    }

    @objc func handleAppToForeground() {
        print("Coming to foreground")

        makeFocusChangeCallbackCalls(callbackIds: onGainsFocusCallbackIds)
    }

    func audioId(_ call: CAPPluginCall) throws -> String {
        guard let audioId = call.getString("audioId") else {
            throw AudioPlayerError.invalidAudioId
        }

        return audioId
    }

    func getAudioSource(methodName: String, call: CAPPluginCall) throws -> AudioSource {
        return try getAudioSource(methodName: methodName, call: call, rejectIfError: true)
    }

    func getAudioSource(methodName: String, call: CAPPluginCall, rejectIfError: Bool) throws -> AudioSource {
        let audioSource = audioSources[try audioId(call)]

        if (audioSource == nil) {
            print("Audio source with ID \(try audioId(call)) was not found.")

            if (rejectIfError) {
                call.reject("There was an issue trying to play the audio (\(methodName))")
            }

            throw AudioPlayerError.missingAudioSource
        }

        return audioSource!
    }

    func makeFocusChangeCallbackCalls(callbackIds: [String : String]) {
        for callbackId in callbackIds.values {
            bridge?.savedCall(withID: callbackId)?.resolve()
        }
    }
}
