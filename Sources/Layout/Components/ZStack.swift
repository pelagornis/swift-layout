import UIKit

/// A z-axis stack layout that layers child layouts on top of each other.
///
/// ``ZStack`` arranges its child layouts in layers, with later children appearing on top
/// of earlier ones. It supports flexible spacing and various alignment options.
///
/// ## Overview
///
/// `ZStack` is a layout container that layers child views on top of each other,
/// similar to SwiftUI's `ZStack`. Child views are positioned according to the
/// specified alignment, with later children appearing above earlier ones.
///
/// ## Key Features
///
/// - **Layered Arrangement**: Child views are stacked on top of each other
/// - **Alignment Options**: Support for 9 different alignment positions
/// - **Z-Index Control**: Later children appear above earlier ones
/// - **Overlay Support**: Perfect for creating overlays and badges
/// - **Flexible Sizing**: Automatically sizes to fit all child content
///
/// ## Example Usage
///
/// ```swift
/// ZStack(alignment: .center) {
///     backgroundView.layout()
///         .size(width: 300, height: 200)
///     titleLabel.layout()
///         .size(width: 280, height: 40)
///     actionButton.layout()
///         .size(width: 180, height: 44)
/// }
/// .padding(40)
/// ```
///
/// ## Topics
///
/// ### Initialization
/// - ``init(alignment:padding:children:)``
///
/// ### Configuration
/// - ``alignment(_:)``
/// - ``padding(_:)``
/// - ``size(width:height:)``
/// - ``overlay(_:)``
///
/// ### Layout Behavior
/// - ``calculateLayout(in:)``
/// - ``extractViews()``
/// - ``intrinsicContentSize``
public class ZStack: UIView, Layout {
    public typealias Body = Never
    
    public var body: Never {
        fatalError("ZStack body should not be called")
    }
    
    /// Alignment of child layouts
    public var alignment: Alignment
    
    /// Padding around the entire stack
    public var padding: UIEdgeInsets
    
    /// Explicit size override
    public var explicitSize: CGSize = .zero
    
    /// Dictionary to store ViewLayout information for each subview
    private var viewLayouts: [UIView: ViewLayout] = [:]
    
    /// Alignment options for ZStack
    public enum Alignment {
        case topLeading, top, topTrailing
        case leading, center, trailing
        case bottomLeading, bottom, bottomTrailing
    }
    
