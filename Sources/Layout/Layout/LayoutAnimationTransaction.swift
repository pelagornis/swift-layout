import Foundation

/// Transaction for layout updates with animation
///
/// `LayoutAnimationTransaction` manages animation state during layout updates, ensuring
/// that UIKit animations are not overwritten by layout passes.
///
/// ## Overview
///
/// The layout engine needs to know when animations are active so it can:
/// - Apply frames with animation instead of immediately
/// - Prevent frame overwrites during animation
/// - Coordinate with UIKit's animation system
///
/// ## Example
///
/// ```swift
/// withLayoutAnimationTransaction(animation: .spring()) {
///     layoutContainer.updateBody { self.body }
///     // Layout engine will animate frame changes
/// }
/// ```
@MainActor
public struct LayoutAnimationTransaction {
    /// The animation to use for layout changes
    public let animation: LayoutAnimation?
    
    /// Whether this transaction is currently active
    public let isActive: Bool
    
    /// Creates a new layout animation transaction
    public init(animation: LayoutAnimation? = nil, isActive: Bool = true) {
        self.animation = animation
        self.isActive = isActive
    }
    
    /// Storage for current transaction (thread-safe via @MainActor)
    private static var _currentTransaction: LayoutAnimationTransaction?
    
    /// The current active transaction (if any)
    /// This is thread-safe because all layout operations are on @MainActor
    public static var current: LayoutAnimationTransaction? {
        get {
            return _currentTransaction
        }
        set {
            _currentTransaction = newValue
        }
    }
}

/// Executes a block within a layout animation transaction
///
/// This function sets up a layout animation transaction for the duration of the block,
/// allowing the layout engine to coordinate animations properly.
///
/// - Parameters:
///   - animation: The animation to use for layout changes (nil for no animation)
///   - body: The block to execute within the transaction
/// - Returns: The result of the block
///
/// ## Example
///
/// ```swift
/// withLayoutAnimationTransaction(animation: .spring()) {
///     layoutContainer.updateBody { self.body }
/// }
/// ```
@MainActor
public func withLayoutAnimationTransaction<T>(
    animation: LayoutAnimation? = nil,
    _ body: () -> T
) -> T {
    let oldTransaction = LayoutAnimationTransaction.current
    LayoutAnimationTransaction.current = LayoutAnimationTransaction(animation: animation, isActive: true)
    defer {
        LayoutAnimationTransaction.current = oldTransaction
    }
    return body()
}
