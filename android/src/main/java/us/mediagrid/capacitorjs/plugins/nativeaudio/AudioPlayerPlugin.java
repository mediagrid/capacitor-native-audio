package us.mediagrid.capacitorjs.plugins.nativeaudio;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.ComponentName;
import android.content.Context;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import androidx.media3.session.MediaController;
import androidx.media3.session.SessionCommand;
import androidx.media3.session.SessionResult;
import androidx.media3.session.SessionToken;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.google.common.util.concurrent.ListenableFuture;
import com.google.common.util.concurrent.MoreExecutors;
import java.util.HashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import us.mediagrid.capacitorjs.plugins.nativeaudio.exceptions.DestroyNotAllowedException;

@CapacitorPlugin(name = "AudioPlayer")
public class AudioPlayerPlugin extends Plugin {

    private static final String TAG = "AudioPlayerPlugin";
    public final ExecutorService executorService = Executors.newCachedThreadPool();

    private ListenableFuture<MediaController> audioMediaControllerFuture;
    private MediaController audioMediaController;

    private AudioSources audioSources = new AudioSources();
    private HashMap<String, String> appOnStartCallbackIds = new HashMap<>();
    private HashMap<String, String> appOnStopCallbackIds = new HashMap<>();

    @Override
    public void load() {
        Log.i(TAG, "Handling load");

        super.load();

        createNotificationChannel();
    }

    @PluginMethod
    public void create(PluginCall call) {
        try {
            String sourceId = audioId(call);

            if (audioSourceExists("create", call, false)) {
                Log.w(
                    TAG,
                    String.format("An audio source with the ID %s already exists.", sourceId)
                );
                call.reject("There was an issue creating the audio player [0].");

                return;
            }

            AudioSource audioSource = new AudioSource(
                this,
                sourceId,
                call.getString("audioSource"),
                new AudioMetadata(
                    call.getString("albumTitle"),
                    call.getString("artistName"),
                    call.getString("friendlyTitle"),
                    call.getString("artworkSource"),
                    call.getString("metadataUpdateUrl"),
                    call.getInt("metadataUpdateInterval")
                ),
                call.getBoolean("useForNotification", false),
                call.getBoolean("isBackgroundMusic", false),
                call.getBoolean("loop", false)
            );

            if (audioSources.count() == 0 && !audioSource.useForNotification) {
                throw new RuntimeException(
                    "An audio source with useForNotification = true must exist first."
                );
            }

            if (audioSources.hasNotification() && audioSource.useForNotification) {
                throw new RuntimeException(
                    "An audio source with useForNotification = true already exists. There can only be one."
                );
            }

            audioSources.add(audioSource);

            initializeMediaController("create", call, () -> {
                call.resolve();
            });
        } catch (Exception ex) {
            call.reject("There was an issue creating the audio player.", ex);
        }
    }

    @PluginMethod
    public void initialize(PluginCall call) {
        try {
            if (!audioSourceExists("initialize", call)) {
                return;
            }

            postToLooper("initialize", call, () -> {
                AudioSource audioSource = audioSources.get(audioId(call));

                if (audioSource.useForNotification) {
                    audioSource.setPlayer(audioMediaController);
                    audioSource.setPlayerAttributes();

                    audioMediaController.prepare();

                    Bundle audioSourceBundles = new Bundle();
                    audioSourceBundles.putBinder("audioSources", audioSources);

                    ListenableFuture<SessionResult> commandResult =
                        audioMediaController.sendCustomCommand(
                            new SessionCommand(
                                MediaSessionCallback.SET_AUDIO_SOURCES,
                                audioSourceBundles
                            ),
                            new Bundle()
                        );

                    commandResult.addListener(
                        () -> {
                            try {
                                SessionResult result = commandResult.get();

                                if (result.resultCode == SessionResult.RESULT_SUCCESS) {
                                    call.resolve();
                                } else {
                                    Log.e(
                                        TAG,
                                        String.format(
                                            "Couldn't set audio sources on MediaSession. Result code was %s.",
                                            result.resultCode
                                        )
                                    );
                                    call.reject(
                                        "There was an issue initializing the audio player [1]."
                                    );
                                }
                            } catch (Exception ex) {
                                Log.e(TAG, "Couldn't set audio sources on MediaSession.", ex);
                                call.reject(
                                    "There was an issue initializing the audio player [2].",
                                    ex
                                );
                            }
                        },
                        MoreExecutors.directExecutor()
                    );
                } else {
                    Bundle audioSourceBundle = new Bundle();
                    audioSourceBundle.putBinder("audioSource", audioSource);

                    ListenableFuture<SessionResult> commandResult =
                        audioMediaController.sendCustomCommand(
                            new SessionCommand(
                                MediaSessionCallback.CREATE_PLAYER,
                                audioSourceBundle
                            ),
                            new Bundle()
                        );

                    commandResult.addListener(
                        () -> {
                            try {
                                SessionResult result = commandResult.get();

                                if (result.resultCode == SessionResult.RESULT_SUCCESS) {
                                    call.resolve();
                                } else {
                                    Log.e(
                                        TAG,
                                        String.format(
                                            "Couldn't create player for Audio Id %s. Result code was %s",
                                            audioSource.id,
                                            result.resultCode
                                        )
                                    );
                                    call.reject(
                                        "There was an issue initializing the audio player [3]."
                                    );
                                }
                            } catch (Exception ex) {
                                Log.e(
                                    TAG,
                                    String.format(
                                        "Couldn't create player for Audio Id %s",
                                        audioSource.id
                                    ),
                                    ex
                                );
                                call.reject(
                                    "There was an issue initializing the audio player [4].",
                                    ex
                                );
                            }
                        },
                        MoreExecutors.directExecutor()
                    );
                }
            });
        } catch (Exception ex) {
            call.reject("There was an issue initializing the audio player [5].", ex);
        }
    }

