import UIKit

/// A horizontal stack layout that arranges child layouts horizontally.
///
/// ``HStack`` arranges its child layouts in a horizontal row with optional spacing
/// and alignment. It supports flexible spacing with ``Spacer`` and various alignment options.
///
/// ## Overview
///
/// `HStack` is one of the fundamental layout containers in the ManualLayout system.
/// It arranges child views in a horizontal row, similar to SwiftUI's `HStack`.
/// The stack automatically handles spacing, alignment, and sizing of child views.
///
/// ## Key Features
///
/// - **Horizontal Arrangement**: Child views are arranged from left to right
/// - **Flexible Spacing**: Configurable spacing between child views
/// - **Alignment Options**: Support for top, center, and bottom alignment
/// - **Spacer Support**: Flexible spacing with `Spacer` components
/// - **ScrollView Integration**: Automatic handling of ScrollView contexts
///
/// ## Example Usage
///
/// ```swift
/// HStack(alignment: .center, spacing: 20) {
///     iconView.layout()
///         .size(width: 40, height: 40)
///     titleLabel.layout()
///         .size(width: 200, height: 30)
///     Spacer()
///     actionButton.layout()
///         .size(width: 100, height: 44)
/// }
/// .padding(40)
/// ```
///
/// ## Topics
///
/// ### Initialization
/// - ``init(alignment:spacing:children:)``
///
/// ### Configuration
/// - ``spacing(_:)``
/// - ``alignment(_:)``
/// - ``padding(_:)``
/// - ``size(width:height:)``
/// - ``overlay(_:)``
///
/// ### Layout Behavior
/// - ``calculateLayout(in:)``
/// - ``extractViews()``
/// - ``intrinsicContentSize``
public class HStack: UIView, Layout {
    public typealias Body = Never
    
    public var body: Never {
        fatalError("HStack body should not be called")
    }
    
    /// Spacing between child layouts
    public var spacing: CGFloat
    
    /// Vertical alignment of child layouts
    public var alignment: VerticalAlignment
    
    /// Padding around the entire stack
    public var padding: UIEdgeInsets
    
    /// Explicit size override
    public var explicitSize: CGSize = .zero
    
    /// Dictionary to store ViewLayout information for each subview
    private var viewLayouts: [UIView: ViewLayout] = [:]
    
    /// Cache for ScrollView detection
    private var isInsideScrollViewCache: Bool?
    
    /// Vertical alignment options for HStack
    public enum VerticalAlignment {
        case top, center, bottom
    }
    
    /// Creates an HStack with the specified spacing, alignment, and padding.
    /// - Parameters:
    ///   - alignment: The vertical alignment of child views
    ///   - spacing: The spacing between child views
    ///   - padding: The padding around the HStack
    ///   - children: A closure that returns the child layouts
    public init(alignment: VerticalAlignment = .center, spacing: CGFloat = 0, @LayoutBuilder children: () -> any Layout) {
        self.alignment = alignment
        self.spacing = spacing
        self.padding = .zero
        
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
        self.spacing = 0
        self.alignment = .center
        self.padding = .zero
        super.init(coder: coder)
    }
    
