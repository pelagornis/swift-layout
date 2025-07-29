import UIKit

/// Modifier for adding padding around views.
///
/// Use ``PaddingModifier`` to add space around a view, similar to SwiftUI's `.padding()`.
public struct PaddingModifier: LayoutModifier {
    /// The padding insets to apply
    public let insets: UIEdgeInsets
    
    /// Creates a padding modifier.
    ///
    /// - Parameter insets: The padding insets to apply
    public init(insets: UIEdgeInsets) {
        self.insets = insets
    }
    
    public func apply(to frame: CGRect, in bounds: CGRect) -> CGRect {
        var newFrame = frame
        newFrame.origin.x += insets.left
        newFrame.origin.y += insets.top
        newFrame.size.width -= (insets.left + insets.right)
        newFrame.size.height -= (insets.top + insets.bottom)
        return newFrame
    }
} 