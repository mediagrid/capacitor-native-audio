package us.mediagrid.capacitorjs.plugins.nativeaudio;

import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import com.getcapacitor.JSObject;
import com.getcapacitor.plugin.util.HttpRequestHandler;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;
import org.json.JSONObject;

public class AudioMetadata {

    private static final String TAG = "AudioMetadata";

    public String albumTitle;
    public String artistName;
    public String songTitle;
    public String artworkSource;
    public String updateUrl;
    public Integer updateInterval = 15;

    private Handler updateHandler = null;
    private Runnable updateRunner = null;
    private Runnable updateCallback = null;

    private AudioPlayerPlugin pluginOwner;

    AudioMetadata(
        String albumTitle,
        String artistName,
        String songTitle,
        String artworkSource,
        String updateUrl,
        Integer updateInterval
    ) {
        this.albumTitle = albumTitle;
        this.artistName = artistName;
        this.songTitle = songTitle;
        this.artworkSource = artworkSource;
        this.updateUrl = updateUrl;

        if (updateInterval != null) {
            this.updateInterval = updateInterval;
        }
    }

    public void update(AudioMetadata metadata) {
        albumTitle = metadata.albumTitle;
        artistName = metadata.artistName;
        songTitle = metadata.songTitle;
        artworkSource = metadata.artworkSource;
    }

    public AudioMetadata setPluginOwner(AudioPlayerPlugin plugin) {
        pluginOwner = plugin;

        return this;
    }

    public AudioMetadata setUpdateCallBack(Runnable callback) {
        updateCallback = callback;

        return this;
    }

    public void startUpdater() {
        if (!hasUpdateUrl() || updateHandler != null) {
            return;
        }

        Log.i(TAG, "Starting metadata updater...");

        updateHandler = new Handler(Looper.getMainLooper());
        updateRunner = new Runnable() {
            @Override
            public void run() {
                makeUpdateRequest();

                if (updateCallback != null) {
                    updateCallback.run();
                }

                updateHandler.postDelayed(this, updateInterval * 1000);
            }
        };

        updateHandler.post(updateRunner);
    }

    public void stopUpdater() {
        if (updateHandler == null) {
            return;
        }

        Log.i(TAG, "Stopping metadata updater...");

        updateHandler.removeCallbacks(updateRunner);
        updateHandler = null;
        updateRunner = null;
    }

    private boolean hasUpdateUrl() {
        return updateUrl != null && updateUrl != "";
    }

    private void makeUpdateRequest() {
        Runnable asyncHttpCall = new Runnable() {
            @Override
            public void run() {
                Log.i(TAG, "Getting metadata from URL " + updateUrl);
                HttpURLConnection urlConnection = null;

                try {
                    URL url = new URL(updateUrl);
                    urlConnection = (HttpURLConnection) url.openConnection();
                    urlConnection.setRequestProperty("Accept", "application/json");

                    InputStream errorStream = urlConnection.getErrorStream();

                    if (errorStream != null) {
                        Log.e(
                            TAG,
                            String.format(
                                "The metadata update server returned a status of %s with the message %s",
                                urlConnection.getResponseCode(),
                                HttpRequestHandler.readStreamAsString(errorStream)
                            )
                        );
                    } else {
                        JSObject json = new JSObject(
                            HttpRequestHandler.readStreamAsString(urlConnection.getInputStream())
                        );

                        albumTitle = json.getString("album_title");
                        artistName = json.getString("artist_name");
                        songTitle = json.getString("song_title");
                        artworkSource = json.getString("artwork_source");
                    }
                } catch (Exception ex) {
                    Log.e(TAG, "An error occurred trying to get updated metadata", ex);
                } finally {
                    if (urlConnection != null) {
                        urlConnection.disconnect();
                    }
                }
            }
        };

        if (!pluginOwner.executorService.isShutdown()) {
            pluginOwner.executorService.submit(asyncHttpCall);
        }
    }
}
