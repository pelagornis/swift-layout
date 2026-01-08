import Foundation

/// Protocol for defining environment keys
public protocol EnvironmentKey {
    associatedtype Value
    static var defaultValue: Value { get }
}
