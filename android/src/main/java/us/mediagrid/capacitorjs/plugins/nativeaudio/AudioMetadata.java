package us.mediagrid.capacitorjs.plugins.nativeaudio;

import android.os.Handler;
import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URL;

public class AudioMetadata {

    public String albumTitle;
    public String artistName;
    public String songTitle;
    public String artworkSource;
    public String updateUrl;
    public Integer updateInterval = 15;

    private Handler updateHandler = null;
    private Runnable updateRunner = null;

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

    public void startUpdater() {
        if (!hasUpdateUrl() || updateHandler != null) {
            return;
        }

        updateHandler = new Handler();
        createUpdateRunner();
    }

    public void stopUpdater() {
        if (updateHandler == null) {
            return;
        }

        updateHandler.removeCallbacks(updateRunner);
        updateHandler = null;
        updateRunner = null;
    }

    private boolean hasUpdateUrl() {
        return updateUrl != null && updateUrl != "";
    }

    private void createUpdateRunner() {
        updateRunner = new Runnable() {
            @Override
            public void run() {
                HttpURLConnection urlConnection = null;

                try {
                    URL url = new URL(updateUrl);
                    urlConnection = (HttpURLConnection) url.openConnection();
                    Object content = urlConnection.getContent();
                } catch (Exception ex) {
                    // TODO: Log exception
                } finally {
                    if (urlConnection != null) {
                        urlConnection.disconnect();
                    }
                }

                updateHandler.postDelayed(this, updateInterval * 1000);
            }
        };
    }
}
