import CoreGraphics
/// Result of placement phase
///
/// `PlacementResult` contains the final positions of all views after the
/// placement phase. This is separate from measurement, allowing placement
/// to be recalculated without remeasuring.
///
/// ## Overview
///
/// The placement phase determines "where should each view be positioned?"
/// using previously measured sizes. This separation allows:
/// - Reusing measurements when only positions change
/// - Efficient animation (only positions change, not sizes)
/// - Partial updates (only affected subtrees)
///
/// ## Example
///
/// ```swift
/// func place(
///     at origin: CGPoint,
///     size: CGSize,
///     measuredSizes: [LayoutID: MeasuredSize]
/// ) -> PlacementResult {
///     var frames: [LayoutID: CGRect] = [:]
///
///     for child in children {
///         guard let childSize = measuredSizes[child.id]?.size else { continue }
///         frames[child.id] = CGRect(
///             x: origin.x,
///             y: origin.y,
///             width: childSize.width,
///             height: childSize.height
///         )
///     }
///
///     return PlacementResult(
///         frames: frames,
///         totalSize: size,
///         preferences: collectPreferences()
///     )
/// }
/// ```
@MainActor
public struct PlacementResult {
    /// Frame for each view (by LayoutID)
    public let frames: [AnyHashable: CGRect]
    
    /// Total size occupied
    public let totalSize: CGSize
    
    /// Preferences collected from children
    public let preferences: [ObjectIdentifier: Any]
    
    /// Creates a new placement result
    ///
    /// - Parameters:
    ///   - frames: Dictionary mapping layout IDs to frames
    ///   - totalSize: Total size occupied
    ///   - preferences: Preferences collected from children (defaults to empty)
    public init(
        frames: [AnyHashable: CGRect] = [:],
        totalSize: CGSize = .zero,
        preferences: [ObjectIdentifier: Any] = [:]
    ) {
        self.frames = frames
        self.totalSize = totalSize
        self.preferences = preferences
    }
    
    /// Creates an empty placement result
    public static var empty: PlacementResult {
        PlacementResult()
    }
}
