package us.mediagrid.capacitorjs.plugins.nativeaudio.exceptions;

public class AudioSourceAlreadyExistsException extends Exception {

    public AudioSourceAlreadyExistsException(String sourceId) {
        super(String.format("Audio source with ID %s already exists.", sourceId));
    }
}
