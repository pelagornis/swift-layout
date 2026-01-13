import Foundation
import CoreGraphics
/// Cache key for layout calculations
public struct LayoutCacheKey: Hashable {
    let bounds: CGRect
    let contentHash: Int
    
    public init(bounds: CGRect, contentHash: Int) {
        self.bounds = bounds
        self.contentHash = contentHash
    }
}

/// Cached layout result with metadata
public struct CachedLayoutResult {
    public let result: LayoutResult
    public let timestamp: Date
    public let hitCount: Int
    
    init(result: LayoutResult, timestamp: Date = Date(), hitCount: Int = 0) {
        self.result = result
        self.timestamp = timestamp
        self.hitCount = hitCount
    }
    
    func incrementHitCount() -> CachedLayoutResult {
        return CachedLayoutResult(result: result, timestamp: timestamp, hitCount: hitCount + 1)
    }
}
