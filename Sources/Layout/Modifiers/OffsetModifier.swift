import CoreGraphics
/// Modifier for applying offset transformations.
///
/// Use ``OffsetModifier`` to move a view by specific x and y amounts
/// from its calculated position.
///
/// ## Overview
///
/// `OffsetModifier` allows you to move a view by a specific amount from
/// its calculated position. This is useful for fine-tuning view placement
/// or creating subtle adjustments to layout positioning.
///
/// ## Key Features
///
/// - **Relative Movement**: Moves view relative to its current position
/// - **Flexible Offsets**: Set x and y offsets independently
/// - **Chainable**: Can be combined with other modifiers
/// - **Non-Destructive**: Doesn't affect the view's size or other properties
///
/// ## Example Usage
///
/// ```swift
/// titleLabel.layout()
///     .centerX()
///     .offset(y: -20) // Move up by 20 points
///
/// iconView.layout()
///     .offset(x: 10, y: 5) // Move right and down
/// ```
public struct OffsetModifier: LayoutModifier {
    /// Horizontal offset amount
    public let x: CGFloat
    
    /// Vertical offset amount
    public let y: CGFloat
    
    /// Creates an offset modifier.
    ///
    /// - Parameters:
    ///   - x: Horizontal offset amount
    ///   - y: Vertical offset amount
    public init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
    
    public func apply(to frame: CGRect, in bounds: CGRect) -> CGRect {
        var newFrame = frame
        newFrame.origin.x += x
        newFrame.origin.y += y
        return newFrame
    }
}
