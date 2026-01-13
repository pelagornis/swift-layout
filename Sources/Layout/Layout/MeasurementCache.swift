import Foundation
/// Cache for measurement results
///
/// `MeasurementCache` stores measured sizes by proposal, allowing efficient
/// reuse of measurement results when only placement changes.
///
/// ## Overview
///
/// The cache:
/// - Stores measurements by `SizeProposal`
/// - Invalidates based on `cacheKey` from `MeasuredSize`
/// - Provides efficient lookup and storage
///
/// ## Example
///
/// ```swift
/// var cache = MeasurementCache()
///
/// // First measurement
/// let proposal = SizeProposal.atMost(width: 300, height: nil)
/// let measured = node.measure(proposal)
/// cache.store(measured, for: proposal)
///
/// // Later, reuse cached measurement
/// if let cached = cache.get(for: proposal, cacheKey: currentCacheKey) {
///     return cached
/// }
/// ```
@MainActor
public struct MeasurementCache {
    /// Storage for cached measurements
    private var storage: [SizeProposal: MeasuredSize] = [:]
    
    /// Creates an empty cache
    public init() {}
    
    /// Gets a cached measurement if available and valid
    ///
    /// - Parameters:
    ///   - proposal: The size proposal to look up
    ///   - cacheKey: The current cache key (for invalidation)
    /// - Returns: Cached measurement if available and valid, nil otherwise
    public func get(for proposal: SizeProposal, cacheKey: Int) -> MeasuredSize? {
        guard let cached = storage[proposal] else {
            return nil
        }
        
        // Check if cache key matches (content hasn't changed)
        guard cached.cacheKey == cacheKey else {
            return nil
        }
        
        return cached
    }
    
    /// Stores a measurement in the cache
    ///
    /// - Parameters:
    ///   - measured: The measured size to cache
    ///   - proposal: The size proposal this measurement is for
    public mutating func store(_ measured: MeasuredSize, for proposal: SizeProposal) {
        storage[proposal] = measured
    }
    
    /// Invalidates all cached measurements
    public mutating func invalidateAll() {
        storage.removeAll()
    }
    
    /// Invalidates measurements for a specific proposal
    ///
    /// - Parameter proposal: The proposal to invalidate
    public mutating func invalidate(for proposal: SizeProposal) {
        storage.removeValue(forKey: proposal)
    }
    
    /// Invalidates measurements that don't match the given cache key
    ///
    /// - Parameter cacheKey: The valid cache key
    public mutating func invalidate(except cacheKey: Int) {
        storage = storage.filter { $0.value.cacheKey == cacheKey }
    }
    
    /// Clears the cache
    public mutating func clear() {
        storage.removeAll()
    }
    
    /// Gets the number of cached measurements
    public var count: Int {
        storage.count
    }
}
