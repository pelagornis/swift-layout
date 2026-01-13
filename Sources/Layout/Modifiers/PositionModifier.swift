import CoreGraphics
/// Modifier for setting explicit position coordinates.
///
/// Use ``PositionModifier`` to place a view at specific x and y coordinates
/// within the layout bounds.
///
/// ## Overview
///
/// `PositionModifier` allows you to explicitly set the position of a view
/// using absolute coordinates. This is useful for precise positioning
/// when you need exact control over view placement.
///
/// ## Key Features
///
/// - **Flexible Positioning**: Set x, y, or both coordinates independently
/// - **Absolute Coordinates**: Uses absolute positioning within bounds
/// - **Chainable**: Can be combined with other modifiers
/// - **Bounds Respect**: Coordinates are relative to the layout bounds
///
/// ## Example Usage
///
/// ```swift
/// closeButton.layout()
///     .size(width: 44, height: 44)
///     .position(x: 300, y: 20)
///
/// badge.layout()
///     .position(x: 280, y: 10)
///     .size(width: 20, height: 20)
/// ```
public struct PositionModifier: LayoutModifier {
    /// Optional x coordinate
    public let x: CGFloat?
    
    /// Optional y coordinate
    public let y: CGFloat?
    
    /// Creates a position modifier.
    ///
    /// - Parameters:
    ///   - x: Optional x coordinate, `nil` to keep current x position
    ///   - y: Optional y coordinate, `nil` to keep current y position
    public init(x: CGFloat? = nil, y: CGFloat? = nil) {
        self.x = x
        self.y = y
    }
    
    public func apply(to frame: CGRect, in bounds: CGRect) -> CGRect {
        var newFrame = frame
        if let x = x { newFrame.origin.x = x }
        if let y = y { newFrame.origin.y = y }
        return newFrame
    }
}
