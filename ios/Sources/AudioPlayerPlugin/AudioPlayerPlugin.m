#import <Capacitor/Capacitor.h>

CAP_PLUGIN(AudioPlayerPlugin, "AudioPlayer",
    CAP_PLUGIN_METHOD(create, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(initialize, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(changeAudioSource, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(getDuration, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(getCurrentTime, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(play, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(pause, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(seek, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(stop, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(setVolume, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(setRate, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(isPlaying, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(destroy, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(onAppGainsFocus, CAPPluginReturnCallback);
    CAP_PLUGIN_METHOD(onAppLosesFocus, CAPPluginReturnCallback);
    CAP_PLUGIN_METHOD(onAudioReady, CAPPluginReturnCallback);
    CAP_PLUGIN_METHOD(onAudioEnd, CAPPluginReturnCallback);
    CAP_PLUGIN_METHOD(onPlaybackStatusChange, CAPPluginReturnCallback);
)