    public override var intrinsicContentSize: CGSize {
        var totalWidth: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        // Detect if inside ScrollView
        let isInsideScrollView = isInsideScrollView()
        
        // intrinsicContentSize calculates the natural size without constraints
        // Based on children's intrinsicContentSize, not dependent on bounds
        
        // Pre-calculate infinite size constant to avoid repeated calculations
        let infiniteSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        
        for subview in subviews {
            var size: CGSize
            
            // Special handling for Spacer
            if let spacer = subview as? Spacer {
                let minLength = spacer.minLength ?? 0
                // Spacer uses minLength in intrinsicContentSize
                size = CGSize(width: minLength, height: minLength)
            } else {
                // Optimize type checking - check most common types first
                if let layoutView = subview as? (any Layout) {
                    // Use intrinsicContentSize for Layout views
                    size = layoutView.intrinsicContentSize
                } else {
                    // Use intrinsicContentSize for other views
                    size = subview.intrinsicContentSize
                }
            }
            
            totalWidth += size.width
            // Optimize max() call - only update if larger
            if size.height > maxHeight {
                maxHeight = size.height
            }
        }
        
        // Add spacing - count effective subviews without creating new array
        var effectiveSubviewCount = 0
        if isInsideScrollView {
            for subview in subviews {
                if let spacer = subview as? Spacer {
                    if (spacer.minLength ?? 0) > 0 {
                        effectiveSubviewCount += 1
                    }
                } else {
                    effectiveSubviewCount += 1
                }
            }
        } else {
            effectiveSubviewCount = subviews.count
        }
        if effectiveSubviewCount > 1 {
            totalWidth += spacing * CGFloat(effectiveSubviewCount - 1)
        }
        
        // Add padding - cache calculations
        let paddingLeftRight = padding.left + padding.right
        let paddingTopBottom = padding.top + padding.bottom
        totalWidth += paddingLeftRight
        maxHeight += paddingTopBottom
        
        return CGSize(width: totalWidth, height: maxHeight)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        
        // Use safeBounds if bounds is not valid
        let safeBounds = bounds.width > 0 && bounds.height > 0 ? bounds : CGRect(x: 0, y: 0, width: 375, height: 600)
        let availableBounds = safeBounds.inset(by: padding)
        
        // Detect if inside ScrollView
        let isInsideScrollView = isInsideScrollView()
        
        // Call calculateLayout to get the calculated frames from ViewLayout
        let layoutResult = calculateLayout(in: bounds)
        
        // First calculate fixed content width (excluding Spacer)
        var fixedContentWidth: CGFloat = 0
        var nonSpacerSubviews: [(UIView, CGSize)] = []
        var spacerCount: Int = 0
        var totalMinLength: CGFloat = 0
        
        for subview in subviews {
            // Detect Spacer
            if let spacer = subview as? Spacer {
                spacerCount += 1
                totalMinLength += spacer.minLength ?? 0
            } else {
                var size: CGSize
                // Use the frame calculated from calculateLayout
                if let frame = layoutResult.frames[subview] {
                    size = frame.size
                } else {
                    // Fallback for views not in layoutResult
                    size = CGSize(width: 50, height: 20)
                }
                nonSpacerSubviews.append((subview, size))
                fixedContentWidth += size.width
            }
        }
        
        // Calculate total spacing - consider Spacers with minLength
        let effectiveSubviews: [UIView]
        if isInsideScrollView {
            effectiveSubviews = subviews.filter { subview in
                if let spacer = subview as? Spacer {
                    return (spacer.minLength ?? 0) > 0
                }
                return true
            }
        } else {
            effectiveSubviews = subviews
        }
        let totalSpacing = effectiveSubviews.count > 1 ? spacing * CGFloat(effectiveSubviews.count - 1) : 0
        
        // Calculate remaining space for Spacers
        let totalAvailableWidthForContent = availableBounds.width
        let remainingWidthForSpacers: CGFloat
        if isInsideScrollView {
            // Inside ScrollView: no flexible space
            remainingWidthForSpacers = 0
        } else {
            // Normal case
            remainingWidthForSpacers = max(0, totalAvailableWidthForContent - fixedContentWidth - totalSpacing - totalMinLength)
        }
        let finalSpacerWidth = spacerCount > 0 ? remainingWidthForSpacers / CGFloat(spacerCount) : 0
        
        
        // Calculate layout start position
        var currentX: CGFloat = availableBounds.minX
        
        // Layout all subviews
        for subview in subviews {
            var size: CGSize
            
            // Detect Spacer
            if let spacer = subview as? Spacer {
                let minLength = spacer.minLength ?? 0
                let actualWidth: CGFloat
                
                if isInsideScrollView {
                    // Inside ScrollView: only use minLength
                    actualWidth = minLength
                } else {
                    // Normal case: flexible space + minLength
                    actualWidth = max(finalSpacerWidth + minLength, minLength)
                }
                size = CGSize(width: actualWidth, height: availableBounds.height)
            } else {
                // Use the frame calculated from calculateLayout
                if let frame = layoutResult.frames[subview] {
                    size = frame.size
                } else {
                    // Find the subview size from nonSpacerSubviews (fallback)
                    if let found = nonSpacerSubviews.first(where: { $0.0 === subview }) {
                        size = found.1
                    } else {
                        size = CGSize(width: 50, height: 20) // Default size
                    }
                }
            }
            
            let y: CGFloat
            switch alignment {
            case .top: y = availableBounds.minY
            case .center: y = availableBounds.midY - size.height / 2
            case .bottom: y = availableBounds.maxY - size.height
            }
            
            let frame = CGRect(x: currentX, y: y, width: max(size.width, 1), height: max(size.height, 1))
            subview.frame = frame
            
            currentX += size.width + spacing
        }
    }
    
    // MARK: - Layout Protocol
    
