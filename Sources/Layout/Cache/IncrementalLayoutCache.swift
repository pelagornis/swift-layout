#if canImport(UIKit)
import UIKit

#endif
/// Cache for incremental layout updates
@MainActor
public final class IncrementalLayoutCache {
    /// Stored frame calculations for each view
    private var storedFrames: [ObjectIdentifier: CGRect] = [:]
    
    /// Views that have been modified
    private var modifiedViews: Set<ObjectIdentifier> = []
    
    /// Gets the stored frame for a view
    public func getFrame(for view: UIView) -> CGRect? {
        return storedFrames[ObjectIdentifier(view)]
    }
    
    /// Stores a frame for a view
    public func setFrame(_ frame: CGRect, for view: UIView) {
        storedFrames[ObjectIdentifier(view)] = frame
    }
    
    /// Marks a view as modified
    public func markModified(_ view: UIView) {
        modifiedViews.insert(ObjectIdentifier(view))
    }
    
    /// Checks if a view was modified
    public func isModified(_ view: UIView) -> Bool {
        return modifiedViews.contains(ObjectIdentifier(view))
    }
    
    /// Clears modification marks
    public func clearModifications() {
        modifiedViews.removeAll()
    }
    
    /// Removes a view from the cache
    public func remove(_ view: UIView) {
        let id = ObjectIdentifier(view)
        storedFrames.removeValue(forKey: id)
        modifiedViews.remove(id)
    }
    
    /// Clears all cached data
    public func clear() {
        storedFrames.removeAll()
        modifiedViews.removeAll()
    }
}

