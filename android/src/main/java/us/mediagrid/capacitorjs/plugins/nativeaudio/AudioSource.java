package us.mediagrid.capacitorjs.plugins.nativeaudio;

import android.content.Context;
import android.net.Uri;
import android.os.Binder;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import androidx.media3.common.AudioAttributes;
import androidx.media3.common.C;
import androidx.media3.common.MediaItem;
import androidx.media3.common.MediaMetadata;
import androidx.media3.common.Player;
import androidx.media3.exoplayer.ExoPlayer;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class AudioSource extends Binder {

    private static final String TAG = "AudioSource";

    public String id;
    public String source;
    public AudioMetadata audioMetadata;
    public boolean useForNotification;
    public boolean isBackgroundMusic;
    public boolean loopAudio = false;

    public String onPlaybackStatusChangeCallbackId;
    public String onReadyCallbackId;
    public String onEndCallbackId;

    private AudioPlayerPlugin pluginOwner;

    private Player player;
    private PlayerEventListener playerEventListener;

    private boolean isPlaying = false;
    private boolean isStopped = true;

    // Background tracking properties
    private Handler backgroundTrackingHandler;
    private Runnable backgroundTrackingRunnable;
    private Set<Integer> backgroundPlayedSeconds = new HashSet<>();
    private boolean isBackgroundTrackingActive = false;
    private int trackingDuration = 0;

    public AudioSource(
        AudioPlayerPlugin pluginOwner,
        String id,
        String source,
        AudioMetadata audioMetadata,
        boolean useForNotification,
        boolean isBackgroundMusic,
        boolean loopAudio
    ) {
        this.pluginOwner = pluginOwner;
        this.id = id;
        this.source = source;
        this.audioMetadata = audioMetadata;
        this.useForNotification = useForNotification;
        this.isBackgroundMusic = isBackgroundMusic;
        this.loopAudio = loopAudio;

        this.audioMetadata.setPluginOwner(pluginOwner).setUpdateCallBack(this::updateMetadata);
    }

    public void initialize(Context context) {
        if (useForNotification || player != null) {
            return;
        }

        setIsStopped();

        player = new ExoPlayer.Builder(context).setWakeMode(C.WAKE_MODE_NETWORK).build();
        setPlayerAttributes();

        player.prepare();
    }

    public void setPlayerAttributes() {
        player.setAudioAttributes(
            new AudioAttributes.Builder()
                .setUsage(C.USAGE_MEDIA)
                .setContentType(
                    useForNotification ? C.AUDIO_CONTENT_TYPE_SPEECH : C.AUDIO_CONTENT_TYPE_MUSIC
                )
                .build(),
            useForNotification
        );

        player.setMediaItem(buildMediaItem());
        player.setRepeatMode(loopAudio ? ExoPlayer.REPEAT_MODE_ONE : ExoPlayer.REPEAT_MODE_OFF);
        player.setPlayWhenReady(false);
        player.addListener(new PlayerEventListener(pluginOwner, this));
    }

    public void changeAudioSource(String newSource) {
        source = newSource;

        Player player = getPlayer();

        player.setMediaItem(buildMediaItem());
        player.setPlayWhenReady(false);
        player.prepare();
    }

    public void changeMetadata(AudioMetadata metadata) {
        audioMetadata.update(metadata);
        updateMetadata();
    }

    public float getDuration() {
        long duration = getPlayer().getDuration();

        if (duration == C.TIME_UNSET) {
            return -1;
        }

        return duration / 1000.0f;
    }

    public float getCurrentTime() {
        return getPlayer().getCurrentPosition() / 1000.0f;
    }

    public void play() {
        setIsPlaying();

        Player player = getPlayer();

        if (player.getPlaybackState() == Player.STATE_IDLE) {
            player.prepare();
        }

        player.play();

        if (useForNotification) {
            audioMetadata.startUpdater();
        }
    }

    public void pause() {
        setIsPaused();
        getPlayer().pause();
        audioMetadata.stopUpdater();
    }

    public void seek(long timeInSeconds) {
        getPlayer().seekTo(timeInSeconds * 1000);
    }

    public void stop() {
        setIsStopped();

        Player player = getPlayer();
        player.pause();
        player.seekToDefaultPosition();
        audioMetadata.stopUpdater();
    }

    public void setVolume(float volume) {
        getPlayer().setVolume(volume);
    }

    public void setRate(float rate) {
        getPlayer().setPlaybackSpeed(rate);
    }

    public void setOnReady(String callbackId) {
        onReadyCallbackId = callbackId;
    }

    public void setOnEnd(String callbackId) {
        onEndCallbackId = callbackId;
    }

    public void setOnPlaybackStatusChange(String callbackId) {
        onPlaybackStatusChangeCallbackId = callbackId;
    }

    public boolean isPlaying() {
        if (getPlayer() == null) {
            return false;
        }

        return isPlaying;
    }

    public boolean isPaused() {
        return !isPlaying && !isStopped;
    }

    public boolean isStopped() {
        return isStopped;
    }

    public void setIsPlaying() {
        this.isStopped = false;
        this.isPlaying = true;
    }

    public void setIsPaused() {
        this.isStopped = false;
        this.isPlaying = false;
    }

    public void setIsStopped() {
        this.isStopped = true;
        this.isPlaying = false;
    }

    public Player getPlayer() {
        return player;
    }

    public void setPlayer(Player player) {
        this.player = player;
    }

    public void releasePlayer() {
        if (player != null) {
            player.release();
            player = null;
            playerEventListener = null;
        }
    }

    public void setEventListener(PlayerEventListener listener) {
        playerEventListener = listener;
    }

    public PlayerEventListener getEventListener() {
        return playerEventListener;
    }

    public boolean isInitialized() {
        return getPlayer() != null;
    }

    public MediaItem buildMediaItem() {
        return new MediaItem.Builder().setMediaMetadata(getMediaMetadata()).setUri(source).build();
    }

    public void destroy() {
        audioMetadata.stopUpdater();
        stopBackgroundTracking();

        if (!useForNotification) {
            releasePlayer();
        }
    }

    // Background tracking methods
    private long backgroundTrackingStartPosition = 0;
    private long lastRecordedPosition = 0;

    public void startBackgroundTracking(int duration) {
        if (loopAudio || isBackgroundTrackingActive) {
            Log.d(TAG, "Background tracking already active or loop audio - skipping start");
            return;
        }

        Log.d(TAG, "Starting background tracking for audio ID: " + id + ", duration: " + duration);
        isBackgroundTrackingActive = true;
        trackingDuration = duration;
        backgroundPlayedSeconds.clear();
        
        // Record the starting position
        Player currentPlayer = getPlayer();
        backgroundTrackingStartPosition = currentPlayer != null ? currentPlayer.getCurrentPosition() : 0;
        lastRecordedPosition = backgroundTrackingStartPosition;
        Log.d(TAG, "Background tracking starting from position: " + (backgroundTrackingStartPosition / 1000) + " seconds");

        backgroundTrackingHandler = new Handler(Looper.getMainLooper());
        backgroundTrackingRunnable = new Runnable() {
            @Override
            public void run() {
                if (!isBackgroundTrackingActive) {
                    return;
                }

                Player currentPlayer = getPlayer();
                if (currentPlayer != null && isPlaying()) {
                    long currentPosition = currentPlayer.getCurrentPosition();
                    
                    // Calculate position difference in milliseconds
                    long positionDiff = currentPosition - lastRecordedPosition;
                    
                    // Only track if position progressed normally (similar to JS SEEK_THRESHOLD logic)
                    // Allow up to 3 seconds for background tracking (slightly more lenient than JS)
                    if (positionDiff > 0 && positionDiff <= 3000) { // 3000ms = 3 seconds
                        int startSecond = (int) (lastRecordedPosition / 1000);
                        int endSecond = (int) (currentPosition / 1000);
                        
                        // Only record the actual progression, not skipped content
                        for (int second = startSecond; second <= endSecond && second <= trackingDuration; second++) {
                            if (second * 1000 >= backgroundTrackingStartPosition) {
                                backgroundPlayedSeconds.add(second);
                                Log.d(TAG, "Background tracking recorded second: " + second + " (progression: " + positionDiff + "ms)");
                            }
                        }
                        
                        lastRecordedPosition = currentPosition;
                    } else if (positionDiff > 3000) {
                        Log.d(TAG, "Background tracking detected skip: " + positionDiff + "ms - not tracking skipped content");
                        // Update position but don't track the skipped seconds
                        lastRecordedPosition = currentPosition;
                    }
                }

                // Schedule next execution
                if (isBackgroundTrackingActive) {
                    backgroundTrackingHandler.postDelayed(this, 1000); // 1 second interval
                }
            }
        };

        // Start the tracking
        backgroundTrackingHandler.post(backgroundTrackingRunnable);
    }

    public void stopBackgroundTracking() {
        if (!isBackgroundTrackingActive) {
            Log.d(TAG, "Background tracking already stopped for audio ID: " + id);
            return;
        }

        Log.d(TAG, "Stopping background tracking for audio ID: " + id);
        isBackgroundTrackingActive = false;

        if (backgroundTrackingHandler != null && backgroundTrackingRunnable != null) {
            backgroundTrackingHandler.removeCallbacks(backgroundTrackingRunnable);
            backgroundTrackingHandler = null;
            backgroundTrackingRunnable = null;
            Log.d(TAG, "Background tracking handler cleaned up for audio ID: " + id);
        }
    }

    public int[] fetchBackgroundPlayedSeconds() {
        List<Integer> sortedSeconds = new ArrayList<>(backgroundPlayedSeconds);
        Collections.sort(sortedSeconds);
        
        // Convert to int array
        int[] result = new int[sortedSeconds.size()];
        for (int i = 0; i < sortedSeconds.size(); i++) {
            result[i] = sortedSeconds.get(i);
        }
        
        // Clear the set after fetching
        backgroundPlayedSeconds.clear();
        
        return result;
    }

    private void updateMetadata() {
        var currentMediaItem = getPlayer().getCurrentMediaItem();
        var newMediaItem = currentMediaItem
            .buildUpon()
            .setMediaMetadata(getMediaMetadata())
            .build();

        getPlayer().replaceMediaItem(0, newMediaItem);
    }

    private MediaMetadata getMediaMetadata() {
        MediaMetadata.Builder builder = new MediaMetadata.Builder()
            .setAlbumTitle(audioMetadata.albumTitle == null ? "" : audioMetadata.albumTitle)
            .setArtist(audioMetadata.artistName == null ? "" : audioMetadata.artistName)
            .setTitle(audioMetadata.songTitle == null ? "" : audioMetadata.songTitle);

        if (useForNotification && audioMetadata.artworkSource != null) {
            try {
                if (audioMetadata.artworkSource.startsWith("https:")) {
                    builder.setArtworkUri(Uri.parse(audioMetadata.artworkSource));
                } else {
                    int bufferLength = 4 * 0x400; // 4KB
                    byte[] buffer = new byte[bufferLength];
                    int readLength;
                    ByteArrayOutputStream outputStream = new ByteArrayOutputStream();

                    InputStream inputStream = pluginOwner
                        .getContext()
                        .getAssets()
                        .open("public/" + audioMetadata.artworkSource);

                    while ((readLength = inputStream.read(buffer, 0, bufferLength)) != -1) {
                        outputStream.write(buffer, 0, readLength);
                    }

                    inputStream.close();

                    builder.maybeSetArtworkData(
                        outputStream.toByteArray(),
                        MediaMetadata.PICTURE_TYPE_OTHER
                    );
                }
            } catch (Exception ex) {
                Log.w(TAG, "Could not load the artwork source.", ex);
            }
        }

        return builder.build();
    }
}
