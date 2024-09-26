public class AudioSources {
    private var audioSources: [String: AudioSource] = [:]

    public func get(sourceId: String) -> AudioSource? {
        return audioSources[sourceId]
    }

    public func add(source: AudioSource) throws {
        if exists(source: source) {
            throw AudioPlayerError.sourceAlreadyExists
        }

        audioSources[source.id] = source
    }

    public func remove(sourceId: String) -> Bool {
        if !exists(sourceId: sourceId) {
            return false
        }

        audioSources.removeValue(forKey: sourceId)

        return true
    }

    public func exists(source: AudioSource) -> Bool {
        return exists(sourceId: source.id)
    }

    public func exists(sourceId: String) -> Bool {
        return audioSources[sourceId] != nil
    }

    public func hasNotification() -> Bool {
        return forNotification() != nil
    }

    public func forNotification() -> AudioSource? {
        return audioSources.first(
            where: { source -> Bool in return source.value.useForNotification }
        )?.value
    }

    public func count() -> Int {
        return audioSources.count
    }
}
