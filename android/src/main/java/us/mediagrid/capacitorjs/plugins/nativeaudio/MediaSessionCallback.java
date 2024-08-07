package us.mediagrid.capacitorjs.plugins.nativeaudio;

import android.os.Bundle;

import androidx.annotation.OptIn;
import androidx.media3.common.util.UnstableApi;
import androidx.media3.session.MediaSession;
import androidx.media3.session.SessionCommand;
import androidx.media3.session.SessionCommands;
import androidx.media3.session.SessionResult;

import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.ListenableFuture;

public class MediaSessionCallback implements MediaSession.Callback {
    public static final String SET_AUDIO_SOURCES = "SetAudioSources";
    public static final String CREATE_PLAYER = "CreatePlayer";

    private AudioPlayerService audioService;

    public MediaSessionCallback(AudioPlayerService audioService) {
        this.audioService = audioService;
    }

    @OptIn(markerClass = UnstableApi.class)
    @Override
    public MediaSession.ConnectionResult onConnect(
        MediaSession session,
        MediaSession.ControllerInfo controller
    ) {
        SessionCommands sessionCommands = MediaSession
            .ConnectionResult.DEFAULT_SESSION_COMMANDS.buildUpon()
            .add(new SessionCommand(SET_AUDIO_SOURCES, new Bundle()))
            .add(new SessionCommand(CREATE_PLAYER, new Bundle()))
            .build();

        return new MediaSession.ConnectionResult.AcceptedResultBuilder(session)
            .setAvailableSessionCommands(sessionCommands)
            .build();
    }

    @Override
    public ListenableFuture<SessionResult> onCustomCommand(
        MediaSession session,
        MediaSession.ControllerInfo controller,
        SessionCommand customCommand,
        Bundle args
    ) {
        if (customCommand.customAction.equals(SET_AUDIO_SOURCES)) {
            Bundle audioSouresBundle = new Bundle();
            audioSouresBundle.putBinder("audioSources", customCommand.customExtras.getBinder("audioSources"));

            session.setSessionExtras(audioSouresBundle);
        } else if (customCommand.customAction.equals(CREATE_PLAYER)) {
            AudioSource source = (AudioSource) customCommand.customExtras.getBinder("audioSource");
            source.initialize(audioService);
        }

        return Futures.immediateFuture(
            new SessionResult(SessionResult.RESULT_SUCCESS)
        );
    }
}
