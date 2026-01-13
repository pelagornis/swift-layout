#if canImport(UIKit)
import UIKit

#endif
/// Modifier for adding padding around views.
///
/// Use ``PaddingModifier`` to add space around a view, similar to SwiftUI's `.padding()`.
///
/// ## Overview
///
/// `PaddingModifier` adds space around a view by reducing its available area.
/// This is similar to SwiftUI's `.padding()` modifier and is useful for
/// creating visual spacing between views and their containers.
///
/// ## Key Features
///
/// - **Flexible Insets**: Support for different padding on each side
/// - **SwiftUI-like API**: Similar to SwiftUI's padding modifier
/// - **Area Reduction**: Reduces the view's available space
/// - **Chainable**: Can be combined with other modifiers
///
/// ## Example Usage
///
/// ```swift
/// titleLabel.layout()
///     .padding(20) // Add 20pt padding on all sides
///
/// contentView.layout()
///     .padding(.init(top: 10, left: 20, bottom: 10, right: 20))
///
/// button.layout()
///     .padding(.horizontal, 16) // Add horizontal padding only
/// ```
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