import UIKit

/// Protocol for layout nodes that separate measurement from placement
///
/// `NewLayoutNode` is the improved version of the layout system that separates
/// measurement (size calculation) from placement (position calculation). This
/// enables:
/// - Measurement result caching
/// - Partial invalidation
/// - Efficient diffing
/// - Animation stability
///
/// ## Overview
///
/// Unlike the current `Layout` protocol which combines measurement and placement
/// in `calculateLayout(in:)`, `NewLayoutNode` separates these concerns:
/// - `measure(_:)`: Calculate size given a proposal (can be cached)
/// - `place(at:size:measuredSizes:)`: Place children at positions (uses cached measurements)
///
/// ## Example
///
/// ```swift
/// struct VStackNode: NewLayoutNode {
///     let id: LayoutID
///     let spacing: CGFloat
///     let children: [LayoutElement]
///
///     func measure(_ proposal: SizeProposal) -> MeasuredSize {
///         // Calculate total size needed
///         var totalHeight: CGFloat = 0
///         for child in children {
///             let childSize = child.node.measure(proposal)
///             totalHeight += childSize.size.height + spacing
///         }
///         return MeasuredSize(size: CGSize(width: proposal.maxSize?.width ?? 0, height: totalHeight))
///     }
///
///     func place(at origin: CGPoint, size: CGSize, measuredSizes: [LayoutID: MeasuredSize]) -> PlacementResult {
///         // Position children using cached measurements
///         var frames: [LayoutID: CGRect] = [:]
///         var currentY = origin.y
///         for child in children {
///             guard let childSize = measuredSizes[child.id]?.size else { continue }
///             frames[child.id] = CGRect(x: origin.x, y: currentY, width: childSize.width, height: childSize.height)
///             currentY += childSize.height + spacing
///         }
///         return PlacementResult(frames: frames, totalSize: size)
///     }
/// }
/// ```
@MainActor
public protocol NewLayoutNode {
    /// Unique identifier for this node
    var id: LayoutID { get }
    
    /// MEASURE PHASE: Calculate size given a proposal
    ///
    /// This method is called during the measurement phase to determine how much
    /// space this node wants to occupy. The result can be cached and reused
    /// across multiple placement calculations.
    ///
    /// - Parameter proposal: Size constraints from parent
    /// - Returns: Measured size that this node wants to occupy
    func measure(_ proposal: SizeProposal) -> MeasuredSize
    
    /// PLACE PHASE: Place children at specific positions
    ///
    /// This method is called during the placement phase to determine where each
    /// child should be positioned. It uses previously measured sizes, allowing
    /// placement to be recalculated without remeasuring.
    ///
    /// - Parameters:
    ///   - origin: Origin point for this node
    ///   - size: Size allocated to this node
    ///   - measuredSizes: Previously measured sizes for all children (by LayoutID)
    /// - Returns: Placement result with frames for all views
    func place(
        at origin: CGPoint,
        size: CGSize,
        measuredSizes: [LayoutID: MeasuredSize]
    ) -> PlacementResult
    
    /// Invalidate this node with a specific reason
    ///
    /// This method is called when the node needs to be recalculated. The reason
    /// allows the node to perform more efficient updates by only recalculating
    /// what's necessary.
    ///
    /// - Parameter reason: Reason for invalidation
    func invalidate(_ reason: LayoutInvalidationReason)
    
    /// Collect preferences from children
    ///
    /// This method collects preference values from children and reduces them
    /// according to the preference key's reduce function.
    ///
    /// - Returns: Dictionary of preference keys to values
    func collectPreferences() -> [ObjectIdentifier: Any]
}

// Default implementations
extension NewLayoutNode {
    /// Default implementation: no preferences
    public func collectPreferences() -> [ObjectIdentifier: Any] {
        return [:]
    }
    
    /// Default implementation: no-op invalidation
    public func invalidate(_ reason: LayoutInvalidationReason) {
        // Subclasses can override to handle invalidation
    }
}
