import UIKit

/// A vertical stack layout that arranges child layouts vertically.
///
/// ``VStack`` arranges its child layouts in a vertical column with optional spacing
/// and alignment. It supports flexible spacing with ``Spacer`` and various alignment options.
///
/// ## Overview
///
/// `VStack` is one of the fundamental layout containers in the ManualLayout system.
/// It arranges child views in a vertical stack, similar to SwiftUI's `VStack`.
/// The stack automatically handles spacing, alignment, and sizing of child views.
///
/// ## Key Features
///
/// - **Vertical Arrangement**: Child views are arranged from top to bottom
/// - **Flexible Spacing**: Configurable spacing between child views
/// - **Alignment Options**: Support for leading, center, and trailing alignment
/// - **Spacer Support**: Flexible spacing with `Spacer` components
/// - **ScrollView Integration**: Automatic handling of ScrollView contexts
///
/// ## Example Usage
///
/// ```swift
/// VStack(alignment: .center, spacing: 20) {
///     titleLabel.layout()
///         .size(width: 280, height: 40)
///     actionButton.layout()
///         .size(width: 180, height: 44)
///     Spacer()
///     footerLabel.layout()
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
public class VStack: UIView, Layout {
    public typealias Body = Never
    
    public var body: Never {
        fatalError("VStack body should not be called")
    }
    
    /// Spacing between child layouts.
    ///
    /// The amount of space to place between child views in the vertical stack.
    /// This spacing is applied between all adjacent child views.
    public var spacing: CGFloat
    
    /// Horizontal alignment of child layouts.
    ///
    /// Determines how child views are aligned horizontally within the stack.
    /// Options include leading, center, and trailing alignment.
    public var alignment: HorizontalAlignment
    
    /// Padding around the entire stack.
    ///
    /// The insets applied around the entire VStack, creating space between
    /// the stack and its container.
    public var padding: UIEdgeInsets
    
    /// Explicit size override.
    ///
    /// When set to a non-zero size, this overrides the natural size calculation
    /// and forces the VStack to use the specified size.
    public var explicitSize: CGSize = .zero
    
    /// Dictionary to store ViewLayout information for each subview
    private var viewLayouts: [UIView: ViewLayout] = [:]
    
    /// Cache for ScrollView detection
    private var isInsideScrollViewCache: Bool?
    
    /// Horizontal alignment options for VStack.
    ///
    /// Defines how child views are aligned horizontally within the vertical stack.
    public enum HorizontalAlignment {
        /// Aligns child views to the leading edge (left in left-to-right languages).
        case leading
        /// Centers child views horizontally within the stack.
        case center
        /// Aligns child views to the trailing edge (right in left-to-right languages).
        case trailing
    }
    
