#if canImport(UIKit)
import UIKit

#endif
/// Protocol for layouts that support caching
@MainActor
public protocol CacheableLayout: Layout {
    /// Computes a hash representing the current content state
    var contentHash: Int { get }
    
    /// Whether this layout should be cached
    var shouldCache: Bool { get }
}

extension CacheableLayout {
    public var shouldCache: Bool { true }
}

/// A layout that caches its calculations
@MainActor
public struct CachedLayout<Base: Layout>: Layout {
    public typealias Body = Never
    
    public var body: Never {
        fatalError("CachedLayout is a primitive layout")
    }
    
    private let base: Base
    private let cacheKey: Int
    private let viewCache: ViewLayoutCache?
    
    public init(_ base: Base, cacheKey: Int = 0) {
        self.base = base
        self.cacheKey = cacheKey
        self.viewCache = nil
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        let key = LayoutCacheKey(bounds: bounds, contentHash: cacheKey)
        
        if let cached = LayoutCache.shared.get(key) {
            return cached
        }
        
        let result = base.calculateLayout(in: bounds)
        LayoutCache.shared.set(result, for: key)
        
        return result
    }
    
    public func extractViews() -> [UIView] {
        return base.extractViews()
    }
    
    public var intrinsicContentSize: CGSize {
        return base.intrinsicContentSize
    }
}

// MARK: - Layout Extension for Caching

extension Layout {
    /// Wraps the layout with caching
    public func cached(key: Int = 0) -> CachedLayout<Self> {
        return CachedLayout(self, cacheKey: key)
    }
}

