#if canImport(UIKit)
import UIKit

#endif
/// A token that automatically invalidates layout when properties change
@MainActor
@propertyWrapper
public struct LayoutInvalidating<Value: Equatable> {
    private var storage: Value
    private weak var container: UIView?
    private let reason: InvalidationReason
    
    public var wrappedValue: Value {
        get { storage }
        set {
            guard storage != newValue else { return }
            storage = newValue
            if let container = container {
                LayoutInvalidationContext.shared.invalidate(container, reason: reason)
                container.setNeedsLayout()
            }
        }
    }
    
    public init(wrappedValue: Value, reason: InvalidationReason = .contentChanged) {
        self.storage = wrappedValue
        self.reason = reason
    }
    
    /// Sets the container view for invalidation notifications
    public mutating func setContainer(_ view: UIView) {
        self.container = view
    }
}

