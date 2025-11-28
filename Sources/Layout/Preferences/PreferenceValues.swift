import Foundation

/// Container for preference values
@MainActor
public final class PreferenceValues {
    private var storage: [ObjectIdentifier: Any] = [:]
    
    public subscript<K: PreferenceKey>(key: K.Type) -> K.Value {
        get {
            return (storage[ObjectIdentifier(key)] as? K.Value) ?? K.defaultValue
        }
        set {
            var currentValue = self[key]
            K.reduce(value: &currentValue) { newValue }
            storage[ObjectIdentifier(key)] = currentValue
        }
    }
    
    /// Resets a preference to its default value
    public func reset<K: PreferenceKey>(_ key: K.Type) {
        storage.removeValue(forKey: ObjectIdentifier(key))
    }
}

