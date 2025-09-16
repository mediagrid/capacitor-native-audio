package us.mediagrid.capacitorjs.plugins.nativeaudio;

import android.app.Notification;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;
import androidx.annotation.Nullable;
import androidx.annotation.OptIn;
import androidx.core.app.NotificationCompat;
import androidx.media3.common.AudioAttributes;
import androidx.media3.common.C;
import androidx.media3.common.Player;
import androidx.media3.common.util.UnstableApi;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.session.MediaSession;
import androidx.media3.session.MediaSessionService;

public class AudioPlayerService extends MediaSessionService {

    private static final String TAG = "AudioPlayerService";
    public static final String PLAYBACK_CHANNEL_ID = "playback_channel";
    private MediaSession mediaSession = null;

    @Override
    public void onCreate() {
        Log.i(TAG, "Service being created");
        super.onCreate();

        ExoPlayer player = new ExoPlayer.Builder(this)
            .setAudioAttributes(
                new AudioAttributes.Builder()
                    .setUsage(C.USAGE_MEDIA)
                    .setContentType(C.AUDIO_CONTENT_TYPE_SPEECH)
                    .build(),
                true
            )
            .setWakeMode(C.WAKE_MODE_NETWORK)
            .build();
        player.setPlayWhenReady(false);
        mediaSession = new MediaSession.Builder(this, player)
            .setCallback(new MediaSessionCallback(this))
            .build();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.i(TAG, "Service starting");
        // Ensure we transition to foreground promptly to avoid 5s timeout
        try {
            Notification notification = buildForegroundNotification();
            // Use a stable ID for the foreground service notification
            startForeground(1, notification);
        } catch (Exception ex) {
            Log.e(TAG, "Failed to start foreground with notification", ex);
        }

        return super.onStartCommand(intent, flags, startId);
    }

    @Override
    public MediaSession onGetSession(MediaSession.ControllerInfo controllerInfo) {
        return mediaSession;
    }

    @Override
    public void onTaskRemoved(@Nullable Intent rootIntent) {
        Log.i(TAG, "Task removed");

        AudioSources audioSources = getAudioSourcesFromMediaSession();

        if (audioSources != null) {
            Log.i(TAG, "Destroying all non-notification audio sources");
            audioSources.destroyAllNonNotificationSources();
        }

        Player player = mediaSession.getPlayer();

        // Make sure the service is not in foreground
        if (player.getPlayWhenReady()) {
            player.pause();
        }

        stopSelf();
    }

    @Override
    public void onDestroy() {
        Log.i(TAG, "Service being destroyed");

        AudioSources audioSources = getAudioSourcesFromMediaSession();

        if (audioSources != null) {
            Log.i(TAG, "Destroying all non-notification audio sources");
            audioSources.destroyAllNonNotificationSources();
        }

        mediaSession.getPlayer().release();
        mediaSession.release();
        mediaSession = null;

        super.onDestroy();
    }

    @OptIn(markerClass = UnstableApi.class)
    private AudioSources getAudioSourcesFromMediaSession() {
        IBinder sourcesBinder = mediaSession.getSessionExtras().getBinder("audioSources");

        if (sourcesBinder != null) {
            return (AudioSources) sourcesBinder;
        }

        return null;
    }

    private Notification buildForegroundNotification() {
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, PLAYBACK_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_media_play)
            .setContentTitle("Audio playback")
            .setContentText("Playing media")
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE);

        return builder.build();
    }
}
