import Foundation

/// Defines rules for when and how layout should be invalidated
/// This provides clear invalidation rules to prevent unnecessary layout passes
public struct LayoutInvalidationRules: Sendable {
    /// Default invalidation rules
    public static let `default` = LayoutInvalidationRules()
    
    /// Determines if a layout should be invalidated based on the reason
    /// - Parameter reason: The reason for invalidation
    /// - Returns: `true` if layout should be invalidated, `false` otherwise
    public func shouldInvalidate(for reason: InvalidationReason) -> Bool {
        switch reason {
        case .contentChanged, .sizeChanged, .hierarchyChanged, .environmentChanged, .explicit, .geometryChanged:
            return true
        case .animation:
            // Animations might not always require a full layout pass
            return false
        }
    }
    
    /// Determines the priority of an invalidation reason
    /// Higher priority reasons might trigger more immediate layout updates
    /// - Parameter reason: The reason for invalidation
    /// - Returns: An integer representing the priority (higher = more urgent)
    public func priority(for reason: InvalidationReason) -> Int {
        switch reason {
        case .hierarchyChanged: return 4 // Hierarchy changes are critical
        case .sizeChanged: return 3
        case .contentChanged: return 2
        case .environmentChanged: return 1
        case .geometryChanged: return 1
        case .explicit: return 1
        case .animation: return 0 // Handled by animation engine
        }
    }
    
    /// Checks if multiple reasons should be batched together
    /// - Parameters:
    ///   - reason1: First invalidation reason
    ///   - reason2: Second invalidation reason
    /// - Returns: `true` if reasons can be batched, `false` otherwise
    public func canBatch(_ reason1: InvalidationReason, with reason2: InvalidationReason) -> Bool {
        // Hierarchy changes should not be batched
        if reason1 == .hierarchyChanged || reason2 == .hierarchyChanged {
            return false
        }
        // Size changes should not be batched with content changes
        if (reason1 == .sizeChanged && reason2 == .contentChanged) ||
           (reason1 == .contentChanged && reason2 == .sizeChanged) {
            return false
        }
        return true
    }
}

