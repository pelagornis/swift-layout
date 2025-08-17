import UIKit

/// Modifier for setting explicit width and height values.
///
/// Use ``SizeModifier`` to set specific dimensions for a view, overriding
/// its intrinsic content size.
///
/// ## Overview
///
/// `SizeModifier` allows you to explicitly set the width and height of a view,
/// overriding its natural intrinsic content size. This is useful when you need
/// precise control over view dimensions.
///
/// ## Key Features
///
/// - **Flexible Sizing**: Set width, height, or both independently
/// - **Intrinsic Override**: Overrides the view's natural size
/// - **Chainable**: Can be combined with other modifiers
/// - **Bounds Respect**: Respects container bounds when applying size
///
/// ## Example Usage
///
/// ```swift
/// titleLabel.layout()
///     .size(width: 200, height: 44)
///     .centerX()
///
/// button.layout()
///     .size(width: 120) // Only width specified
///     .center()
/// ```
public struct SizeModifier: LayoutModifier {
    /// Optional width override
    public let width: CGFloat?
    
    /// Optional height override
    public let height: CGFloat?
    
    /// Creates a size modifier.
    ///
    /// - Parameters:
    ///   - width: Optional width to set, `nil` to keep current width
    ///   - height: Optional height to set, `nil` to keep current height
    public init(width: CGFloat? = nil, height: CGFloat? = nil) {
        self.width = width
        self.height = height
    }
    
    public func apply(to frame: CGRect, in bounds: CGRect) -> CGRect {
        var newFrame = frame
        if let width = width { newFrame.size.width = width }
        if let height = height { newFrame.size.height = height }
        return newFrame
    }
}
