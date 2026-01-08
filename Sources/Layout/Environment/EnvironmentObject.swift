import Foundation

/// Protocol for objects that can be passed through the environment
@MainActor
public protocol EnvironmentObject: AnyObject {
    /// Called when the object is inserted into the environment
    func didInsertIntoEnvironment()
    
    /// Called when the object is removed from the environment
    func willRemoveFromEnvironment()
}

extension EnvironmentObject {
    public func didInsertIntoEnvironment() {}
    public func willRemoveFromEnvironment() {}
}
