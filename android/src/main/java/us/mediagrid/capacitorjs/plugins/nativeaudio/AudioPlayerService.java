package us.mediagrid.capacitorjs.plugins.nativeaudio;

import android.app.Notification;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Binder;
import android.os.IBinder;
import android.util.Log;

import androidx.appcompat.app.AppCompatActivity;

import com.google.android.exoplayer2.ui.DefaultMediaDescriptionAdapter;
import com.google.android.exoplayer2.ui.PlayerNotificationManager;

import java.util.HashMap;

public class AudioPlayerService extends Service {

    private static final String TAG = "AudioPlayerService";
    public static final String PLAYBACK_CHANNEL_ID = "playback_channel";
    public static final int PLAYBACK_NOTIFICATION_ID = 1;

    private final IBinder serviceBinder = new AudioPlayerServiceBinder();
    private static boolean isRunning = false;

    private PlayerNotificationManager playerNotificationManager;
    private AudioSource notificationAudioSource;
    private HashMap<String, AudioSource> audioSources = new HashMap<>();

    public boolean createAudioSource(AudioSource audioSource) {
        if (audioSources.containsKey(audioSource.id)) {
            Log.w(TAG, String.format("There is already an audio source with ID %s", audioSource.id));

            return false;
        }

        Log.i(TAG, String.format("Initializing audio source ID %s (%s)", audioSource.id, audioSource.source));

        if (audioSource.useForNotification) {
            notificationAudioSource = audioSource;
        }

        audioSource.setServiceOwner(this);
        audioSources.put(audioSource.id, audioSource);

        return true;
    }

    public void initializeAudioSource(String audioSourceId) {
        getAudioSource(audioSourceId).initialize(this);
    }

    public boolean audioSourceExists(String audioSourceId) {
        return audioSources.containsKey(audioSourceId);
    }

    public void changeAudioSource(String audioSourceId, String newSource) {
        Log.i(TAG, String.format("Changing audio source for ID %s to %s", audioSourceId, newSource));

        getAudioSource(audioSourceId).changeAudioSource(newSource);
    }

    public float getDuration(String audioSourceId) {
        Log.i(TAG, String.format("Getting duration for audio source ID %s", audioSourceId));

        return getAudioSource(audioSourceId).getDuration();
    }

    public float getCurrentTime(String audioSourceId) {
        Log.i(TAG, String.format("Getting current time for audio source ID %s", audioSourceId));

        return getAudioSource(audioSourceId).getCurrentTime();
    }

    public void play(String audioSourceId) {
        Log.i(TAG, String.format("Playing audio source ID %s", audioSourceId));

        if (notificationAudioSource.id.equals(audioSourceId)) {
            Log.i(TAG, String.format("Setting notification player to audio source ID %s", audioSourceId));
            playerNotificationManager.setPlayer(getAudioSource(audioSourceId).getPlayer());
        }

        getAudioSource(audioSourceId).play();
    }

    public void pause(String audioSourceId) {
        Log.i(TAG, String.format("Pausing audio source ID %s", audioSourceId));
        getAudioSource(audioSourceId).pause();
    }

    public void seek(String audioSourceId, long timeInSeconds) {
        Log.i(TAG, String.format("Seeking audio source ID %s", audioSourceId));
        getAudioSource(audioSourceId).seek(timeInSeconds);
    }

    public void stop(String audioSourceId) {
        Log.i(TAG, String.format("Stopping audio source ID %s", audioSourceId));

        if (notificationAudioSource.id.equals(audioSourceId)) {
            Log.i(TAG, String.format("Clearing notification for audio source ID %s", audioSourceId));
            clearNotification();
            stopService();
        }

        getAudioSource(audioSourceId).stop();
    }

    public void setVolume(String audioSourceId, float volume) {
        Log.i(TAG, String.format("Setting volume for audio source ID %s", audioSourceId));
        getAudioSource(audioSourceId).setVolume(volume);
    }

    public void setRate(String audioSourceId, float rate) {
        Log.i(TAG, String.format("Setting rate for audio source ID %s", audioSourceId));
        getAudioSource(audioSourceId).setRate(rate);
    }

    public boolean isPlaying(String audioSourceId) {
        return getAudioSource(audioSourceId).isPlaying();
    }

