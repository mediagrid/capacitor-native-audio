#import <Capacitor/Capacitor.h>

CAP_PLUGIN(AudioPlayerPlugin, "AudioPlayer",
    CAP_PLUGIN_METHOD(create, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(createMultiple, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(play, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(pause, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(stop, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(seek, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(next, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(previous, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(setVolume, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(setRate, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(getCurrentTime, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(getCurrentAudio, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(getDuration, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(setAudioSources, CAPPluginReturnPromise);

    // Focus Callbacks
    CAP_PLUGIN_METHOD(onAppGainsFocus, CAPPluginReturnCallback);
    CAP_PLUGIN_METHOD(onAppLosesFocus, CAPPluginReturnCallback);

    // Playback Callbacks
    CAP_PLUGIN_METHOD(onAudioReady, CAPPluginReturnCallback);
    CAP_PLUGIN_METHOD(onAudioEnd, CAPPluginReturnCallback);
    CAP_PLUGIN_METHOD(onPlaybackStatusChange, CAPPluginReturnCallback);
    CAP_PLUGIN_METHOD(onPlayNext, CAPPluginReturnCallback);
    CAP_PLUGIN_METHOD(onPlayPrevious, CAPPluginReturnCallback);
    CAP_PLUGIN_METHOD(onSeek, CAPPluginReturnCallback);
)
