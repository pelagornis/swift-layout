import UIKit

/// Provides environment values to child layouts
@MainActor
public final class EnvironmentProvider {
    /// The shared environment provider
    public static let shared = EnvironmentProvider()
    
    /// Root environment values
    private(set) public var rootEnvironment: EnvironmentValues
    
    /// View-specific environments
    private var viewEnvironments: [ObjectIdentifier: EnvironmentValues] = [:]
    
    /// Environment objects
    private var environmentObjects: [ObjectIdentifier: Any] = [:]
    
    private init() {
        rootEnvironment = EnvironmentValues()
        setupSystemEnvironment()
    }
    
    private func setupSystemEnvironment() {
        rootEnvironment.colorScheme = ColorScheme.current
        rootEnvironment.layoutDirection = LayoutDirection.current
        rootEnvironment.contentSizeCategory = UIApplication.shared.preferredContentSizeCategory
    }
    
    /// Gets the environment for a specific view
    public func environment(for view: UIView) -> EnvironmentValues {
        let id = ObjectIdentifier(view)
        
        if let env = viewEnvironments[id] {
            return env
        }
        
        let parentEnv: EnvironmentValues
        if let superview = view.superview {
            parentEnv = environment(for: superview)
        } else {
            parentEnv = rootEnvironment
        }
        
        let env = parentEnv.makeChild()
        viewEnvironments[id] = env
        return env
    }
    
    /// Sets environment values for a view
    public func setEnvironment(_ environment: EnvironmentValues, for view: UIView) {
        viewEnvironments[ObjectIdentifier(view)] = environment
    }
    
    /// Removes environment for a view
    public func removeEnvironment(for view: UIView) {
        viewEnvironments.removeValue(forKey: ObjectIdentifier(view))
    }
    
    /// Registers an environment object
    public func setObject<T: EnvironmentObject>(_ object: T) {
        let key = ObjectIdentifier(T.self)
        if let existing = environmentObjects[key] as? T {
            existing.willRemoveFromEnvironment()
        }
        environmentObjects[key] = object
        object.didInsertIntoEnvironment()
    }
    
    /// Gets an environment object
    public func object<T: EnvironmentObject>(of type: T.Type) -> T? {
        return environmentObjects[ObjectIdentifier(type)] as? T
    }
    
    /// Removes an environment object
    public func removeObject<T: EnvironmentObject>(of type: T.Type) {
        let key = ObjectIdentifier(type)
        if let object = environmentObjects[key] as? T {
            object.willRemoveFromEnvironment()
        }
        environmentObjects.removeValue(forKey: key)
    }
    
    /// Updates the system environment values
    public func updateSystemEnvironment() {
        rootEnvironment.colorScheme = ColorScheme.current
        rootEnvironment.layoutDirection = LayoutDirection.current
        rootEnvironment.contentSizeCategory = UIApplication.shared.preferredContentSizeCategory
    }
}
