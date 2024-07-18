package us.mediagrid.capacitorjs.plugins.nativeaudio;

import android.util.Log;
import com.getcapacitor.JSObject;
import com.getcapacitor.PluginCall;
import com.google.android.exoplayer2.Player;

public class PlayerEventListener implements Player.Listener {

    private static final String TAG = "PlayerEventListener";

    private AudioPlayerPlugin plugin;
    private AudioSource audioSource;

    public PlayerEventListener(AudioPlayerPlugin plugin, AudioSource audioSource) {
        this.plugin = plugin;
        this.audioSource = audioSource;
    }

    @Override
    public void onIsPlayingChanged(boolean isPlaying) {
        String status = "stopped";

        if (audioSource.isInitialized()) {
            if (
                audioSource.getPlayer().getPlaybackState() == Player.STATE_READY &&
                !audioSource.getPlayer().getPlayWhenReady() &&
                !audioSource.isStopped()
            ) {
                status = "paused";
                audioSource.setIsPlaying(false);
            } else if (isPlaying || audioSource.isPlaying()) {
                status = "playing";
                audioSource.setIsPlaying(true);
                audioSource.setIsStopped(false);
            }
        }

        makeCall(audioSource.onPlaybackStatusChangeCallbackId, new JSObject().put("status", status));
    }

    @Override
    public void onPlaybackStateChanged(int playbackState) {
        if (playbackState == Player.STATE_READY) {
            makeCall(audioSource.onReadyCallbackId);
        }

        if (playbackState == Player.STATE_ENDED) {
            audioSource.stopThroughService();

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
