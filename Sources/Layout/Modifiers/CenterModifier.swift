import UIKit

/// Modifier for centering views horizontally and/or vertically.
///
/// Use ``CenterModifier`` to center a view within the available bounds
/// along one or both axes.
///
/// ## Overview
///
/// `CenterModifier` allows you to center a view within its container bounds.
/// You can center horizontally, vertically, or both, providing flexible
/// centering options for different layout needs.
///
/// ## Key Features
///
/// - **Flexible Centering**: Center horizontally, vertically, or both
/// - **Bounds Aware**: Centers relative to the available bounds
/// - **Size Preserving**: Maintains the view's size while centering
/// - **Chainable**: Can be combined with other modifiers
///
/// ## Example Usage
///
/// ```swift
/// titleLabel.layout()
///     .size(width: 200, height: 44)
///     .center() // Center both horizontally and vertically
///
/// iconView.layout()
///     .size(width: 60, height: 60)
///     .centerX() // Center horizontally only
///
/// button.layout()
///     .centerY() // Center vertically only
/// ```
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
