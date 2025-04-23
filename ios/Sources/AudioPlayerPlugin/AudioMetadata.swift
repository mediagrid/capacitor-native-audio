public class AudioMetadata {
    var albumTitle: String
    var artistName: String
    var songTitle: String
    var artworkSource: String

    public init(
        albumTitle: String,
        artistName: String,
        songTitle: String,
        artworkSource: String
    ) {
        self.albumTitle = albumTitle
        self.artistName = artistName
        self.songTitle = songTitle
        self.artworkSource = artworkSource
    }
}
