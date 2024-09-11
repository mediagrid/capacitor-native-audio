public class AudioSources {
    private var audioSources: [String : AudioSource] = [:]
    
    public func get(sourceId: String) -> AudioSource? {
        return audioSources[sourceId]
    }
    
    public func add(source: AudioSource) throws {
        
    }
    
    public func remove(sourceId: String) -> Bool {
        
    }
    
    public func exists(source: AudioSource) -> Bool {
        
    }
    
    public func exists(sourceId: String) -> Bool {
        
    }
    
    public func hasNotification() -> Bool {
        
    }
    
    public func forNotification() -> AudioSource? {
        
    }
    
    public func count()->Int {
        return audioSources.count
    }
}
