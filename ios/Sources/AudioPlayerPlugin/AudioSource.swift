class AudioSource: NSObject, Codable {
    var audioId: String
    var source: String
    var title: String
    var artist: String
    var albumTitle: String?
    var artworkSource: String?

    init(audioId: String, source: String, title: String, artist: String, albumTitle: String, artworkSource: String) {
        self.audioId = audioId
        self.source = source
        self.title = title
        self.artist = artist
        self.albumTitle = albumTitle
        self.artworkSource = artworkSource
    }
}