    @PluginMethod
    public void changeAudioSource(PluginCall call) {
        try {
            if (!audioSourceExists("changeAudioSource", call)) {
                return;
            }

            AudioSource audioSource = audioSources.get(audioId(call));

            postToLooper("changeAudioSource", call, () -> {
                audioSource.changeAudioSource(call.getString("source"));

                call.resolve();
            });
        } catch (Exception ex) {
            call.reject("There was an issue changing the audio source.", ex);
        }
    }

    @PluginMethod
    public void changeMetadata(PluginCall call) {
        try {
            if (!audioSourceExists("changeMetadata", call)) {
                return;
            }

            AudioSource audioSource = audioSources.get(audioId(call));

            postToLooper("changeMetadata", call, () -> {
                audioSource.changeMetadata(
                    new AudioMetadata(
                        call.getString("albumTitle"),
                        call.getString("artistName"),
                        call.getString("friendlyTitle"),
                        call.getString("artworkSource"),
                        null,
                        null
                    )
                );

                call.resolve();
            });
        } catch (Exception ex) {
            call.reject("There was an issue changing the metadata.", ex);
        }
    }

    @PluginMethod
    public void updateMetadata(PluginCall call) {
        try {
            if (!audioSourceExists("updateMetadata", call)) {
                return;
            }

            AudioSource audioSource = audioSources.get(audioId(call));

            postToLooper("updateMetadata", call, () -> {
                audioSource.audioMetadata.updateMetadataByUrl(null);

                call.resolve();
            });
        } catch (Exception ex) {
            call.reject("There was an issue updating the metadata.", ex);
        }
    }

    @PluginMethod
    public void getDuration(PluginCall call) {
        try {
            if (!audioSourceExists("getDuration", call)) {
                return;
            }

            postToLooper("getDuration", call, () -> {
                call.resolve(
                    new JSObject().put("duration", audioSources.get(audioId(call)).getDuration())
                );
            });
        } catch (Exception ex) {
            call.reject("There was an issue getting the duration for the audio source.", ex);
        }
    }

    @PluginMethod
    public void getCurrentTime(PluginCall call) {
        try {
            if (!audioSourceExists("getCurrentTime", call)) {
                return;
            }

            postToLooper("getCurrentTime", call, () -> {
                call.resolve(
                    new JSObject()
                        .put("currentTime", audioSources.get(audioId(call)).getCurrentTime())
                );
            });
        } catch (Exception ex) {
            call.reject("There was an issue getting the current time for the audio source.", ex);
        }
    }

    @PluginMethod
    public void play(PluginCall call) {
        try {
            if (!audioSourceExists("play", call)) {
                return;
            }

            postToLooper("play", call, () -> {
                audioSources.get(audioId(call)).play();

                call.resolve();
            });
        } catch (Exception ex) {
            call.reject("There was an issue playing the audio.", ex);
        }
    }

    @PluginMethod
    public void pause(PluginCall call) {
        try {
            if (!audioSourceExists("pause", call)) {
                return;
            }

            postToLooper("pause", call, () -> {
                audioSources.get(audioId(call)).pause();

                call.resolve();
            });
        } catch (Exception ex) {
            call.reject("There was an issue pausing the audio.", ex);
        }
    }

