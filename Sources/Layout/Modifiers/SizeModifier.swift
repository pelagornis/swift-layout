#if canImport(UIKit)
import UIKit
#endif

/// Modifier for setting explicit width and height values.
///
/// Use ``SizeModifier`` to set specific dimensions for a view, overriding
/// its intrinsic content size.
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
