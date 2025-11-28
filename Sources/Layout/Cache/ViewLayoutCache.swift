import UIKit

/// Manages layout cache for a specific view
@MainActor
public final class ViewLayoutCache {
    private weak var view: UIView?
    private var cachedResult: LayoutResult?
    private var cachedBounds: CGRect = .zero
    private var cachedContentHash: Int = 0
    
    public init(view: UIView) {
        self.view = view
    }
    
    /// Gets the cached result if valid
    public func getCachedResult(for bounds: CGRect, contentHash: Int) -> LayoutResult? {
        guard cachedBounds == bounds && cachedContentHash == contentHash else {
            return nil
        }
        return cachedResult
    }
    
    /// Caches a layout result
    public func cache(_ result: LayoutResult, bounds: CGRect, contentHash: Int) {
        cachedResult = result
        cachedBounds = bounds
        cachedContentHash = contentHash
    }
    
    /// Invalidates the cache
    public func invalidate() {
        cachedResult = nil
        cachedBounds = .zero
        cachedContentHash = 0
    }
}

// MARK: - UIView Extension

extension UIView {
    private static var layoutCacheKey: UInt8 = 0
    
    /// The layout cache for this view
    public var layoutCache: ViewLayoutCache {
        if let cache = objc_getAssociatedObject(self, &Self.layoutCacheKey) as? ViewLayoutCache {
            return cache
        }
        let cache = ViewLayoutCache(view: self)
        objc_setAssociatedObject(self, &Self.layoutCacheKey, cache, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return cache
    }
    
    /// Invalidates the layout cache
    public func invalidateLayoutCache() {
        layoutCache.invalidate()
    }
}

