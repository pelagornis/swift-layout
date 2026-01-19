import UIKit

/// Tracks dirty regions for optimized partial layout updates
@MainActor
public final class DirtyRegionTracker {
    /// The dirty region that needs to be re-laid out
    private(set) public var dirtyRect: CGRect = .null
    
    /// Whether the entire layout is dirty
    private(set) public var isFullyDirty: Bool = false
    
    /// Marks a region as dirty
    public func markDirty(_ rect: CGRect) {
        if dirtyRect.isNull {
            dirtyRect = rect
        } else {
            dirtyRect = dirtyRect.union(rect)
        }
    }
    
    /// Marks the entire layout as dirty
    public func markFullyDirty() {
        isFullyDirty = true
    }
    
    /// Clears all dirty regions
    public func clear() {
        dirtyRect = .null
        isFullyDirty = false
    }
    
    /// Checks if a rect intersects with the dirty region
    public func needsLayout(in rect: CGRect) -> Bool {
        return isFullyDirty || dirtyRect.intersects(rect)
    }
}

// MARK: - UIView Extension for Invalidation

extension UIView {
    private static var invalidationContextKey: UInt8 = 0
    
    /// The dirty region tracker for this view
    public var dirtyRegionTracker: DirtyRegionTracker {
        if let tracker = objc_getAssociatedObject(self, &Self.invalidationContextKey) as? DirtyRegionTracker {
            return tracker
        }
        let tracker = DirtyRegionTracker()
        objc_setAssociatedObject(self, &Self.invalidationContextKey, tracker, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return tracker
    }
    
    /// Invalidates the layout with a specific reason
    public func invalidateLayout(reason: InvalidationReason = .explicit) {
        LayoutInvalidationContext.shared.invalidate(self, reason: reason)
        setNeedsLayout()
    }
    
    /// Invalidates a specific region of the layout
    public func invalidateLayout(in rect: CGRect, reason: InvalidationReason = .explicit) {
        dirtyRegionTracker.markDirty(rect)
        invalidateLayout(reason: reason)
    }
}