    // Layout calculation when Spacer is present
    private func calculateLayoutWithSpacers(in bounds: CGRect) -> LayoutResult {
        
        let safeBounds = bounds.inset(by: padding)
        var frames: [UIView: CGRect] = [:]
        var totalSize = CGSize.zero
        
        // Detect if inside ScrollView
        let isInsideScrollView = isInsideScrollView()
        
        // First calculate the size of views that are not Spacers
        var fixedContentWidth: CGFloat = 0
        var spacerCount: Int = 0
        var totalMinLength: CGFloat = 0
        
        for subview in subviews {
            if let layoutView = subview as? (any Layout) {
                let childResult = layoutView.calculateLayout(in: safeBounds)
                frames.merge(childResult.frames) { _, new in new }
                totalSize.height = max(totalSize.height, childResult.totalSize.height)
                fixedContentWidth += childResult.totalSize.width
            } else if let spacer = subview as? Spacer {
                spacerCount += 1
                totalMinLength += spacer.minLength ?? 0
            } else {
                let size = calculateFallbackSize(for: subview, maxWidth: CGFloat.greatestFiniteMagnitude, maxHeight: safeBounds.height)
                frames[subview] = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                totalSize.height = max(totalSize.height, size.height)
                fixedContentWidth += size.width
            }
        }
        
        // Spacer calculation
        let totalSpacing = subviews.count > 1 ? spacing * CGFloat(subviews.count - 1) : 0
        let remainingWidthForSpacers: CGFloat
        if isInsideScrollView {
            remainingWidthForSpacers = 0
        } else {
            remainingWidthForSpacers = max(0, safeBounds.width - fixedContentWidth - totalSpacing - totalMinLength)
        }
        let spacerWidth = spacerCount > 0 ? remainingWidthForSpacers / CGFloat(spacerCount) : 0
        
        // Set calculated size for Spacers
        for subview in subviews {
            if let spacer = subview as? Spacer {
                let minLength = spacer.minLength ?? 0
                let actualWidth: CGFloat
                if isInsideScrollView {
                    actualWidth = minLength
                } else {
                    actualWidth = max(spacerWidth + minLength, minLength)
                }
                frames[subview] = CGRect(x: 0, y: 0, width: actualWidth, height: safeBounds.height)
                totalSize.height = max(totalSize.height, safeBounds.height)
            }
        }
        
        // Calculate total width
        if isInsideScrollView {
            // Inside ScrollView: calculate actual content width including Spacer minLengths
            totalSize.width = fixedContentWidth + totalSpacing + totalMinLength
        } else {
            // Use all available space
            totalSize.width = safeBounds.width
        }
        totalSize.width += padding.left + padding.right
        totalSize.height += padding.top + padding.bottom
        
        frames[self] = CGRect(x: 0, y: 0, width: totalSize.width, height: totalSize.height)
        
        return LayoutResult(frames: frames, totalSize: totalSize)
    }
    
