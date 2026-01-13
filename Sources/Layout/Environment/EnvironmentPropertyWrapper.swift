#if canImport(UIKit)
import UIKit

#endif
/// Property wrapper to read environment values
@MainActor
@propertyWrapper
public struct Environment<Value> {
    private let keyPath: KeyPath<EnvironmentValues, Value>
    private weak var view: UIView?
    
    public var wrappedValue: Value {
        guard let view = view else {
            return EnvironmentProvider.shared.rootEnvironment[keyPath: keyPath]
        }
        return view.environment[keyPath: keyPath]
    }
    
    public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
        self.keyPath = keyPath
    }
    
    /// Binds the environment to a specific view
    public mutating func bind(to view: UIView) {
        self.view = view
    }
}

/// Property wrapper to access environment objects
@MainActor
@propertyWrapper
public struct EnvironmentObjectWrapper<T: EnvironmentObject> {
    public var wrappedValue: T? {
        return EnvironmentProvider.shared.object(of: T.self)
    }
    
    public init() {}
}
