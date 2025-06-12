#if canImport(UIKit)
import UIKit
#endif

/// Modifier for setting explicit position coordinates.
///
/// Use ``PositionModifier`` to place a view at specific x and y coordinates
/// within the layout bounds.
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
