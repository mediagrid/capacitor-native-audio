import Capacitor

public class AudioMetadata {
    var albumTitle: String
    var artistName: String
    var songTitle: String
    var artworkSource: String
    var updateUrl: String
    var updateInterval: Int = 15

    private var updateHandler: DispatchSourceTimer!
    private var updateCallback: (() -> Void)!

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

    public func setUpdateCallback(callback: @escaping () -> Void) -> Self {
        self.updateCallback = callback

        return self
    }

    public func startUpdater() {
        if !hasUpdateUrl() || updateHandler != nil {
            return
        }

        print("Starting metadata updater...")

        guard
            let updateUrl = URL.init(string: self.updateUrl)
        else {
            print("Update metadata URL is invalid")
            return
        }

        var updateRequest = URLRequest(url: updateUrl)
        updateRequest.addValue("application/json", forHTTPHeaderField: "Accept")

        updateHandler = DispatchSource.makeTimerSource(
            queue: DispatchQueue.global(qos: .background)
        )
        updateHandler.schedule(
            deadline: .now(),
            repeating: .seconds(updateInterval),
            leeway: .milliseconds(250)
        )
        updateHandler.setEventHandler {
            print("Getting metadata from URL \(self.updateUrl)")

            URLSession.shared.dataTask(with: updateRequest) { (data, response, error) in
                if let error = error {
                    print(error)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("The metadata update server response is invalid")
                    return
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    print(
                        "The metadata update server returned a non-2xx status code: \(httpResponse.statusCode)"
                    )
                    return
                }

                do {
                    guard
                        let json = (try JSONSerialization.jsonObject(with: data!)) as? [String: Any]
                    else {
                        print("The metdata update data could not be parsed as JSON")
                        return
                    }
                    print(json)

                    self.albumTitle = json["album_title"] as? String ?? ""
                    self.artistName = json["artist_name"] as? String ?? ""
                    self.songTitle = json["song_title"] as? String ?? ""
                    self.artworkSource = json["artwork_source"] as? String ?? ""
                } catch {
                    print(
                        "An error ocurred trying to get updated metadata: \(error.localizedDescription)"
                    )
                }

                self.updateCallback?()
            }.resume()
        }

        updateHandler.activate()
    }

    public func stopUpdater() {
        if updateHandler == nil {
            return
        }

        print("Stopping metadata updater...")

        updateHandler.cancel()
        updateHandler = nil
    }

    public func hasUpdateUrl() -> Bool {
        return !updateUrl.isEmpty
    }
}
