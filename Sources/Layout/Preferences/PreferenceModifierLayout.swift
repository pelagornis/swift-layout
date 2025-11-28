import UIKit

/// A layout that sets a preference value
@MainActor
public struct PreferenceModifierLayout<K: PreferenceKey>: Layout {
    public typealias Body = Never
    
    public var body: Never {
        fatalError("PreferenceModifierLayout is a primitive layout")
    }
    
    private let base: any Layout
    private let key: K.Type
    private let value: K.Value
    
    public init(base: any Layout, key: K.Type, value: K.Value) {
        self.base = base
        self.key = key
        self.value = value
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        return base.calculateLayout(in: bounds)
    }
    
    public func extractViews() -> [UIView] {
        let views = base.extractViews()
        
        for view in views {
            PreferenceRegistry.shared.setPreference(key, value: value, for: view)
        }
        
        return views
    }
    
    public var intrinsicContentSize: CGSize {
        return base.intrinsicContentSize
    }
}

/// A layout that responds to preference changes
@MainActor
public struct OnPreferenceChangeLayout<K: PreferenceKey>: Layout {
    public typealias Body = Never
    
    public var body: Never {
        fatalError("OnPreferenceChangeLayout is a primitive layout")
    }
    
    private let base: any Layout
    private let key: K.Type
    private let action: (K.Value) -> Void
    
    public init(base: any Layout, key: K.Type, action: @escaping (K.Value) -> Void) {
        self.base = base
        self.key = key
        self.action = action
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        return base.calculateLayout(in: bounds)
    }
    
    public func extractViews() -> [UIView] {
        let views = base.extractViews()
        
        for view in views {
            PreferenceRegistry.shared.onPreferenceChange(key, for: view, handler: action)
        }
        
        return views
    }
    
    public var intrinsicContentSize: CGSize {
        return base.intrinsicContentSize
    }
}

// MARK: - Layout Extensions

extension Layout {
    /// Sets a preference value
    public func preference<K: PreferenceKey>(key: K.Type, value: K.Value) -> PreferenceModifierLayout<K> {
        return PreferenceModifierLayout(base: self, key: key, value: value)
    }
    
    /// Responds to preference changes
    public func onPreferenceChange<K: PreferenceKey>(
        _ key: K.Type,
        perform action: @escaping (K.Value) -> Void
    ) -> OnPreferenceChangeLayout<K> {
        return OnPreferenceChangeLayout(base: self, key: key, action: action)
    }
}

// MARK: - UIView Extension for Preferences

extension UIView {
    /// Sets a preference value
    public func setPreference<K: PreferenceKey>(_ key: K.Type, value: K.Value) {
        PreferenceRegistry.shared.setPreference(key, value: value, for: self)
    }
    
    /// Gets a preference value
    public func getPreference<K: PreferenceKey>(_ key: K.Type) -> K.Value {
        return PreferenceRegistry.shared.getPreference(key, for: self)
    }
    
    /// Observes preference changes
    public func onPreferenceChange<K: PreferenceKey>(
        _ key: K.Type,
        perform action: @escaping (K.Value) -> Void
    ) {
        PreferenceRegistry.shared.onPreferenceChange(key, for: self, handler: action)
    }
}

