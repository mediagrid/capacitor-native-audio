public class AudioMetadata {
    var albumTitle: String
    var artistName: String
    var songTitle: String
    var artworkSource: String
    var updateUrl: String
    var updateInterval: Int = 15

    private var pluginOwner: AudioPlayerPlugin?

    public init(
        albumTitle: String,
        artistName: String,
        songTitle: String,
        artworkSource: String,
        updateUrl: String,
        updateInterval: Int
    ) {
        self.albumTitle = albumTitle
        self.artistName = artistName
        self.songTitle = songTitle
        self.artworkSource = artworkSource
        self.updateUrl = updateUrl

        if updateInterval != -1 {
            self.updateInterval = updateInterval
        }
    }

    public func update(metadata: AudioMetadata) {
        self.albumTitle = metadata.albumTitle
        self.artistName = metadata.artistName
        self.songTitle = metadata.songTitle
        self.artworkSource = metadata.artworkSource
    }

    public func setPluginOwner(pluginOwner: AudioPlayerPlugin) -> Self {
        self.pluginOwner = pluginOwner

        return self
    }

    public func startUpdater() {}

    public func stopUpdater() {}

    public func hasUpdateUrl() -> Bool {
        return !updateUrl.isEmpty
    }
}
