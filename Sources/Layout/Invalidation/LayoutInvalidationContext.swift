import UIKit

/// Manages layout invalidation across the view hierarchy
@MainActor
public final class LayoutInvalidationContext {
    /// Shared instance for global invalidation management
    public static let shared = LayoutInvalidationContext()
    
    /// Set of views that need layout updates
    private var pendingInvalidations: Set<ObjectIdentifier> = []
    
    /// Map of views to their invalidation reasons
    private var invalidationReasons: [ObjectIdentifier: Set<InvalidationReason>] = [:]
    
    /// Whether a layout pass is currently scheduled
    private var isLayoutPassScheduled = false
    
    /// Observers for invalidation events
    private var observers: [ObjectIdentifier: (InvalidationReason) -> Void] = [:]
    
    /// Current transaction for batching invalidations
    private var currentTransaction: LayoutTransaction?
    
    private init() {}
    
    /// Marks a view as needing layout update
    public func invalidate(_ view: UIView, reason: InvalidationReason) {
        let id = ObjectIdentifier(view)
        pendingInvalidations.insert(id)
        
        if invalidationReasons[id] == nil {
            invalidationReasons[id] = []
        }
        invalidationReasons[id]?.insert(reason)
        
        observers[id]?(reason)
        
        if currentTransaction != nil {
            return
        }
        
        scheduleLayoutPassIfNeeded()
    }
    
    /// Begins a batch transaction for multiple invalidations
    public func beginTransaction() -> LayoutTransaction {
        let transaction = LayoutTransaction()
        currentTransaction = transaction
        return transaction
    }
    
    /// Commits the current transaction and schedules layout
    public func commitTransaction(_ transaction: LayoutTransaction) {
        guard currentTransaction === transaction else { return }
        currentTransaction = nil
        scheduleLayoutPassIfNeeded()
    }
    
    /// Adds an observer for invalidation events on a specific view
    public func addObserver(for view: UIView, handler: @escaping (InvalidationReason) -> Void) {
        observers[ObjectIdentifier(view)] = handler
    }
    
    /// Removes the observer for a specific view
    public func removeObserver(for view: UIView) {
        observers.removeValue(forKey: ObjectIdentifier(view))
    }
    
    /// Gets the pending invalidation reasons for a view
    public func pendingReasons(for view: UIView) -> Set<InvalidationReason> {
        return invalidationReasons[ObjectIdentifier(view)] ?? []
    }
    
    /// Clears pending invalidations for a view
    public func clearInvalidation(for view: UIView) {
        let id = ObjectIdentifier(view)
        pendingInvalidations.remove(id)
        invalidationReasons.removeValue(forKey: id)
    }
    
    /// Checks if a view has pending invalidations
    public func hasPendingInvalidation(for view: UIView) -> Bool {
        return pendingInvalidations.contains(ObjectIdentifier(view))
    }
    
    private func scheduleLayoutPassIfNeeded() {
        guard !isLayoutPassScheduled && !pendingInvalidations.isEmpty else { return }
        
        isLayoutPassScheduled = true
        
        DispatchQueue.main.async { [weak self] in
            self?.performLayoutPass()
        }
    }
    
    private func performLayoutPass() {
        isLayoutPassScheduled = false
        pendingInvalidations.removeAll()
        invalidationReasons.removeAll()
    }
}

/// Represents a batch transaction for layout invalidations
@MainActor
public final class LayoutTransaction {
    fileprivate init() {}
}