    /// Creates a VStack with the specified spacing, alignment, and padding.
    ///
    /// - Parameters:
    ///   - alignment: The horizontal alignment of child views (default: `.center`)
    ///   - spacing: The spacing between child views (default: `0`)
    ///   - children: A closure that returns the child layouts
    ///
    /// ## Example
    ///
    /// ```swift
    /// VStack(alignment: .leading, spacing: 16) {
    ///     titleLabel.layout()
    ///     subtitleLabel.layout()
    ///     actionButton.layout()
    /// }
    /// ```
    public init(alignment: HorizontalAlignment = .center, spacing: CGFloat = 0, @LayoutBuilder children: () -> any Layout) {
        self.alignment = alignment
        self.spacing = spacing
        self.padding = .zero
        
        super.init(frame: .zero)
        
        // Create child layout and convert to views
        let layout = children()
        
        // Extract children directly if it's a TupleLayout
        if let tupleLayout = layout as? TupleLayout {
            
            // Extract views directly from TupleLayout's layouts array
            for (_, childLayout) in tupleLayout.layouts.enumerated() {
                
                let childViews = childLayout.extractViews()
                
                // Process views from each child layout
                for (_, childView) in childViews.enumerated() {
                    
                    
                    // Add stack components directly (as own children)
                    if childView is VStack || childView is HStack || childView is ZStack {
                        addSubview(childView)
                        continue
                    }
                    
                    // Also add regular views directly
                    addSubview(childView)
                    
                    // Store ViewLayout information
                    if let viewLayout = childLayout as? ViewLayout {
                        storeViewLayout(viewLayout, for: childView)
                    }
                }
            }
        } else {
            let allChildViews = layout.extractViews()
            for (_, childView) in allChildViews.enumerated() {
                addSubview(childView)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        self.spacing = 0
        self.alignment = .center
        self.padding = .zero
        super.init(coder: coder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // Use safeBounds if bounds is invalid
        let safeBounds = bounds.width > 0 && bounds.height > 0 ? bounds : CGRect(x: 0, y: 0, width: 375, height: 600)
        let availableBounds = safeBounds.inset(by: padding)
        
        // Call calculateLayout to get the calculated frames from ViewLayout
        let layoutResult = calculateLayout(in: bounds)
        
        // First calculate fixed content height (excluding Spacers)
        var fixedContentHeight: CGFloat = 0
        var spacerCount: Int = 0
        var totalMinLength: CGFloat = 0
        
        for subview in subviews {
            // Detect Spacer
            if let spacer = subview as? Spacer {
                spacerCount += 1
                totalMinLength += spacer.minLength ?? 0
            } else {
                // Use the frame calculated from calculateLayout
                if let frame = layoutResult.frames[subview] {
                    let size = frame.size
                    fixedContentHeight += size.height
                } else {
                    // Fallback for views not in layoutResult
                    let size = CGSize(width: 50, height: 20)
                    fixedContentHeight += size.height
                }
            }
        }
        
        // Calculate total spacing (between all subviews)
        let totalSpacing = subviews.count > 1 ? spacing * CGFloat(subviews.count - 1) : 0
        
        // Calculate remaining space for Spacers (like SwiftUI, occupy all available space)
        let totalAvailableHeightForContent = availableBounds.height
        
        // Detect if inside ScrollView
        let isInsideScrollView = isInsideScrollView()
        
        let remainingHeightForSpacers: CGFloat
        if isInsideScrollView {
            // Completely ignore Spacer inside ScrollView
            remainingHeightForSpacers = 0
        } else {
            // Normal case
            remainingHeightForSpacers = max(0, totalAvailableHeightForContent - fixedContentHeight - totalSpacing - totalMinLength)
        }
        
        let finalSpacerHeight: CGFloat
        if isInsideScrollView {
            // Inside ScrollView, Spacer takes only a very small space
            let reasonableSpacerHeight = min(remainingHeightForSpacers / CGFloat(max(spacerCount, 1)), 10) // Limit to maximum 10 points
            finalSpacerHeight = reasonableSpacerHeight
        } else {
            finalSpacerHeight = spacerCount > 0 ? (remainingHeightForSpacers / CGFloat(spacerCount)) : 0
        }
        
        // Calculate starting position for layout
        var currentY: CGFloat = availableBounds.minY
        
        // Layout all subviews
        for subview in subviews {
            // Completely ignore Spacer inside ScrollView
            if isInsideScrollView && subview is Spacer {
                continue
            }
            
            var size: CGSize
            
            // Detect Spacer
            if let spacer = subview as? Spacer {
                let minLength = spacer.minLength ?? 0
                let actualHeight: CGFloat
                
                if isInsideScrollView {
                    // Set Spacer height to 0 inside ScrollView
                    actualHeight = 0
                } else {
                    // Normal case
                    actualHeight = max(finalSpacerHeight + minLength, minLength)
                }
                
                size = CGSize(width: availableBounds.width, height: actualHeight)
            } else {
                // Use the frame calculated from calculateLayout
                if let frame = layoutResult.frames[subview] {
                    size = frame.size
                } else {
                    // Fallback for views not in layoutResult
                    size = CGSize(width: 50, height: 20)
                }
            }
            
            let x: CGFloat
            switch alignment {
            case .leading: x = availableBounds.minX
            case .center: x = availableBounds.midX - size.width / 2
            case .trailing: x = availableBounds.maxX - size.width
            }
            
            let frame = CGRect(x: x, y: currentY, width: max(size.width, 1), height: max(size.height, 1))
            subview.frame = frame
            
            currentY += size.height + spacing
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        var totalHeight: CGFloat = 0
        var maxWidth: CGFloat = 0
        
        // Detect if inside ScrollView
        let isInsideScrollView = isInsideScrollView()
        
        // intrinsicContentSize calculates the natural size without constraints
        // Based on children's intrinsicContentSize, not dependent on bounds
        
        for subview in subviews {
            // Completely ignore Spacer inside ScrollView
            if isInsideScrollView && subview is Spacer {
                continue
            }
            
            var size: CGSize
            
            // Special handling for Spacer
            if subview is Spacer {
                // Spacer takes minimal space in intrinsicContentSize
                size = CGSize(width: 0, height: 0)
            } else if let layoutView = subview as? (any Layout) {
                // Use intrinsicContentSize for Layout views
                size = layoutView.intrinsicContentSize
            } else if let label = subview as? UILabel {
                // Calculate based on text size for UILabel
                let textSize = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
                size = textSize
            } else if let button = subview as? UIButton {
                // Calculate based on button size for UIButton
                let buttonSize = button.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
                size = buttonSize
            } else {
                // Use intrinsicContentSize for other views
                size = subview.intrinsicContentSize
            }
            
            totalHeight += size.height
            maxWidth = max(maxWidth, size.width)
        }
        
        // Add spacing - don't consider Spacer inside ScrollView
        let effectiveSubviews = isInsideScrollView ? subviews.filter { !($0 is Spacer) } : subviews
        if effectiveSubviews.count > 1 {
            totalHeight += spacing * CGFloat(effectiveSubviews.count - 1)
        }
        
        // Add padding
        totalHeight += padding.top + padding.bottom
        maxWidth += padding.left + padding.right
        
        return CGSize(width: maxWidth, height: totalHeight)
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
        var fixedContentHeight: CGFloat = 0
        var spacerCount: Int = 0
        
        for subview in subviews {
            if let layoutView = subview as? (any Layout) {
                let childResult = layoutView.calculateLayout(in: safeBounds)
                frames.merge(childResult.frames) { _, new in new }
                totalSize.width = max(totalSize.width, childResult.totalSize.width)
                fixedContentHeight += childResult.totalSize.height
            } else if subview is Spacer {
                spacerCount += 1
            } else {
                var size: CGSize
                if let label = subview as? UILabel {
                    let textSize = label.sizeThatFits(CGSize(width: safeBounds.width, height: CGFloat.greatestFiniteMagnitude))
                    size = CGSize(width: max(textSize.width, 50), height: max(textSize.height, 20))
                } else if let button = subview as? UIButton {
                    let buttonSize = button.sizeThatFits(CGSize(width: safeBounds.width, height: CGFloat.greatestFiniteMagnitude))
                    size = CGSize(width: max(buttonSize.width, 80), height: max(buttonSize.height, 30))
                } else {
                    let intrinsicSize = subview.intrinsicContentSize
                    size = CGSize(width: max(intrinsicSize.width, 50), height: max(intrinsicSize.height, 20))
                }
                frames[subview] = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                totalSize.width = max(totalSize.width, size.width)
                fixedContentHeight += size.height
            }
        }
        
        // Detect and limit unlimited height
        let maxReasonableHeight: CGFloat = 10000 // 10000pt limit
        if fixedContentHeight > maxReasonableHeight {
            fixedContentHeight = maxReasonableHeight
        }
        
        // Spacer calculation - limit Spacer height if inside ScrollView
        let totalSpacing = subviews.count > 1 ? spacing * CGFloat(subviews.count - 1) : 0
        let remainingHeightForSpacers: CGFloat
        
        if isInsideScrollView {
            // If inside ScrollView, limit Spacer so it doesn't increase actual content size
            let maxSpacerHeight: CGFloat = 10 // Spacer maximum height limit (very small like SwiftUI)
            remainingHeightForSpacers = min(maxSpacerHeight, max(0, safeBounds.height - fixedContentHeight - totalSpacing))
        } else {
            // Normal case
            remainingHeightForSpacers = max(0, safeBounds.height - fixedContentHeight - totalSpacing)
        }
        
        let spacerHeight = spacerCount > 0 ? remainingHeightForSpacers / CGFloat(spacerCount) : 0
        
        // Set calculated size for Spacers
        for subview in subviews {
            if subview is Spacer {
                frames[subview] = CGRect(x: 0, y: 0, width: safeBounds.width, height: spacerHeight)
                totalSize.width = max(totalSize.width, safeBounds.width)
            }
        }
        
        // Calculate total height - limit to not exceed bounds if inside ScrollView
        let finalHeight: CGFloat
        if isInsideScrollView {
            // Inside ScrollView, use actual content height including Spacer height
            let spacerHeight = spacerCount > 0 ? remainingHeightForSpacers / CGFloat(spacerCount) : 0
            let totalSpacerHeight = spacerHeight * CGFloat(spacerCount)
            let contentHeight = fixedContentHeight + totalSpacing + totalSpacerHeight
            finalHeight = min(contentHeight, safeBounds.height)
        } else {
            // Normal case
            finalHeight = min(safeBounds.height, maxReasonableHeight)
        }
        
        totalSize.height = finalHeight
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
        
        // Detect and limit infinite height
        let isInfiniteHeight = bounds.height > 10000 // Consider infinite if over 10000pt
        let maxWidth = min(safeBounds.width, bounds.width)
        let maxHeight = isInfiniteHeight ? 1000 : min(safeBounds.height, bounds.height) // Limit to 1000pt if infinite
        
        for subview in subviews {
            // Completely ignore Spacer inside ScrollView
            if isInsideScrollView && subview is Spacer {
                print("🔧 [VStack] Spacer ignored inside ScrollView")
                continue
            }
            if let layoutView = subview as? (any Layout) {
                // Pass limited size to child layout (prevent infinite)
                let childBounds = CGRect(x: 0, y: 0, width: maxWidth, height: maxHeight)
                let childResult = layoutView.calculateLayout(in: childBounds)
                frames.merge(childResult.frames) { _, new in new }
                
                // Apply size limits
                let limitedWidth = min(childResult.totalSize.width, maxWidth)
                let limitedHeight = min(childResult.totalSize.height, maxHeight)
                totalSize.width = max(totalSize.width, limitedWidth)
                totalSize.height += limitedHeight
            } else {
                // Check if stored ViewLayout information exists
                if let storedViewLayout = getViewLayout(for: subview) {
                    // Call calculateLayout using stored ViewLayout information
                    let viewResult = storedViewLayout.calculateLayout(in: CGRect(x: 0, y: 0, width: maxWidth, height: maxHeight))
                    
                    if let frame = viewResult.frames[subview] {
                        frames[subview] = frame
                        totalSize.width = max(totalSize.width, frame.width)
                        totalSize.height += frame.height

                    } else {
                        // Fallback: use existing logic
                        var size: CGSize
                        if let label = subview as? UILabel {
                            let textSize = label.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
                            size = CGSize(width: min(textSize.width, maxWidth), height: max(textSize.height, 20))
                        } else if let button = subview as? UIButton {
                            let buttonSize = button.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
                            size = CGSize(width: min(buttonSize.width, maxWidth), height: max(buttonSize.height, 30))
                        } else {
                            let intrinsicSize = subview.intrinsicContentSize
                            size = CGSize(width: min(intrinsicSize.width, maxWidth), height: max(intrinsicSize.height, 20))
                        }
                        frames[subview] = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                        totalSize.width = max(totalSize.width, size.width)
                        totalSize.height += size.height
                    }
                } else {
                    // Use existing logic if no stored ViewLayout information
                    var size: CGSize
                    if let label = subview as? UILabel {
                        let textSize = label.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
                        size = CGSize(width: min(textSize.width, maxWidth), height: max(textSize.height, 20))
                    } else if let button = subview as? UIButton {
                        let buttonSize = button.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
                        size = CGSize(width: min(buttonSize.width, maxWidth), height: max(buttonSize.height, 30))
                    } else {
                        let intrinsicSize = subview.intrinsicContentSize
                        size = CGSize(width: min(intrinsicSize.width, maxWidth), height: max(intrinsicSize.height, 20))
                    }
                    frames[subview] = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                    totalSize.width = max(totalSize.width, size.width)
                    totalSize.height += size.height
                }
            }
        }
        
        // Add spacing - don't consider Spacer inside ScrollView
        let effectiveSubviews = isInsideScrollView ? subviews.filter { !($0 is Spacer) } : subviews
        if effectiveSubviews.count > 1 {
            totalSize.height += spacing * CGFloat(effectiveSubviews.count - 1)
        }
        
        // Add padding
        totalSize.width += padding.left + padding.right
        totalSize.height += padding.top + padding.bottom
        
        // Detect and limit unlimited height
        let maxReasonableHeight: CGFloat = 10000 // 10000pt limit
        if totalSize.height > maxReasonableHeight {
            totalSize.height = maxReasonableHeight
        }
        
        // Use full width if alignment is set
        if alignment != .leading {
            totalSize.width = bounds.width
        } else {
            // Apply final size limits
            totalSize.width = min(totalSize.width, bounds.width)
        }
        totalSize.height = min(totalSize.height, bounds.height)
        
        frames[self] = CGRect(x: 0, y: 0, width: totalSize.width, height: totalSize.height)
        
        return LayoutResult(frames: frames, totalSize: totalSize)
    }

    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        
        // Check if Spacer exists
        let hasSpacers = subviews.contains { $0 is Spacer }
        
        // Detect if inside ScrollView
        let isInsideScrollView = isInsideScrollView()
        
        if hasSpacers && isInsideScrollView {
            // If Spacer exists inside ScrollView: ignore Spacer and calculate only actual content
            print("🔧 [VStack] Spacer detected inside ScrollView - switching to WithoutSpacer mode")
            return calculateLayoutWithoutSpacers(in: bounds)
        } else if hasSpacers {
            // Normal case when Spacer exists
            return calculateLayoutWithSpacers(in: bounds)
        } else {
            // When Spacer doesn't exist
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
        
        // Consider inside ScrollView if bounds.height is very large
        if bounds.height > 1000 {
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
    
    public func alignment(_ alignment: HorizontalAlignment) -> Self {
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
