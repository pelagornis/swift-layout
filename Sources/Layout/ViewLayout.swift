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
        // Cache modifiers to avoid repeated property access
        let cachedModifiers = modifiers
        
        // PHASE 1: MEASURE - Calculate the size the view wants
        let measuredSize = measureSize(in: bounds, modifiers: cachedModifiers)
        
        // PHASE 2: LAYOUT - Calculate the final position
        let finalFrame = layoutFrame(size: measuredSize, in: bounds, modifiers: cachedModifiers)
        
        return LayoutResult(frames: [view: finalFrame], totalSize: measuredSize)
    }
    
    /// MEASURE PHASE: Determines the size the view wants
    /// This is separate from placement (layout phase)
    private func measureSize(in bounds: CGRect, modifiers: [LayoutModifier]) -> CGSize {
        // Use default bounds if invalid (width can be 0 while height is available)
        // SwiftUI-style: nil width/height means unconstrained in that dimension
        let proposedWidth: CGFloat? = bounds.width > 0 ? bounds.width : nil
        let proposedHeight: CGFloat? = bounds.height > 0 ? bounds.height : nil
        
        let intrinsicSize = view.intrinsicContentSize
        
        // Calculate more accurate default size
        var defaultSize: CGSize
        
        // Optimize: check if intrinsicContentSize is valid before using it
        let hasIntrinsicWidth = intrinsicSize.width != UIView.noIntrinsicMetric
        let hasIntrinsicHeight = intrinsicSize.height != UIView.noIntrinsicMetric
        
        if hasIntrinsicWidth && hasIntrinsicHeight {
            // Use intrinsicContentSize, but respect proposed constraints
            defaultSize = CGSize(
                width: proposedWidth.map { min($0, intrinsicSize.width) } ?? intrinsicSize.width,
                height: proposedHeight.map { min($0, intrinsicSize.height) } ?? intrinsicSize.height
            )
        } else {
            defaultSize = CGSize(
                width: proposedWidth ?? 100,
                height: proposedHeight ?? 30
            )
        }
        
        // Apply size modifiers (measure phase) - use cached modifiers
        var measuredSize = defaultSize
        for modifier in modifiers {
            if let sizeModifier = modifier as? SizeModifier {
                if let width = sizeModifier.width {
                    // Always use actual bounds.width for Percent calculation to ensure consistency
                    // If bounds.width is 0, we'll recalculate in layoutFrame with actual bounds
                    let parentWidth = bounds.width > 0 ? bounds.width : (proposedWidth ?? 375)
                    measuredSize.width = width.calculate(relativeTo: parentWidth)
                }
                if let height = sizeModifier.height {
                    // Always use actual bounds.height for Percent calculation to ensure consistency
                    // If bounds.height is 0, we'll recalculate in layoutFrame with actual bounds
                    let parentHeight = bounds.height > 0 ? bounds.height : (proposedHeight ?? 667)
                    measuredSize.height = height.calculate(relativeTo: parentHeight)
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
    private func layoutFrame(size: CGSize, in bounds: CGRect, modifiers: [LayoutModifier]) -> CGRect {
        // Use actual bounds if available, otherwise use safe fallback
        let safeBounds = bounds.width > 0 && bounds.height > 0 ? bounds : CGRect(x: 0, y: 0, width: 375, height: bounds.height > 0 ? bounds.height : 600)
        
        // Pre-filter size modifiers to avoid repeated type checks
        let sizeModifiers = modifiers.compactMap { $0 as? SizeModifier }
        let hasSizeModifiers = !sizeModifiers.isEmpty
        
        // Only recalculate Percent-based sizes if bounds changed from measure phase
        // Check if bounds are significantly different to avoid unnecessary recalculation
        var finalSize = size
        let boundsChanged = abs(safeBounds.width - (bounds.width > 0 ? bounds.width : 375)) > 1.0 || 
                           abs(safeBounds.height - (bounds.height > 0 ? bounds.height : 600)) > 1.0
        
        if boundsChanged && hasSizeModifiers {
            // Recalculate size if we have Percent modifiers and bounds changed
            for sizeModifier in sizeModifiers {
                if let width = sizeModifier.width {
                    finalSize.width = width.calculate(relativeTo: safeBounds.width)
                }
                if let height = sizeModifier.height {
                    finalSize.height = height.calculate(relativeTo: safeBounds.height)
                }
            }
        }
        
        // Ensure minimum size to prevent invisible views
        finalSize = CGSize(width: max(finalSize.width, 1), height: max(finalSize.height, 1))
        
        // Start with relative coordinates using recalculated size
        var frame = CGRect(origin: .zero, size: finalSize)
        
        // Apply modifiers in sequence (layout phase - positioning)
        // Skip size and aspect ratio modifiers (already applied in measure phase)
        for modifier in modifiers {
            // Skip size modifiers and aspect ratio modifiers (already applied above)
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
    /// Supports both fixed values and percentage (using `%` operator).
    ///
    /// - Parameters:
    ///   - width: Optional width to set (fixed value or percentage like `80%`)
    ///   - height: Optional height to set (fixed value or percentage like `50%`)
    /// - Returns: A new ``ViewLayout`` with the size modifier applied
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Fixed size
    /// view.layout().size(width: 200, height: 100)
    ///
    /// // Percentage (PinLayout-style)
    /// view.layout().size(width: 80%, height: 50%)
    ///
    /// // Mixed
    /// view.layout().size(width: 80%, height: 100)
    /// ```
    /// Note: Modifier is stored on the view itself, not creating a new node
    public func size(width: CGFloat? = nil, height: CGFloat? = nil) -> ViewLayout {
        view.addLayoutModifier(SizeModifier(width: width, height: height))
        return self
    }
    
    /// Sets the width and/or height of the view using SizeValue (supports percentage).
    ///
    /// - Parameters:
    ///   - width: Optional width value (fixed or percentage)
    ///   - height: Optional height value (fixed or percentage)
    /// - Returns: A new ``ViewLayout`` with the size modifier applied
    public func size(width: SizeValue? = nil, height: SizeValue? = nil) -> ViewLayout {
        view.addLayoutModifier(SizeModifier(width: width, height: height))
        return self
    }
    
    /// Sets the width and/or height of the view using Percent (PinLayout-style).
    ///
    /// - Parameters:
    ///   - width: Optional width as Percent (e.g., `80%`)
    ///   - height: Optional height as Percent (e.g., `50%`)
    /// - Returns: A new ``ViewLayout`` with the size modifier applied
    public func size(width: Percent? = nil, height: Percent? = nil) -> ViewLayout {
        view.addLayoutModifier(SizeModifier(width: width, height: height))
        return self
    }
    
    /// Sets the width and/or height of the view with mixed types (Percent width, CGFloat height).
    ///
    /// - Parameters:
    ///   - width: Optional width as Percent (e.g., `80%`)
    ///   - height: Optional height as fixed value
    /// - Returns: A new ``ViewLayout`` with the size modifier applied
    public func size(width: Percent?, height: CGFloat?) -> ViewLayout {
        view.addLayoutModifier(SizeModifier(width: width, height: height))
        return self
    }
    
    /// Sets the width and/or height of the view with mixed types (CGFloat width, Percent height).
    ///
    /// - Parameters:
    ///   - width: Optional width as fixed value
    ///   - height: Optional height as Percent (e.g., `50%`)
    /// - Returns: A new ``ViewLayout`` with the size modifier applied
    public func size(width: CGFloat?, height: Percent?) -> ViewLayout {
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
    
    // MARK: - PinLayout-style Edge Positioning
    
    /// Positions the view from the top edge (PinLayout-style).
    ///
    /// - Parameter value: Distance from top (fixed value or percentage like `25%`)
    /// - Returns: A new ``ViewLayout`` with the edge modifier applied
    ///
    /// ## Example
    ///
    /// ```swift
    /// view.layout()
    ///     .top(25%)  // 25% from top
    ///     .centerX()
    /// ```
    public func top(_ value: Percent) -> ViewLayout {
        view.addLayoutModifier(EdgeModifier(edge: .top, percent: value))
        return self
    }
    
    /// Positions the view from the top edge with fixed value.
    ///
    /// - Parameter value: Distance from top in points
    /// - Returns: A new ``ViewLayout`` with the edge modifier applied
    public func top(_ value: CGFloat) -> ViewLayout {
        view.addLayoutModifier(EdgeModifier(edge: .top, value: .fixed(value)))
        return self
    }
    
    /// Positions the view from the bottom edge (PinLayout-style).
    ///
    /// - Parameter value: Distance from bottom (fixed value or percentage like `25%`)
    /// - Returns: A new ``ViewLayout`` with the edge modifier applied
    public func bottom(_ value: Percent) -> ViewLayout {
        view.addLayoutModifier(EdgeModifier(edge: .bottom, percent: value))
        return self
    }
    
    /// Positions the view from the bottom edge with fixed value.
    ///
    /// - Parameter value: Distance from bottom in points
    /// - Returns: A new ``ViewLayout`` with the edge modifier applied
    public func bottom(_ value: CGFloat) -> ViewLayout {
        view.addLayoutModifier(EdgeModifier(edge: .bottom, value: .fixed(value)))
        return self
    }
    
    /// Positions the view from the leading edge (PinLayout-style).
    ///
    /// - Parameter value: Distance from leading (fixed value or percentage like `25%`)
    /// - Returns: A new ``ViewLayout`` with the edge modifier applied
    public func leading(_ value: Percent) -> ViewLayout {
        view.addLayoutModifier(EdgeModifier(edge: .leading, percent: value))
        return self
    }
    
    /// Positions the view from the leading edge with fixed value.
    ///
    /// - Parameter value: Distance from leading in points
    /// - Returns: A new ``ViewLayout`` with the edge modifier applied
    public func leading(_ value: CGFloat) -> ViewLayout {
        view.addLayoutModifier(EdgeModifier(edge: .leading, value: .fixed(value)))
        return self
    }
    
    /// Positions the view from the trailing edge (PinLayout-style).
    ///
    /// - Parameter value: Distance from trailing (fixed value or percentage like `25%`)
    /// - Returns: A new ``ViewLayout`` with the edge modifier applied
    public func trailing(_ value: Percent) -> ViewLayout {
        view.addLayoutModifier(EdgeModifier(edge: .trailing, percent: value))
        return self
    }
    
    /// Positions the view from the trailing edge with fixed value.
    ///
    /// - Parameter value: Distance from trailing in points
    /// - Returns: A new ``ViewLayout`` with the edge modifier applied
    public func trailing(_ value: CGFloat) -> ViewLayout {
        view.addLayoutModifier(EdgeModifier(edge: .trailing, value: .fixed(value)))
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
}
