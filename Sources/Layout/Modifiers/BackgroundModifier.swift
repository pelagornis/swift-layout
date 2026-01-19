import UIKit

/// A modifier that applies background color to a view.
///
/// ``BackgroundModifier`` applies background color to a view,
/// similar to SwiftUI's `.background()` modifier.
///
/// ## Example Usage
///
/// ```swift
/// myView.layout()
///     .background(.systemBlue)
///     .size(width: 200, height: 100)
/// ```
public struct BackgroundModifier: LayoutModifier, @unchecked Sendable {
    public let color: UIColor
    
    public init(color: UIColor) {
        self.color = color
    }
    
    public func apply(to frame: CGRect, in bounds: CGRect) -> CGRect {
        return frame
    }
} 