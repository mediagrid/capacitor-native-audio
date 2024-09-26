public class AudioSources {
    private var audioSources: [String : AudioSource] = [:]
    
    public func get(sourceId: String) -> AudioSource? {
        return audioSources[sourceId]
    }
    
    public func add(source: AudioSource) throws {
        if (exists(source: source)) {
            throw AudioPlayerError.sourceAlreadyExists
        }
        
        audioSources[source.assetId] = source
    }
    
    public func remove(sourceId: String) -> Bool {
        
    }
    
    public func exists(source: AudioSource) -> Bool {
        return exists(sourceId: source.assetId)
    }
    
    public func exists(sourceId: String) -> Bool {
        return audioSources[sourceId] != nil
    }
    
    public func hasNotification() -> Bool {
        
    }
    
    public func forNotification() -> AudioSource? {
        return audioSources.first(where: <#T##((key: String, value: AudioSource)) throws -> Bool#>)
    }
    
    public func count()->Int {
        return audioSources.count
    }
}