    @PluginMethod
    public void seek(PluginCall call) {
        try {
            if (!audioSourceExists("seek", call)) {
                return;
            }

            postToLooper("seek", call, () -> {
                audioSources.get(audioId(call)).seek(call.getInt("timeInSeconds"));

                call.resolve();
            });
        } catch (Exception ex) {
            call.reject("There was an issue seeking the audio.", ex);
        }
    }

    @PluginMethod
    public void stop(PluginCall call) {
        try {
            if (!audioSourceExists("stop", call)) {
                return;
            }

            postToLooper("stop", call, () -> {
                audioSources.get(audioId(call)).stop();

                call.resolve();
            });
        } catch (Exception ex) {
            call.reject("There was an issue stopping the audio.", ex);
        }
    }

    @PluginMethod
    public void setVolume(PluginCall call) {
        try {
            if (!audioSourceExists("setVolume", call)) {
                return;
            }

            postToLooper("setVolume", call, () -> {
                audioSources.get(audioId(call)).setVolume(call.getFloat("volume"));

                call.resolve();
            });
        } catch (Exception ex) {
            call.reject("There was an issue setting the audio volume.", ex);
        }
    }

    @PluginMethod
    public void setRate(PluginCall call) {
        try {
            if (!audioSourceExists("setRate", call)) {
                return;
            }

            postToLooper("setRate", call, () -> {
                audioSources.get(audioId(call)).setRate(call.getFloat("rate"));

                call.resolve();
            });
        } catch (Exception ex) {
            call.reject("There was an issue setting the rate of the audio.", ex);
        }
    }

    @PluginMethod
    public void isPlaying(PluginCall call) {
        try {
            if (!audioSourceExists("isPlaying", call)) {
                return;
            }

            postToLooper("isPlaying", call, () -> {
                call.resolve(
                    new JSObject().put("isPlaying", audioSources.get(audioId(call)).isPlaying())
                );
            });
        } catch (Exception ex) {
            call.reject("There was an issue getting the playing status of the audio.", ex);
        }
    }

