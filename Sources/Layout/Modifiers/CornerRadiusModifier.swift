import UIKit

/// A modifier that applies corner radius to a view.
///
/// ``CornerRadiusModifier`` applies corner radius to a view's layer,
/// similar to SwiftUI's `.cornerRadius()` modifier.
///
/// ## Example Usage
///
/// ```swift
/// myView.layout()
///     .cornerRadius(12)
///     .size(width: 200, height: 100)
/// ```
public struct CornerRadiusModifier: LayoutModifier {
    public let radius: CGFloat
    
    public init(radius: CGFloat) {
        self.radius = radius
    }
    
    public func apply(to frame: CGRect, in bounds: CGRect) -> CGRect {
        return frame
    }
} 