    public void destroyAudioSource(String audioSourceId) throws DestroyNotAllowedException {
        Log.i(TAG, String.format("Destroying audio source ID %s", audioSourceId));

        if (notificationAudioSource != null) {
            if (notificationAudioSource.id.equals(audioSourceId)) {
                if (audioSources.size() > 1) {
                    throw new DestroyNotAllowedException(
                        String.format(
                            "Audio source ID %s is the current notification and cannot be destroyed. Destroy other audio sources first.",
                            audioSourceId
                        )
                    );
                } else {
                    Log.i(TAG, String.format("Clearing notification while destroying audio source ID %s", audioSourceId));
                    clearNotification();
                }
            }
        }

        AudioSource audioSource = getAudioSource(audioSourceId);
        audioSource.releasePlayer();

        audioSources.remove(audioSourceId);

        if (audioSources.isEmpty()) {
            Log.i(TAG, String.format("Stopping service, audio source ID %s was the last source to be destroyed", audioSourceId));
            stopService();
        }
    }

    public void setOnAudioReady(String audioSourceId, String callbackId) {
        getAudioSource(audioSourceId).setOnReady(callbackId);
    }

    public void setOnAudioEnd(String audioSourceId, String callbackId) {
        getAudioSource(audioSourceId).setOnEnd(callbackId);
    }

    public void setOnPlaybackStatusChange(String audioSourceId, String callbackId) {
        getAudioSource(audioSourceId).setOnPlaybackStatusChange(callbackId);
    }

    public boolean isRunning() {
        return isRunning;
    }

    public static Intent newIntent(Context context) {
        return new Intent(context, AudioPlayerService.class);
    }

    public class AudioPlayerServiceBinder extends Binder {

        public AudioPlayerService getService() {
            return AudioPlayerService.this;
        }
    }

    @Override
    public void onCreate() {
        Log.i(TAG, "Service being created");

        Context appContext = getApplication().getApplicationContext();

        playerNotificationManager =
            new PlayerNotificationManager.Builder(appContext, PLAYBACK_NOTIFICATION_ID, PLAYBACK_CHANNEL_ID)
                .setMediaDescriptionAdapter(
                    new DefaultMediaDescriptionAdapter(
                        PendingIntent.getService(
                            appContext,
                            0,
                            new Intent(appContext, appContext.getClass()),
                            PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
                        )
                    )
                )
                .setNotificationListener(
                    new PlayerNotificationManager.NotificationListener() {
                        @Override
                        public void onNotificationCancelled(int notificationId, boolean dismissedByUser) {
                            Log.i(TAG, "Notification cancelled, stopping service");
                            stopService();
                        }

                        @Override
                        public void onNotificationPosted(int notificationId, Notification notification, boolean ongoing) {
                            if (ongoing) {
                                // Make sure the service will not get destroyed while playing media
                                Log.i(TAG, "Notification posted, starting foreground");
                                startForeground(notificationId, notification);
                            } else {
                                // Make notification cancellable
                                Log.i(TAG, "Notification posted, stopping foreground");
                                stopForeground(false);
                            }
                        }
                    }
                )
                .build();

        playerNotificationManager.setUsePreviousAction(false);
        playerNotificationManager.setUseNextAction(false);
        playerNotificationManager.setUseChronometer(true);
        playerNotificationManager.setSmallIcon(getResources().getIdentifier("ic_stat_icon_default", "drawable", getPackageName()));
    }

    @Override
    public IBinder onBind(Intent intent) {
        return serviceBinder;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.i(TAG, "Service starting");
        isRunning = true;

        return super.onStartCommand(intent, flags, startId);
    }

    @Override
    public void onDestroy() {
        Log.i(TAG, "Service being destroyed");
        clearNotification();
        playerNotificationManager = null;

        for (AudioSource audioSource : audioSources.values()) {
            audioSource.releasePlayer();
        }

        audioSources.clear();
        isRunning = false;

        super.onDestroy();
    }

    private AudioSource getAudioSource(String id) {
        AudioSource source = audioSources.get(id);

        if (source == null) {
            Log.w(TAG, String.format("Audio source with ID %s was not found.", id));
        }

        return source;
    }

    private void clearNotification() {
        if (playerNotificationManager != null) {
            Log.i(TAG, "Notification: Setting player to null.");
            playerNotificationManager.setPlayer(null);
        }
    }

    private void stopService() {
        stopForeground(true);
        stopSelf();
        isRunning = false;
    }
}
