package us.mediagrid.capacitorjs.plugins.nativeaudio;

import android.content.Context;
import com.google.android.exoplayer2.C;
import com.google.android.exoplayer2.ExoPlayer;
import com.google.android.exoplayer2.MediaItem;
import com.google.android.exoplayer2.MediaMetadata;
import com.google.android.exoplayer2.audio.AudioAttributes;

public class AudioSource {

    private static final String TAG = "AudioSource";

    public String id;
    public String source;
    public String friendlyTitle;
    public boolean useForNotification;
    public boolean isBackgroundMusic;
    public String onPlaybackStatusChangeCallbackId;
    public String onReadyCallbackId;
    public String onEndCallbackId;

    private AudioPlayerService serviceOwner;
    private AudioPlayerPlugin pluginOwner;
    private ExoPlayer player;
    private boolean isPlaying = false;
    private boolean isStopped = true;
    private boolean loopAudio = false;

    public AudioSource(
        AudioPlayerPlugin pluginOwner,
        String id,
        String source,
        String friendlyTitle,
        boolean useForNotification,
        boolean isBackgroundMusic,
        boolean loopAudio
    ) {
        this.pluginOwner = pluginOwner;
        this.id = id;
        this.source = source;
        this.friendlyTitle = friendlyTitle;
        this.useForNotification = useForNotification;
        this.isBackgroundMusic = isBackgroundMusic;
        this.loopAudio = loopAudio;
    }

    public void initialize(Context context) {
        if (player != null) {
            return;
        }

        isPlaying = false;
        isStopped = true;

        player =
            new ExoPlayer.Builder(context)
                .setAudioAttributes(
                    new AudioAttributes.Builder()
                        .setUsage(C.USAGE_MEDIA)
                        .setContentType(isBackgroundMusic ? C.AUDIO_CONTENT_TYPE_SPEECH : C.AUDIO_CONTENT_TYPE_SPEECH)
                        .build(),
                    useForNotification
                )
                .setWakeMode(C.WAKE_MODE_NETWORK)
                .build();
        player.setMediaItem(buildMediaItem());
        player.setRepeatMode(loopAudio ? ExoPlayer.REPEAT_MODE_ONE : ExoPlayer.REPEAT_MODE_OFF);

        player.addListener(new PlayerEventListener(pluginOwner, this));

        player.prepare();
    }

    public void changeAudioSource(String newSource) {
        source = newSource;

        player.setMediaItem(buildMediaItem());
        player.setPlayWhenReady(false);
        player.prepare();
    }

    public float getDuration() {
        long duration = player.getDuration();

        if (duration == C.TIME_UNSET) {
            return -1;
        }

        return duration / 1000;
    }

    public float getCurrentTime() {
        return player.getCurrentPosition() / 1000;
    }

    public void play() {
        isPlaying = true;
        isStopped = false;

        player.play();
    }

    public void pause() {
        isPlaying = false;
        isStopped = false;

        player.pause();
    }

    public void seek(long timeInSeconds) {
        player.seekTo(timeInSeconds * 1000);
    }

    public void stop() {
        isStopped = true;
        isPlaying = false;

        player.pause();
        player.seekToDefaultPosition();
    }

    public void stopThroughService() {
        serviceOwner.stop(id);
    }

    public void setVolume(float volume) {
        player.setVolume(volume);
    }

    public void setRate(float rate) {
        player.setPlaybackSpeed(rate);
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
        if (player == null) {
            return false;
        }

        return isPlaying;
    }

    public boolean isStopped() {
        return isStopped;
    }

    public void setIsPlaying(boolean isPlaying) {
        this.isPlaying = isPlaying;
    }

    public void setIsStopped(boolean isStopped) {
        this.isStopped = isStopped;
    }

    public void setServiceOwner(AudioPlayerService service) {
        this.serviceOwner = service;
    }

    public ExoPlayer getPlayer() {
        return player;
    }

    public void releasePlayer() {
        if (isInitialized()) {
            player.release();
            player = null;
        }
    }

    public boolean isInitialized() {
        return player != null;
    }

    private MediaItem buildMediaItem() {
        return new MediaItem.Builder()
            .setMediaMetadata(new MediaMetadata.Builder().setArtist("").setTitle(friendlyTitle).build())
            .setUri(source)
            .build();
    }
}
