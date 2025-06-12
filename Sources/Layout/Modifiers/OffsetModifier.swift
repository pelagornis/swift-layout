#if canImport(UIKit)
import UIKit
#endif

/// Modifier for applying offset transformations.
///
/// Use ``OffsetModifier`` to move a view by specific x and y amounts
/// from its calculated position.
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
