package us.mediagrid.capacitorjs.plugins.nativeaudio;

import android.content.Context;
import android.net.Uri;
import android.os.Binder;
import android.os.Bundle;

import androidx.media3.common.C;
import androidx.media3.common.Player;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.common.MediaItem;
import androidx.media3.common.MediaMetadata;
import androidx.media3.common.AudioAttributes;
import androidx.media3.session.MediaController;
import androidx.media3.session.MediaSession;

public class AudioSource extends Binder {

    private static final String TAG = "AudioSource";

    public String id;
    public String source;
    public String friendlyTitle;
    public boolean useForNotification;
    public String artworkSource;
    public boolean isBackgroundMusic;
    public String onPlaybackStatusChangeCallbackId;
    public String onReadyCallbackId;
    public String onEndCallbackId;

    private AudioPlayerPlugin pluginOwner;

    private ExoPlayer player;
    private MediaController mediaController;
    private PlayerEventListener playerEventListener;

    private boolean isPlaying = false;
    private boolean isStopped = true;
    private boolean loopAudio = false;

    public AudioSource(
        AudioPlayerPlugin pluginOwner,
        String id,
        String source,
        String friendlyTitle,
        boolean useForNotification,
        String artworkSource,
        boolean isBackgroundMusic,
        boolean loopAudio
    ) {
        this.pluginOwner = pluginOwner;
        this.id = id;
        this.source = source;
        this.friendlyTitle = friendlyTitle;
        this.useForNotification = useForNotification;
        this.artworkSource = artworkSource;
        this.isBackgroundMusic = isBackgroundMusic;
        this.loopAudio = loopAudio;
    }

    public void initialize(Context context) {
        if (useForNotification || player != null) {
            return;
        }

        setIsStopped();

        player =
            new ExoPlayer.Builder(context)
                .setAudioAttributes(
                    new AudioAttributes.Builder()
                        .setUsage(C.USAGE_MEDIA)
                        .setContentType(C.AUDIO_CONTENT_TYPE_SPEECH)
                        .build(),
                    false
                )
                .setWakeMode(C.WAKE_MODE_NETWORK)
                .build();
        player.setMediaItem(buildMediaItem());
        player.setRepeatMode(loopAudio ? ExoPlayer.REPEAT_MODE_ONE : ExoPlayer.REPEAT_MODE_OFF);
        player.setPlayWhenReady(false);
        player.addListener(new PlayerEventListener(pluginOwner, this));

        player.prepare();
    }

    public void changeAudioSource(String newSource) {
        source = newSource;

        Player player = getPlayer();

        player.setMediaItem(buildMediaItem());
        player.setPlayWhenReady(false);
        player.prepare();
    }

    public float getDuration() {
        long duration = getPlayer().getDuration();

        if (duration == C.TIME_UNSET) {
            return -1;
        }

        return duration / 1000;
    }

    public float getCurrentTime() {
        return getPlayer().getCurrentPosition() / 1000;
    }

    public void play() {
        setIsPlaying();

        Player player = getPlayer();

        if (player.getPlaybackState() == Player.STATE_IDLE) {
            player.prepare();
        }

        player.play();
    }

    public void pause() {
        setIsPaused();
        getPlayer().pause();
    }

    public void seek(long timeInSeconds) {
        getPlayer().seekTo(timeInSeconds * 1000);
    }

    public void stop() {
        setIsStopped();

        Player player = getPlayer();
        player.pause();
        player.seekToDefaultPosition();
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
        if (useForNotification) {
            return mediaController;
        }

        return player;
    }

    public void setPlayer(Player player) {
        if (useForNotification) {
            mediaController = (MediaController) player;
        } else {
            this.player = (ExoPlayer) player;
        }
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
        return new MediaItem.Builder()
            .setMediaMetadata(
                new MediaMetadata.Builder()
                    .setArtist("")
                    .setTitle(friendlyTitle)
                    .setArtworkUri(getArtworkUri())
                    .build()
            )
            .setUri(source)
            .build();
    }

    private Uri getArtworkUri() {
        if (!useForNotification || artworkSource == null) {
            return null;
        }

        return Uri.parse(artworkSource);
    }
}
