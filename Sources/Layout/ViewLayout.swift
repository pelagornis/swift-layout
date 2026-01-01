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
public struct ViewLayout: Layout {
    public typealias Body = Never
    
    public var body: Never {
        neverLayout("ViewLayout")
    }
    
    /// The wrapped UIView
    public let view: UIView
    
    /// Creates a view layout wrapper.
    ///
    /// - Parameter view: The UIView to wrap
    public init(_ view: UIView) {
        self.view = view
    }
    
    /// Gets modifiers from the view's associated object
    /// This prevents creating new ViewLayout instances for each modifier chain
    private var modifiers: [LayoutModifier] {
        return view.layoutModifiers
    }

    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        // PHASE 1: MEASURE - Calculate the size the view wants
        let measuredSize = measureSize(in: bounds)
        
        // PHASE 2: LAYOUT - Calculate the final position
        let finalFrame = layoutFrame(size: measuredSize, in: bounds)
        
        return LayoutResult(frames: [view: finalFrame], totalSize: measuredSize)
    }
    
    /// MEASURE PHASE: Determines the size the view wants
    /// This is separate from placement (layout phase)
    private func measureSize(in bounds: CGRect) -> CGSize {
        // Use default bounds if invalid (width can be 0 while height is available)
        // SwiftUI-style: nil width/height means unconstrained in that dimension
        let proposedWidth: CGFloat? = bounds.width > 0 ? bounds.width : nil
        let proposedHeight: CGFloat? = bounds.height > 0 ? bounds.height : nil
        
        let intrinsicSize = view.intrinsicContentSize
        
        // Calculate more accurate default size
        var defaultSize: CGSize
        
        if intrinsicSize.width == UIView.noIntrinsicMetric || intrinsicSize.height == UIView.noIntrinsicMetric {
            // When intrinsicContentSize is not set
            if let label = view as? UILabel {
                // For UILabel, calculate based on text size
                let maxWidth = proposedWidth ?? CGFloat.greatestFiniteMagnitude
                let textSize = label.text?.size(withAttributes: [.font: label.font ?? UIFont.systemFont(ofSize: 17)]) ?? .zero
                defaultSize = CGSize(
                    width: max(min(textSize.width + 20, maxWidth), 100), // Ensure minimum width
                    height: max(textSize.height + 10, 30) // Ensure minimum height
                )
            } else if let button = view as? UIButton {
                // For UIButton, calculate based on title size
                let maxWidth = proposedWidth ?? CGFloat.greatestFiniteMagnitude
                let titleSize = button.title(for: .normal)?.size(withAttributes: [.font: button.titleLabel?.font ?? UIFont.systemFont(ofSize: 17)]) ?? .zero
                defaultSize = CGSize(
                    width: max(min(titleSize.width + 40, maxWidth), 120), // Ensure minimum width
                    height: max(titleSize.height + 20, 44) // Ensure minimum height
                )
            } else {
                // For other UIViews, use default values or proposed size
                defaultSize = CGSize(
                    width: proposedWidth ?? 100,
                    height: proposedHeight ?? 30
                )
            }
        } else {
            // Use intrinsicContentSize, but respect proposed constraints
            defaultSize = CGSize(
                width: proposedWidth.map { min($0, intrinsicSize.width) } ?? intrinsicSize.width,
                height: proposedHeight.map { min($0, intrinsicSize.height) } ?? intrinsicSize.height
            )
        }
        
        // Apply size modifiers (measure phase)
        var measuredSize = defaultSize
        for modifier in modifiers {
            if let sizeModifier = modifier as? SizeModifier {
                if let width = sizeModifier.width {
                    measuredSize.width = width
                }
                if let height = sizeModifier.height {
                    measuredSize.height = height
                }
            } else if let aspectRatioModifier = modifier as? AspectRatioModifier {
                // Apply aspect ratio during measure
                if measuredSize.width > 0 && measuredSize.height > 0 {
                    let currentRatio = measuredSize.width / measuredSize.height
                    if abs(currentRatio - aspectRatioModifier.ratio) > 0.001 {
                        if measuredSize.width > measuredSize.height {
                            measuredSize.height = measuredSize.width / aspectRatioModifier.ratio
                        } else {
                            measuredSize.width = measuredSize.height * aspectRatioModifier.ratio
                        }
                    }
                }
            }
        }
        
        // Prevent negative values
        measuredSize = CGSize(width: max(measuredSize.width, 1), height: max(measuredSize.height, 1))
        
        return measuredSize
    }
    
    /// LAYOUT PHASE: Determines the final position of the view
    /// This happens after measure phase
    private func layoutFrame(size: CGSize, in bounds: CGRect) -> CGRect {
        let safeBounds = bounds.width > 0 ? bounds : CGRect(x: 0, y: 0, width: 375, height: bounds.height > 0 ? bounds.height : 600)
        
        // Start with relative coordinates
        var frame = CGRect(origin: .zero, size: size)
        
        // Apply modifiers in sequence (layout phase - positioning)
        for modifier in modifiers {
            // Skip size modifiers (already applied in measure phase)
            if modifier is SizeModifier || modifier is AspectRatioModifier {
                continue
            }
            
            frame = modifier.apply(to: frame, in: safeBounds)

            // Handle BackgroundModifier
            if let backgroundModifier = modifier as? BackgroundModifier {
                view.backgroundColor = backgroundModifier.color
            }
        }
        
        // Convert final frame to relative coordinates based on safeBounds.origin
        let finalFrame = CGRect(
            x: safeBounds.origin.x + frame.origin.x,
            y: safeBounds.origin.y + frame.origin.y,
            width: max(frame.width, 1),
            height: max(frame.height, 1)
        )
        
        return finalFrame
    }
    
    public func extractViews() -> [UIView] {
        return [view]
    }
    
    public var intrinsicContentSize: CGSize {
        // Return the view's intrinsic content size
        return view.intrinsicContentSize
    }
    
    // MARK: - Size Modifiers
    
    /// Sets the width and/or height of the view.
    ///
    /// - Parameters:
    ///   - width: Optional width to set
    ///   - height: Optional height to set
    /// - Returns: A new ``ViewLayout`` with the size modifier applied
    /// Note: Modifier is stored on the view itself, not creating a new node
    public func size(width: CGFloat? = nil, height: CGFloat? = nil) -> ViewLayout {
        view.addLayoutModifier(SizeModifier(width: width, height: height))
        return self
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
    /// - Parameters:
    ///   - width: Optional width to set
    ///   - height: Optional height to set
    /// - Returns: A new ``ViewLayout`` with the frame modifier applied
    public func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> ViewLayout {
        view.addLayoutModifier(SizeModifier(width: width, height: height))
        return self
    }
    
    // MARK: - Position Modifiers
    
    /// Centers the view horizontally within its bounds.
    ///
    /// - Returns: A new ``ViewLayout`` with the center modifier applied
    public func centerX() -> ViewLayout {
        view.addLayoutModifier(CenterModifier(horizontal: true, vertical: false))
        return self
    }
    
    /// Centers the view vertically within its bounds.
    ///
    /// - Returns: A new ``ViewLayout`` with the center modifier applied
    public func centerY() -> ViewLayout {
        view.addLayoutModifier(CenterModifier(horizontal: false, vertical: true))
        return self
    }
    
    /// Centers the view both horizontally and vertically within its bounds.
    ///
    /// - Returns: A new ``ViewLayout`` with the center modifier applied
    public func center() -> ViewLayout {
        view.addLayoutModifier(CenterModifier(horizontal: true, vertical: true))
        return self
    }
    
    /// Sets the position of the view.
    ///
    /// - Parameters:
    ///   - x: X coordinate
    ///   - y: Y coordinate
    /// - Returns: A new ``ViewLayout`` with the position modifier applied
    public func position(x: CGFloat, y: CGFloat) -> ViewLayout {
        view.addLayoutModifier(PositionModifier(x: x, y: y))
        return self
    }
    
    /// Offsets the view by the specified amount.
    ///
    /// - Parameters:
    ///   - x: X offset
    ///   - y: Y offset
    /// - Returns: A new ``ViewLayout`` with the offset modifier applied
    public func offset(x: CGFloat = 0, y: CGFloat = 0) -> ViewLayout {
        view.addLayoutModifier(OffsetModifier(x: x, y: y))
        return self
    }
    
    // MARK: - Aspect Ratio Modifier
    
    /// Sets the aspect ratio of the view.
    ///
    /// - Parameter ratio: The aspect ratio (width / height)
    /// - Returns: A new ``ViewLayout`` with the aspect ratio modifier applied
    public func aspectRatio(_ ratio: CGFloat) -> ViewLayout {
        view.addLayoutModifier(AspectRatioModifier(ratio: ratio, contentMode: .fit))
        return self
    }
    
    // MARK: - Corner Radius Modifier
    
    /// Sets the corner radius of the view.
    ///
    /// - Parameter radius: The corner radius
    /// - Returns: A new ``ViewLayout`` with the corner radius modifier applied
    public func cornerRadius(_ radius: CGFloat) -> ViewLayout {
        view.addLayoutModifier(CornerRadiusModifier(radius: radius))
        
        // Apply corner radius to layer immediately
        view.layer.cornerRadius = radius
        view.layer.masksToBounds = true
        
        return self
    }
    
    // MARK: - Background Modifier
    
    /// Sets the background color of the view.
    ///
    /// - Parameter color: The background color
    /// - Returns: A new ``ViewLayout`` with the background modifier applied
    public func background(_ color: UIColor) -> ViewLayout {
        view.addLayoutModifier(BackgroundModifier(color: color))
        return self
    }
    
    // MARK: - Padding Modifier
    
    /// Adds padding around the view.
    ///
    /// - Parameter insets: The padding insets
    /// - Returns: A new ``ViewLayout`` with the padding modifier applied
    public func padding(_ insets: UIEdgeInsets) -> ViewLayout {
        view.addLayoutModifier(PaddingModifier(insets: insets))
        return self
    }
    
    /// Adds padding around the view.
    ///
    /// - Parameter value: The padding value for all sides
    /// - Returns: A new ``ViewLayout`` with the padding modifier applied
    public func padding(_ value: CGFloat) -> ViewLayout {
        return padding(UIEdgeInsets(top: value, left: value, bottom: value, right: value))
    }
    
    // MARK: - Identity Modifier
    
    /// Sets the identity of the view for efficient diffing and view reuse.
    ///
    /// Identity allows the layout system to:
    /// - Track views across layout updates
    /// - Reuse existing views when identity matches
    /// - Efficiently update only changed views
    ///
    /// - Parameter identity: A hashable value that uniquely identifies this view
    /// - Returns: A new ``ViewLayout`` with the identity set
    ///
    /// ## Example
    ///
    /// ```swift
    /// ForEach(items) { item in
    ///     ItemView(item: item)
    ///         .layout()
    ///         .id(item.id)  // Use item's ID as identity
    /// }
    /// ```
    public func id<ID: Hashable>(_ identity: ID) -> ViewLayout {
        view.layoutIdentity = AnyHashable(identity)
        return self
    }
    
    /// Sets the identity of the view using a string identifier.
    ///
    /// - Parameter identity: A string that uniquely identifies this view
    /// - Returns: A new ``ViewLayout`` with the identity set
    public func id(_ identity: String) -> ViewLayout {
        view.layoutIdentity = AnyHashable(identity)
        return self
    }
}
