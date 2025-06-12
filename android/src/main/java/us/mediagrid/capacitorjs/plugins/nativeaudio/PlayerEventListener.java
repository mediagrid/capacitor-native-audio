package us.mediagrid.capacitorjs.plugins.nativeaudio;

import static androidx.media3.common.Player.*;

import com.getcapacitor.JSObject;
import com.getcapacitor.PluginCall;

public class PlayerEventListener implements Listener {

    private static final String TAG = "PlayerEventListener";

    private AudioPlayerPlugin plugin;
    private AudioSource audioSource;

    public PlayerEventListener(AudioPlayerPlugin plugin, AudioSource audioSource) {
        this.plugin = plugin;
        this.audioSource = audioSource;
        this.audioSource.setEventListener(this);
    }

    @Override
    public void onIsPlayingChanged(boolean isPlaying) {
        String status = "stopped";

        if (audioSource.isInitialized()) {
            if (
                audioSource.getPlayer().getPlaybackState() == STATE_READY &&
                !audioSource.getPlayer().getPlayWhenReady() &&
                !audioSource.isStopped()
            ) {
                status = "paused";
                audioSource.setIsPaused();
                audioSource.audioMetadata.stopUpdater();
            } else if (isPlaying || audioSource.isPlaying()) {
                status = "playing";
                audioSource.setIsPlaying();
                audioSource.audioMetadata.startUpdater();
            }
        }

        makeCall(
            audioSource.onPlaybackStatusChangeCallbackId,
            new JSObject().put("status", status)
        );
    }

    @Override
    public void onPlaybackStateChanged(@State int playbackState) {
        if (playbackState == STATE_READY) {
            makeCall(audioSource.onReadyCallbackId);
        }

        if (playbackState == STATE_ENDED) {
            audioSource.getPlayer().stop();
            audioSource.getPlayer().seekToDefaultPosition();
            audioSource.setIsStopped();
            audioSource.audioMetadata.stopUpdater();

            makeCall(audioSource.onEndCallbackId);
        }
    }

    private void makeCall(String callbackId) {
        makeCall(callbackId, new JSObject());
    }

    private void makeCall(String callbackId, JSObject data) {
        if (callbackId == null) {
            return;
        }

        PluginCall call = plugin.getBridge().getSavedCall(callbackId);

        if (call == null) {
            return;
        }

        if (data.length() == 0) {
            call.resolve();
        } else {
            call.resolve(data);
        }
    }
}
