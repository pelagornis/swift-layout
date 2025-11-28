import UIKit

/// High-performance layout cache using LRU eviction
@MainActor
public final class LayoutCache {
    /// Shared instance
    public static let shared = LayoutCache()
    
    /// Maximum number of cached entries
    public var maxCacheSize: Int = 100 {
        didSet {
            evictIfNeeded()
        }
    }
    
    /// Cache time-to-live in seconds
    public var cacheTTL: TimeInterval = 60
    
    /// Whether caching is enabled
    public var isEnabled: Bool = true
    
    /// Cache storage
    private var cache: [LayoutCacheKey: CachedLayoutResult] = [:]
    
    /// Order of cache entries for LRU eviction
    private var accessOrder: [LayoutCacheKey] = []
    
    /// Cache statistics
    private(set) public var cacheHits: Int = 0
    private(set) public var cacheMisses: Int = 0
    
    private init() {}
    
    /// Gets a cached layout result
    public func get(_ key: LayoutCacheKey) -> LayoutResult? {
        guard isEnabled else { return nil }
        
        guard let cached = cache[key] else {
            cacheMisses += 1
            return nil
        }
        
        if Date().timeIntervalSince(cached.timestamp) > cacheTTL {
            cache.removeValue(forKey: key)
            accessOrder.removeAll { $0 == key }
            cacheMisses += 1
            return nil
        }
        
        if let index = accessOrder.firstIndex(of: key) {
            accessOrder.remove(at: index)
        }
        accessOrder.append(key)
        
        cache[key] = cached.incrementHitCount()
        
        cacheHits += 1
        return cached.result
    }
    
    /// Stores a layout result in the cache
    public func set(_ result: LayoutResult, for key: LayoutCacheKey) {
        guard isEnabled else { return }
        
        cache[key] = CachedLayoutResult(result: result)
        accessOrder.append(key)
        
        evictIfNeeded()
    }
    
    /// Invalidates a specific cache entry
    public func invalidate(_ key: LayoutCacheKey) {
        cache.removeValue(forKey: key)
        accessOrder.removeAll { $0 == key }
    }
    
    /// Invalidates all cache entries matching a predicate
    public func invalidate(where predicate: (LayoutCacheKey) -> Bool) {
        let keysToRemove = cache.keys.filter(predicate)
        for key in keysToRemove {
            cache.removeValue(forKey: key)
        }
        accessOrder.removeAll { predicate($0) }
    }
    
    /// Clears all cached entries
    public func clearAll() {
        cache.removeAll()
        accessOrder.removeAll()
    }
    
    /// Resets statistics
    public func resetStatistics() {
        cacheHits = 0
        cacheMisses = 0
    }
    
    /// Gets the cache hit rate
    public var hitRate: Double {
        let total = cacheHits + cacheMisses
        return total > 0 ? Double(cacheHits) / Double(total) : 0
    }
    
    /// Gets the current cache size
    public var currentSize: Int {
        return cache.count
    }
    
    private func evictIfNeeded() {
        while cache.count > maxCacheSize && !accessOrder.isEmpty {
            let keyToRemove = accessOrder.removeFirst()
            cache.removeValue(forKey: keyToRemove)
        }
    }
}