    // Layout calculation when Spacer is not present
    private func calculateLayoutWithoutSpacers(in bounds: CGRect) -> LayoutResult {
        
        let safeBounds = bounds.inset(by: padding)
        var frames: [UIView: CGRect] = [:]
        var totalSize = CGSize.zero
        
        // Detect if inside ScrollView
        let isInsideScrollView = isInsideScrollView()
        
        // Apply screen size limits - optimize min() calls
        let maxWidth: CGFloat
        if safeBounds.width <= bounds.width {
            maxWidth = safeBounds.width
        } else {
            maxWidth = bounds.width
        }
        let maxHeight: CGFloat
        if safeBounds.height <= bounds.height {
            maxHeight = safeBounds.height
        } else {
            maxHeight = bounds.height
        }
        
        // Pre-calculate alignment values to avoid repeated checks
        let isTop = alignment == .top
        let isCenter = alignment == .center
        let safeBoundsMinY = safeBounds.minY
        let safeBoundsMaxY = safeBounds.maxY
        let safeBoundsHeight = safeBounds.height
        let safeBoundsHalfHeight = safeBoundsHeight * 0.5
        
        for subview in subviews {
            // Handle Spacer with minLength inside ScrollView
            if let spacer = subview as? Spacer {
                let minLength = spacer.minLength ?? 0
                if isInsideScrollView {
                    // Inside ScrollView: only use minLength
                    let size = CGSize(width: minLength, height: maxHeight)
                    frames[subview] = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                    totalSize.width += size.width
                    // Optimize max() call - only update if larger
                    if size.height > totalSize.height {
                        totalSize.height = size.height
                    }
                }
                continue
            }
            
            // Check if stored ViewLayout information exists (PRIORITY: check ViewLayout first!)
            if let storedViewLayout = getViewLayout(for: subview) {
                // Call calculateLayout using stored ViewLayout information
                let viewResult = storedViewLayout.calculateLayout(in: CGRect(x: 0, y: 0, width: maxWidth, height: maxHeight))
                
                if let frame = viewResult.frames[subview] {
                    frames[subview] = frame
                    totalSize.width += frame.width
                    totalSize.height = max(totalSize.height, frame.height)
                } else {
                    // Fallback: use existing logic
                    var size: CGSize

                    let intrinsicSize = subview.intrinsicContentSize
                    size = CGSize(width: min(intrinsicSize.width, maxWidth), height: max(intrinsicSize.height, 20))
                    frames[subview] = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                    totalSize.width += size.width
                    // Optimize max() call - only update if larger
                    if size.height > totalSize.height {
                        totalSize.height = size.height
                    }
                }
            } else if let layoutView = subview as? (any Layout) {
                // Pass limited size to child layout
                let limitedBounds = CGRect(x: 0, y: 0, width: maxWidth, height: maxHeight)
                let childResult = layoutView.calculateLayout(in: limitedBounds)
                frames.merge(childResult.frames) { _, new in new }
                
                // Apply size limits - optimize min() calls
                let limitedWidth: CGFloat
                if childResult.totalSize.width <= maxWidth {
                    limitedWidth = childResult.totalSize.width
                } else {
                    limitedWidth = maxWidth
                }
                let limitedHeight: CGFloat
                if childResult.totalSize.height <= maxHeight {
                    limitedHeight = childResult.totalSize.height
                } else {
                    limitedHeight = maxHeight
                }
                totalSize.width += limitedWidth
                // Optimize max() call - only update if larger
                if limitedHeight > totalSize.height {
                    totalSize.height = limitedHeight
                }
            } else {
                // Use existing logic if no stored ViewLayout information - reuse helper
                let size = calculateFallbackSize(for: subview, maxWidth: maxWidth, maxHeight: maxHeight)
                frames[subview] = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                totalSize.width += size.width
                totalSize.height = max(totalSize.height, size.height)
            }
        }
        
        // Add spacing - count effective subviews without creating new array
        var effectiveSubviewCount = 0
        if isInsideScrollView {
            for subview in subviews {
                if let spacer = subview as? Spacer {
                    if (spacer.minLength ?? 0) > 0 {
                        effectiveSubviewCount += 1
                    }
                } else {
                    effectiveSubviewCount += 1
                }
            }
        } else {
            effectiveSubviewCount = subviews.count
        }
        if effectiveSubviewCount > 1 {
            totalSize.width += spacing * CGFloat(effectiveSubviewCount - 1)
        }
        
        // Add padding
        totalSize.width += padding.left + padding.right
        totalSize.height += padding.top + padding.bottom
        
        // Apply final size limits - optimize min() calls
        if totalSize.width > bounds.width {
            totalSize.width = bounds.width
        }
        if totalSize.height > bounds.height {
            totalSize.height = bounds.height
        }
        
        // Calculate actual position for each view
        var currentX: CGFloat = padding.left
        // Optimize /2 with *0.5
        let paddingHeight = totalSize.height - padding.top - padding.bottom
        let centerY = paddingHeight * 0.5 + padding.top
        
        for subview in subviews {
            if let frame = frames[subview] {
                // Calculate actual position for view (center alignment)
                // Optimize /2 with *0.5
                let viewY = centerY - frame.height * 0.5
                let actualFrame = CGRect(
                    x: currentX,
                    y: viewY,
                    width: frame.width,
                    height: frame.height
                )
                frames[subview] = actualFrame
                currentX += frame.width + spacing
            }
        }
        
        frames[self] = CGRect(x: 0, y: 0, width: totalSize.width, height: totalSize.height)

        return LayoutResult(frames: frames, totalSize: totalSize)
    }

    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        
        // Check if Spacer exists
        let hasSpacers = subviews.contains { $0 is Spacer }
        
        // Detect if inside ScrollView
        let isInsideScrollView = isInsideScrollView()
        
        if hasSpacers && isInsideScrollView {
            return calculateLayoutWithoutSpacers(in: bounds)
        } else if hasSpacers {
            return calculateLayoutWithSpacers(in: bounds)
        } else {
            return calculateLayoutWithoutSpacers(in: bounds)
        }
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
    
    /// Helper method to calculate fallback size for a subview
    private func calculateFallbackSize(for subview: UIView, maxWidth: CGFloat, maxHeight: CGFloat) -> CGSize {
        let intrinsicSize = subview.intrinsicContentSize
        return CGSize(width: min(intrinsicSize.width, maxWidth), height: max(intrinsicSize.height, 20))
    }
    
    /// Method to detect if inside ScrollView
    private func isInsideScrollView() -> Bool {
        // Return cached value if exists
        if let cached = isInsideScrollViewCache {
            return cached
        }
        
        // Traverse parent views to find ScrollView
        var currentView: UIView? = self.superview
        while let view = currentView {
            if view is UIScrollView || view is ScrollView {
                isInsideScrollViewCache = true
                return true
            }
            currentView = view.superview
        }
        
        // Consider inside ScrollView if bounds.width is very large (horizontal scroll)
        if bounds.width > 1000 {
            isInsideScrollViewCache = true
            return true
        }
        
        isInsideScrollViewCache = false
        return false
    }
    
    // MARK: - Modifier Methods
    
    public func spacing(_ spacing: CGFloat) -> Self {
        self.spacing = spacing
        return self
    }
    
    public func alignment(_ alignment: VerticalAlignment) -> Self {
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
