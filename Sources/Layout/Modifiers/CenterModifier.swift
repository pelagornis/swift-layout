import UIKit

/// Modifier for centering views horizontally and/or vertically.
///
/// Use ``CenterModifier`` to center a view within the available bounds
/// along one or both axes.
public struct CenterModifier: LayoutModifier {
    /// Whether to center horizontally
    public let horizontal: Bool
    
    /// Whether to center vertically
    public let vertical: Bool
    
    /// Creates a center modifier.
    ///
    /// - Parameters:
    ///   - horizontal: Whether to center horizontally
    ///   - vertical: Whether to center vertically
    public init(horizontal: Bool, vertical: Bool) {
        self.horizontal = horizontal
        self.vertical = vertical
    }
    
    public func apply(to frame: CGRect, in bounds: CGRect) -> CGRect {
        var newFrame = frame
        if horizontal {
            newFrame.origin.x = (bounds.width - frame.width) / 2
        }
        if vertical {
            newFrame.origin.y = (bounds.height - frame.height) / 2
        }
        return newFrame
    }
}
