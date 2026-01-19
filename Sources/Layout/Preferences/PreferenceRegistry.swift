import UIKit

/// Registry for managing preference values
@MainActor
public final class PreferenceRegistry {
    public static let shared = PreferenceRegistry()
    
    /// View-specific preferences
    private var viewPreferences: [ObjectIdentifier: PreferenceValues] = [:]
    
    /// Preference change handlers
    private var changeHandlers: [ObjectIdentifier: [ObjectIdentifier: (Any) -> Void]] = [:]
    
    private init() {}
    
    /// Gets preferences for a view
    public func preferences(for view: UIView) -> PreferenceValues {
        let id = ObjectIdentifier(view)
        if let prefs = viewPreferences[id] {
            return prefs
        }
        let prefs = PreferenceValues()
        viewPreferences[id] = prefs
        return prefs
    }
    
    /// Sets a preference value
    public func setPreference<K: PreferenceKey>(_ key: K.Type, value: K.Value, for view: UIView) {
        let prefs = preferences(for: view)
        prefs[key] = value
        
        propagatePreference(key, from: view)
        notifyHandlers(for: view, key: key, value: value)
    }
    
    /// Gets a preference value
    public func getPreference<K: PreferenceKey>(_ key: K.Type, for view: UIView) -> K.Value {
        return preferences(for: view)[key]
    }
    
    /// Adds a preference change handler
    public func onPreferenceChange<K: PreferenceKey>(
        _ key: K.Type,
        for view: UIView,
        handler: @escaping (K.Value) -> Void
    ) {
        let viewId = ObjectIdentifier(view)
        let keyId = ObjectIdentifier(key)
        
        if changeHandlers[viewId] == nil {
            changeHandlers[viewId] = [:]
        }
        changeHandlers[viewId]?[keyId] = { value in
            if let typedValue = value as? K.Value {
                handler(typedValue)
            }
        }
    }
    
    /// Removes preference change handlers for a view
    public func removeHandlers(for view: UIView) {
        changeHandlers.removeValue(forKey: ObjectIdentifier(view))
    }
    
    /// Removes all preferences for a view
    public func removePreferences(for view: UIView) {
        let id = ObjectIdentifier(view)
        viewPreferences.removeValue(forKey: id)
        changeHandlers.removeValue(forKey: id)
    }
    
    private func propagatePreference<K: PreferenceKey>(_ key: K.Type, from view: UIView) {
        guard let superview = view.superview else { return }
        
        var combinedValue = K.defaultValue
        for subview in superview.subviews {
            let childValue = preferences(for: subview)[key]
            K.reduce(value: &combinedValue) { childValue }
        }
        
        let parentPrefs = preferences(for: superview)
        parentPrefs[key] = combinedValue
        
        propagatePreference(key, from: superview)
        notifyHandlers(for: superview, key: key, value: combinedValue)
    }
    
    private func notifyHandlers<K: PreferenceKey>(for view: UIView, key: K.Type, value: K.Value) {
        let viewId = ObjectIdentifier(view)
        let keyId = ObjectIdentifier(key)
        changeHandlers[viewId]?[keyId]?(value)
    }
}

