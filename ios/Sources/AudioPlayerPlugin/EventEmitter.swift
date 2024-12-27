import Foundation

public class EventEmitter {
    private var listeners: [String: [(Any) -> Void]] = [:]

    // Add a listener for a specific event
    func on(event: String, listener: @escaping (Any) -> Void) {
        if listeners[event] != nil {
            listeners[event]?.append(listener)
        } else {
            listeners[event] = [listener]
        }
    }

    // Emit an event with optional data
    func emit(event: String, data: Any) {
        guard let eventListeners = listeners[event] else { return }
        for listener in eventListeners {
            listener(data)
        }
    }

    // Remove all listeners for a specific event
    func removeListeners(for event: String) {
        listeners[event] = nil
    }

    // Remove all listeners
    func removeAllListeners() {
        listeners.removeAll()
    }
}
