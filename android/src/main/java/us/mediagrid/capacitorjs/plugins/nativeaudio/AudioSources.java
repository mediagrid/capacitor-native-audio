package us.mediagrid.capacitorjs.plugins.nativeaudio;

import android.os.Binder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import us.mediagrid.capacitorjs.plugins.nativeaudio.exceptions.AudioSourceAlreadyExistsException;

public class AudioSources extends Binder {

    private HashMap<String, AudioSource> audioSources = new HashMap<>();

    public AudioSource get(String sourceId) {
        return audioSources.get(sourceId);
    }

    public void add(AudioSource source) throws AudioSourceAlreadyExistsException {
        if (exists(source)) {
            throw new AudioSourceAlreadyExistsException(source.id);
        }

        audioSources.put(source.id, source);
    }

    public boolean remove(String sourceId) {
        if (!exists(sourceId)) {
            return false;
        }

        audioSources.remove(sourceId);

        return true;
    }

    public boolean exists(AudioSource source) {
        return exists(source.id);
    }

    public boolean exists(String sourceId) {
        return audioSources.containsKey(sourceId);
    }

    public boolean hasNotification() {
        return forNotification() != null;
    }

    public AudioSource forNotification() {
        for (AudioSource audioSource : audioSources.values()) {
            if (audioSource.useForNotification) {
                return audioSource;
            }
        }

        return null;
    }

    public int count() {
        return audioSources.size();
    }

    public void destroyAllNonNotificationSources() {
        List<AudioSource> sourcesToRemove = new ArrayList<>();

        for (AudioSource audioSource : audioSources.values()) {
            if (audioSource.useForNotification) {
                continue;
            }

            audioSource.releasePlayer();

            sourcesToRemove.add(audioSource);
        }

        for (AudioSource sourceToRemove : sourcesToRemove) {
            audioSources.remove(sourceToRemove.id);
        }
    }
}
