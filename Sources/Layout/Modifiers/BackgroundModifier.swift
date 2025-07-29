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
public struct BackgroundModifier: LayoutModifier {
    public let color: UIColor
    
    public init(color: UIColor) {
        self.color = color
    }
    
    public func apply(to frame: CGRect, in bounds: CGRect) -> CGRect {
        // Background color는 프레임에 영향을 주지 않으므로 프레임은 그대로 반환
        // 실제 background color는 ViewLayout에서 적용
        return frame
    }
} 