import Foundation

/// Protocol for preference keys
public protocol PreferenceKey {
    associatedtype Value
    static var defaultValue: Value { get }
    static func reduce(value: inout Value, nextValue: () -> Value)
}