    /// Creates a ZStack with the specified alignment and padding.
    /// - Parameters:
    ///   - alignment: The alignment of child views
    ///   - padding: The padding around the ZStack
    ///   - children: A closure that returns the child layouts
    public init(alignment: Alignment = .center, padding: UIEdgeInsets = .zero, @LayoutBuilder children: () -> any Layout) {
        self.alignment = alignment
        self.padding = padding
        
        super.init(frame: .zero)
        
        
        let layout = children()
        
        if let tupleLayout = layout as? TupleLayout {
            
            for (_, childLayout) in tupleLayout.layouts.enumerated() {
                
                let childViews = childLayout.extractViews()
                
                for (_, childView) in childViews.enumerated() {
                    addSubview(childView)
                    
                    // Store ViewLayout information for all views (including Stack components)
                    if let viewLayout = childLayout as? ViewLayout {
                        storeViewLayout(viewLayout, for: childView)
                    }
                }
            }
        } else {
            let allChildViews = layout.extractViews()

            for (_, childView) in allChildViews.enumerated() {
                addSubview(childView)
                
                if let viewLayout = layout as? ViewLayout {
                    storeViewLayout(viewLayout, for: childView)
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        self.alignment = .center
        self.padding = .zero
        super.init(coder: coder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        
        // Use safeBounds if bounds is not valid
        let safeBounds = bounds.width > 0 && bounds.height > 0 ? bounds : CGRect(x: 0, y: 0, width: 375, height: 600)
        let paddedBounds = safeBounds.inset(by: padding)
        
        // Call calculateLayout to get the calculated frames from ViewLayout
        let layoutResult = calculateLayout(in: bounds)
        
        // Layout all subviews
        for subview in subviews {
            
            var size: CGSize
            var offsetX: CGFloat = 0
            var offsetY: CGFloat = 0
            
            // Use the frame calculated from calculateLayout
            if let frame = layoutResult.frames[subview] {
                size = frame.size
                
                // Check if view has offset modifier (stored on view itself)
                for modifier in subview.layoutModifiers {
                    if let offsetModifier = modifier as? OffsetModifier {
                        offsetX = offsetModifier.x
                        offsetY = offsetModifier.y
                        break
                    }
                }
            } else {
                // Fallback for views not in layoutResult
                size = CGSize(width: 50, height: 20)
            }
            
            // Prevent negative values
            size = CGSize(width: max(size.width, 1), height: max(size.height, 1))
            
            // Use ZStack's full bounds for center alignment (excluding padding)
            let (x, y) = calculatePosition(for: size, in: paddedBounds, alignment: alignment)
            
            // Apply offset modifier if present
            let finalFrame = CGRect(
                x: x + offsetX,
                y: y + offsetY,
                width: size.width,
                height: size.height
            )
            subview.frame = finalFrame
        }
    }
    
    private func calculatePosition(for size: CGSize, in bounds: CGRect, alignment: Alignment) -> (CGFloat, CGFloat) {
        let x: CGFloat
        let y: CGFloat
        
        switch alignment {
        case .topLeading:
            x = bounds.minX
            y = bounds.minY
        case .top:
            // Optimize /2 with *0.5
            x = bounds.midX - size.width * 0.5
            y = bounds.minY
        case .topTrailing:
            x = bounds.maxX - size.width
            y = bounds.minY
        case .leading:
            x = bounds.minX
            // Optimize /2 with *0.5
            y = bounds.midY - size.height * 0.5
        case .center:
            // Optimize /2 with *0.5
            x = bounds.midX - size.width * 0.5
            y = bounds.midY - size.height * 0.5
        case .trailing:
            x = bounds.maxX - size.width
            // Optimize /2 with *0.5
            y = bounds.midY - size.height * 0.5
        case .bottomLeading:
            x = bounds.minX
            y = bounds.maxY - size.height
        case .bottom:
            // Optimize /2 with *0.5
            x = bounds.midX - size.width * 0.5
            y = bounds.maxY - size.height
        case .bottomTrailing:
            x = bounds.maxX - size.width
            y = bounds.maxY - size.height
        }
        
        return (x, y)
    }
    
    public override var intrinsicContentSize: CGSize {
        var maxWidth: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        // Pre-calculate default bounds constant to avoid repeated calculations
        let defaultBounds = CGRect(x: 0, y: 0, width: 375, height: 600)
        
        // Calculate actual size of child views accurately
        for subview in subviews {
            var size: CGSize
            
            // For views implementing Layout protocol (VStack, HStack, ZStack)
            if let layoutView = subview as? (any Layout) {
                // Use calculateLayout for Layout views to calculate accurate size - reuse defaultBounds
                let layoutResult = layoutView.calculateLayout(in: defaultBounds)
                size = layoutResult.totalSize
                // Prevent negative values - optimize max() calls
                if size.width < 50 {
                    size.width = 50
                }
                if size.height < 20 {
                    size.height = 20
                }
            } else {
                // Use intrinsicContentSize for other views
                let intrinsicSize = subview.intrinsicContentSize
                // Optimize max() calls
                size = CGSize(
                    width: intrinsicSize.width >= 50 ? intrinsicSize.width : 50,
                    height: intrinsicSize.height >= 20 ? intrinsicSize.height : 20
                )
            }
            
            // Optimize max() calls - only update if larger
            if size.width > maxWidth {
                maxWidth = size.width
            }
            if size.height > maxHeight {
                maxHeight = size.height
            }
        }
        
        // Add padding - cache calculations
        let paddingLeftRight = padding.left + padding.right
        let paddingTopBottom = padding.top + padding.bottom
        maxWidth += paddingLeftRight
        maxHeight += paddingTopBottom
        
        // Ensure minimum size (even when no child views) - optimize max() calls
        if maxWidth < 200 {
            maxWidth = 200
        }
        if maxHeight < 100 {
            maxHeight = 100
        }
        
        return CGSize(width: maxWidth, height: maxHeight)
    }
    
    // MARK: - Layout Protocol
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        
        let safeBounds = bounds.inset(by: padding)
        var frames: [UIView: CGRect] = [:]
        var totalSize = CGSize.zero
        // If ZStack itself has ViewLayout (from .layout() modifier), use it for size calculation
        // This handles Percent-based sizes correctly
        var zStackSize: CGSize? = nil
        if let storedViewLayout = getViewLayout(for: self) {
            let viewResult = storedViewLayout.calculateLayout(in: bounds)
            if let frame = viewResult.frames[self] {
                zStackSize = frame.size
                frames[self] = frame
            }
        } else if explicitSize.width > 0 || explicitSize.height > 0 {
            // Use explicit size if set
            zStackSize = CGSize(
                width: explicitSize.width > 0 ? explicitSize.width : bounds.width,
                height: explicitSize.height > 0 ? explicitSize.height : bounds.height
            )
        }
        
        // Calculate layout for each child
        for subview in subviews {
            if let layoutView = subview as? (any Layout) {
                let childResult = layoutView.calculateLayout(in: safeBounds)
                
                frames.merge(childResult.frames) { _, new in new }
                // Optimize max() calls - only update if larger
                if childResult.totalSize.width > totalSize.width {
                    totalSize.width = childResult.totalSize.width
                }
                if childResult.totalSize.height > totalSize.height {
                    totalSize.height = childResult.totalSize.height
                }
            } else {
                // Check if stored ViewLayout information exists
                if let storedViewLayout = getViewLayout(for: subview) {
                    // Call calculateLayout using stored ViewLayout information
                    let viewResult = storedViewLayout.calculateLayout(in: safeBounds)
                    
                    if let frame = viewResult.frames[subview] {
                        frames[subview] = frame
                        // Optimize max() calls - only update if larger
                        if frame.width > totalSize.width {
                            totalSize.width = frame.width
                        }
                        if frame.height > totalSize.height {
                            totalSize.height = frame.height
                        }

                    } else {
                        // Fallback: use existing logic
                        var size: CGSize
                        if subview is Spacer {
                            size = .zero
                        } else {
                            let intrinsicSize = subview.intrinsicContentSize
                            size = CGSize(width: max(intrinsicSize.width, 50), height: max(intrinsicSize.height, 20))
                        }
                        frames[subview] = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                        // Optimize max() calls - only update if larger
                        if size.width > totalSize.width {
                            totalSize.width = size.width
                        }
                        if size.height > totalSize.height {
                            totalSize.height = size.height
                        }
                    }
                } else {
                    // Use existing logic if no stored ViewLayout information
                    var size: CGSize
                    if subview is Spacer {
                        size = .zero
                    } else {
                        let intrinsicSize = subview.intrinsicContentSize
                        size = CGSize(width: max(intrinsicSize.width, 50), height: max(intrinsicSize.height, 20))
                    }
                    frames[subview] = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                    totalSize.width = max(totalSize.width, size.width)
                    totalSize.height = max(totalSize.height, size.height)
                }
            }
        }
        
        // If we have a size from ViewLayout or explicitSize, use it
        if let zStackSize = zStackSize {
            totalSize = zStackSize
        } else {
            // Otherwise, calculate from children and add padding
            totalSize.width += padding.left + padding.right
            totalSize.height += padding.top + padding.bottom
        }
        
        // Set frame for ZStack itself using totalSize (actual content size)
        frames[self] = CGRect(x: 0, y: 0, width: totalSize.width, height: totalSize.height)
        
        
        return LayoutResult(frames: frames, totalSize: totalSize)
    }
    
    public func extractViews() -> [UIView] {
        return [self]
    }
    
    /// Stores ViewLayout information for a specific view
    public func storeViewLayout(_ viewLayout: ViewLayout, for view: UIView) {
        viewLayouts[view] = viewLayout
    }
    
    /// Retrieves ViewLayout information for a specific view
    public func getViewLayout(for view: UIView) -> ViewLayout? {
        return viewLayouts[view]
    }
    
    // MARK: - Modifier Methods
    
    public func alignment(_ alignment: Alignment) -> Self {
        self.alignment = alignment
        return self
    }
    
    public func padding(_ insets: UIEdgeInsets) -> Self {
        self.padding = insets
        return self
    }
    
    public func padding(_ length: CGFloat) -> Self {
        return padding(UIEdgeInsets(top: length, left: length, bottom: length, right: length))
    }
    
    public func padding(_ edges: UIRectEdge = .all, _ length: CGFloat) -> Self {
        var insets = UIEdgeInsets.zero
        if edges.contains(.top) { insets.top = length }
        if edges.contains(.left) { insets.left = length }
        if edges.contains(.bottom) { insets.bottom = length }
        if edges.contains(.right) { insets.right = length }
        return padding(insets)
    }
    
    public func size(width: CGFloat? = nil, height: CGFloat? = nil) -> Self {
        self.explicitSize = CGSize(
            width: width ?? 0,
            height: height ?? 0
        )
        return self
    }
    
    public func size(_ size: CGSize) -> Self {
        self.explicitSize = size
        return self
    }
    
    public func overlay(@LayoutBuilder _ overlay: () -> any Layout) -> Self {
        let overlayLayout = overlay()
        
        let overlayLayouts: [any Layout]
        if let tupleLayout = overlayLayout as? TupleLayout {
            // Extract child views using TupleLayout's extractViews()
            let views = tupleLayout.extractViews()
            // Convert to ViewLayout
            overlayLayouts = views.map { ViewLayout($0) }
        } else {
            overlayLayouts = [overlayLayout]
        }

        // Add overlay views (exclude Layout views)
        for overlayLayout in overlayLayouts {
            let overlayViews = overlayLayout.extractViews()
            for overlayView in overlayViews {
                // Don't add Layout views (child views already added)
                if !(overlayView is VStack || overlayView is HStack || overlayView is ZStack) {
                    self.addSubview(overlayView)
                }
            }
        }
        return self
    }
}
