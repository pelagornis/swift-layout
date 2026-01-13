import CoreGraphics
/// Result of measurement phase
///
/// `MeasuredSize` represents the size that a layout node wants to occupy,
/// as determined during the measurement phase. This is separate from placement,
/// allowing measurement results to be cached and reused.
///
/// ## Overview
///
/// The measurement phase determines "how big does this want to be?" while
/// the placement phase determines "where should this be positioned?". By
/// separating these, we can:
/// - Cache measurement results by proposal
/// - Reuse measurements when only placement changes
/// - Perform partial invalidations
///
/// ## Example
///
/// ```swift
/// func measure(_ proposal: SizeProposal) -> MeasuredSize {
///     // Check cache first
///     if let cached = measurementCache[proposal] {
///         return cached
///     }
///
///     // Calculate size
///     let size = calculateSize(for: proposal)
///
///     // Cache and return
///     let measured = MeasuredSize(
///         size: size,
///         baselineOffset: calculateBaseline(),
///         cacheKey: contentHash
///     )
///     measurementCache[proposal] = measured
///     return measured
/// }
/// ```
@MainActor
public struct MeasuredSize: Equatable {
    /// The size that this node wants to occupy
    public let size: CGSize
    
    /// Baseline offset from the top (for text alignment)
    public let baselineOffset: CGFloat?
    
    /// Cache key for invalidation (e.g., content hash)
    public let cacheKey: Int
    
    /// Creates a new measured size
    ///
    /// - Parameters:
    ///   - size: The size that this node wants to occupy
    ///   - baselineOffset: Baseline offset from the top (nil if not applicable)
    ///   - cacheKey: Cache key for invalidation (defaults to 0)
    public init(
        size: CGSize,
        baselineOffset: CGFloat? = nil,
        cacheKey: Int = 0
    ) {
        self.size = size
        self.baselineOffset = baselineOffset
        self.cacheKey = cacheKey
    }
    
    /// Creates a measured size with zero size
    public static var zero: MeasuredSize {
        MeasuredSize(size: .zero)
    }
}
