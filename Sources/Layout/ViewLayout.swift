import UIKit
/// A wrapper that provides layout functionality for UIViews with chainable modifiers.
///
/// ``ViewLayout`` wraps a UIView and provides a fluent interface for applying
/// layout modifiers. It calculates the final frame by applying all modifiers
/// in sequence to the view's intrinsic content size.
///
/// ## Example Usage
///
/// ```swift
/// titleLabel.layout()
///     .size(width: 200, height: 44)
///     .centerX()
///     .offset(y: 20)
/// ```
public struct ViewLayout: @preconcurrency Layout {
    public typealias Body = Never
    
    public var body: Never {
        neverLayout("ViewLayout")
    }
    
    /// The wrapped UIView
    public let view: UIView
    
    /// Array of modifiers to apply during layout calculation
    public var modifiers: [LayoutModifier] = []
    
    /// Creates a view layout wrapper.
    ///
    /// - Parameter view: The UIView to wrap
    public init(_ view: UIView) {
        self.view = view
    }
    
    @MainActor public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        let intrinsicSize = view.intrinsicContentSize
        let defaultSize = CGSize(
            width: intrinsicSize.width == UIView.noIntrinsicMetric ? 100 : intrinsicSize.width,
            height: intrinsicSize.height == UIView.noIntrinsicMetric ? 30 : intrinsicSize.height
        )
        
        var frame = CGRect(origin: .zero, size: defaultSize)
        
        // Apply modifiers in sequence
        for modifier in modifiers {
            frame = modifier.apply(to: frame, in: bounds)
        }
        
        return LayoutResult(frames: [view: frame], totalSize: frame.size)
    }
    
    public func extractViews() -> [UIView] {
        return [view]
    }
    
    // MARK: - Size Modifiers
    
    /// Sets the width and/or height of the view.
    ///
    /// - Parameters:
    ///   - width: Optional width to set
    ///   - height: Optional height to set
    /// - Returns: A new ``ViewLayout`` with the size modifier applied
    public func size(width: CGFloat? = nil, height: CGFloat? = nil) -> ViewLayout {
        var copy = self
        copy.modifiers.append(SizeModifier(width: width, height: height))
        return copy
    }
    
    /// Sets the size of the view using a CGSize.
    ///
    /// - Parameter size: The size to set
    /// - Returns: A new ``ViewLayout`` with the size modifier applied
    public func size(_ size: CGSize) -> ViewLayout {
        return self.size(width: size.width, height: size.height)
    }
    
    /// Sets the frame dimensions of the view.
    ///
    /// This is an alias for ``size(width:height:)`` for SwiftUI compatibility.
    ///
    /// - Parameters:
    ///   - width: Optional width to set
    ///   - height: Optional height to set
    /// - Returns: A new ``ViewLayout`` with the size modifier applied
    public func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> ViewLayout {
        return size(width: width, height: height)
    }
    
    // MARK: - Position Modifiers
    
    /// Sets the position of the view.
    ///
    /// - Parameters:
    ///   - x: Optional x coordinate
    ///   - y: Optional y coordinate
    /// - Returns: A new ``ViewLayout`` with the position modifier applied
    public func position(x: CGFloat? = nil, y: CGFloat? = nil) -> ViewLayout {
        var copy = self
        copy.modifiers.append(PositionModifier(x: x, y: y))
        return copy
    }
    
    /// Centers the view both horizontally and vertically.
    ///
    /// - Returns: A new ``ViewLayout`` with center alignment applied
    public func center() -> ViewLayout {
        var copy = self
        copy.modifiers.append(CenterModifier(horizontal: true, vertical: true))
        return copy
    }
    
    /// Centers the view horizontally.
    ///
    /// - Returns: A new ``ViewLayout`` with horizontal center alignment applied
    public func centerX() -> ViewLayout {
        var copy = self
        copy.modifiers.append(CenterModifier(horizontal: true, vertical: false))
        return copy
    }
    
    /// Centers the view vertically.
    ///
    /// - Returns: A new ``ViewLayout`` with vertical center alignment applied
    public func centerY() -> ViewLayout {
        var copy = self
        copy.modifiers.append(CenterModifier(horizontal: false, vertical: true))
        return copy
    }
    
    /// Offsets the view by the specified amounts.
    ///
    /// - Parameters:
    ///   - x: Horizontal offset amount (default: 0)
    ///   - y: Vertical offset amount (default: 0)
    /// - Returns: A new ``ViewLayout`` with the offset modifier applied
    public func offset(x: CGFloat = 0, y: CGFloat = 0) -> ViewLayout {
        var copy = self
        copy.modifiers.append(OffsetModifier(x: x, y: y))
        return copy
    }
    
    /// Constrains the view to a specific aspect ratio.
    ///
    /// - Parameters:
    ///   - ratio: The desired aspect ratio (width / height)
    ///   - contentMode: How to apply the aspect ratio (default: .fit)
    /// - Returns: A new ``ViewLayout`` with the aspect ratio modifier applied
    public func aspectRatio(_ ratio: CGFloat, contentMode: AspectRatioModifier.ContentMode = .fit) -> ViewLayout {
        var copy = self
        copy.modifiers.append(AspectRatioModifier(ratio: ratio, contentMode: contentMode))
        return copy
    }
}