    @PluginMethod
    public void destroy(PluginCall call) {
        try {
            if (!audioSourceExists("destroy", call)) {
                return;
            }

            String audioId = audioId(call);
            AudioSource audioSource = audioSources.get(audioId);

            if (audioSource.useForNotification && audioSources.count() > 1) {
                throw new DestroyNotAllowedException(
                    String.format(
                        "Audio source ID %s is the current notification and cannot be destroyed. Destroy other audio sources first.",
                        audioId
                    )
                );
            }

            appOnStartCallbackIds.remove(audioId);
            appOnStopCallbackIds.remove(audioId);

            postToLooper("destroy", call, () -> {
                if (audioSource.useForNotification) {
                    releaseMediaController();
                }

                audioSource.destroy();
                audioSources.remove(audioId);

                call.resolve();
            });
        } catch (Exception ex) {
            call.reject("There was an issue cleaning up the audio player.", ex);
        }
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void onAppGainsFocus(PluginCall call) {
        call.setKeepAlive(true);
        getBridge().saveCall(call);

        appOnStartCallbackIds.put(audioId(call), call.getCallbackId());
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void onAppLosesFocus(PluginCall call) {
        call.setKeepAlive(true);
        getBridge().saveCall(call);

        appOnStopCallbackIds.put(audioId(call), call.getCallbackId());
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void onAudioReady(PluginCall call) {
        if (!audioSourceExists("onAudioReady", call)) {
            return;
        }

        call.setKeepAlive(true);
        getBridge().saveCall(call);

        audioSources.get(audioId(call)).setOnReady(call.getCallbackId());
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void onAudioEnd(PluginCall call) {
        if (!audioSourceExists("onAudioEnd", call)) {
            return;
        }

        call.setKeepAlive(true);
        getBridge().saveCall(call);

        audioSources.get(audioId(call)).setOnEnd(call.getCallbackId());
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void onPlaybackStatusChange(PluginCall call) {
        if (!audioSourceExists("onPlaybackStatusChange", call)) {
            return;
        }

        call.setKeepAlive(true);
        getBridge().saveCall(call);

        audioSources.get(audioId(call)).setOnPlaybackStatusChange(call.getCallbackId());
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void onMetadataUpdate(PluginCall call) {
        if (!audioSourceExists("onMetadataUpdate", call)) {
            return;
        }

        call.setKeepAlive(true);
        getBridge().saveCall(call);

        audioSources.get(audioId(call)).audioMetadata.setOnMetadataUpdate(call.getCallbackId());
    }

    @Override
    protected void handleOnStart() {
        Log.i(TAG, "Handling onStart");

        super.handleOnStart();

        makeAppStatusChangeCallbacks(appOnStartCallbackIds);
    }

    @Override
    protected void handleOnStop() {
        Log.i(TAG, "Handling onStop");

        makeAppStatusChangeCallbacks(appOnStopCallbackIds);

        super.handleOnStop();
    }

    @Override
    protected void handleOnDestroy() {
        Log.i(TAG, "Handling onDestroy");

        releaseMediaController();
        executorService.shutdownNow();

        super.handleOnDestroy();
    }

    private void initializeMediaController(String methodName, PluginCall call, Runnable callback) {
        Log.i(TAG, "Initializing MediaController");

        if (audioMediaController != null) {
            Log.i(TAG, "MediaController already initialized, running callback.");
            callback.run();

            return;
        }

        postToLooper("initializeMediaController", call, () -> {
            SessionToken sessionToken = new SessionToken(
                getContextForAudioService(),
                new ComponentName(getContextForAudioService(), AudioPlayerService.class)
            );

            audioMediaControllerFuture = new MediaController.Builder(
                getContextForAudioService(),
                sessionToken
            ).buildAsync();

            audioMediaControllerFuture.addListener(
                () -> {
                    try {
                        audioMediaController = audioMediaControllerFuture.get();
                        callback.run();
                    } catch (Exception ex) {
                        Log.e(TAG, "Couldn't get MediaController", ex);
                        call.reject(
                            String.format(
                                "There was an issue initializing the MediaController in method %s",
                                methodName
                            ),
                            ex
                        );
                    }
                },
                MoreExecutors.directExecutor()
            );
        });
    }

    private void releaseMediaController() {
        if (audioMediaController == null) {
            return;
        }

        Log.i(TAG, "Releasing MediaController");

        AudioSource audioSourceForNotification = audioSources.forNotification();

        if (
            audioSourceForNotification != null &&
            audioSourceForNotification.getEventListener() != null
        ) {
            audioMediaController.removeListener(audioSourceForNotification.getEventListener());
        }

        audioMediaController.stop();
        audioMediaController.release();
        MediaController.releaseFuture(audioMediaControllerFuture);
        audioMediaController = null;
    }

    private String audioId(PluginCall call) {
        return call.getString("audioId");
    }

    private boolean audioSourceExists(String methodName, PluginCall call) {
        return audioSourceExists(methodName, call, true);
    }

    private boolean audioSourceExists(String methodName, PluginCall call, boolean rejectIfError) {
        boolean audioSourceExists = audioSources.exists(audioId(call));

        if (!audioSourceExists && rejectIfError) {
            Log.w(TAG, String.format("Audio source with ID %s was not found.", audioId(call)));
            call.reject(
                String.format("There was an issue trying to play the audio (%s [2])", methodName)
            );
        }

        return audioSourceExists;
    }

    private Context getContextForAudioService() {
        return this.getActivity();
    }

    private void createNotificationChannel() {
        if (
            Build.VERSION.SDK_INT < Build.VERSION_CODES.O ||
            getContext()
                .getSystemService(NotificationManager.class)
                .getNotificationChannel(AudioPlayerService.PLAYBACK_CHANNEL_ID) !=
            null
        ) {
            return;
        }

        NotificationManager manager = getContext().getSystemService(NotificationManager.class);

        NotificationChannel playbackChannel = new NotificationChannel(
            AudioPlayerService.PLAYBACK_CHANNEL_ID,
            "Audio playback",
            NotificationManager.IMPORTANCE_LOW
        );

        manager.createNotificationChannel(playbackChannel);
    }

    private void makeAppStatusChangeCallbacks(HashMap<String, String> callbackIds) {
        for (String callbackId : callbackIds.values()) {
            PluginCall call = getBridge().getSavedCall(callbackId);

            if (call == null) {
                continue;
            }

            call.resolve();
        }
    }

    private void postToLooper(String methodName, PluginCall call, Runnable callback) {
        new Handler(Looper.getMainLooper()).post(() -> {
            try {
                callback.run();
            } catch (Exception ex) {
                call.reject(
                    String.format(
                        "There was an issue posting to the looper for method %s",
                        methodName
                    ),
                    ex
                );
            }
        });
    }
}
