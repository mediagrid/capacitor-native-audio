package us.mediagrid.capacitorjs.plugins.nativeaudio;

public class AudioMetadata {

    public String albumTitle;
    public String artistName;
    public String songTitle;
    public String artworkSource;

    AudioMetadata(String albumTitle, String artistName, String songTitle, String artworkSource) {
        this.albumTitle = albumTitle;
        this.artistName = artistName;
        this.songTitle = songTitle;
        this.artworkSource = artworkSource;
    }
}
