#if canImport(UIKit)
import UIKit

#endif
/// A scrollable container view that enables scrolling when content exceeds available space.
public class ScrollView: UIScrollView, Layout {
    public typealias Body = Never
    
    public var body: Never {
        fatalError("ScrollView body should not be called")
    }
    
    /// Container view that holds all scrollable content
    private let contentView = UIView()
    
    /// The child layout to be displayed inside the scroll view
    private var childLayout: (any Layout)?
    
    /// Cached content size to avoid unnecessary layout recalculations
    private var cachedContentSize: CGSize = .zero
    
    /// Cached bounds to detect when layout needs to be recalculated
    private var cachedBounds: CGRect = .zero

    /// Scroll direction (vertical or horizontal)
    public var axis: Axis = .vertical
    public enum Axis {
        case vertical, horizontal
    }
    
    /// Whether to adjust content offset for safe area insets
    /// When true, the scroll view will preserve negative offsets that account for safe area
    /// Note: UIScrollView automatically handles offset clamping, so we just preserve the current offset
    public var adjustsContentOffsetForSafeArea: Bool = false
    
    public override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        if adjustsContentOffsetForSafeArea {
            setNeedsLayout()
        }
    }
    
    // MARK: - Child Layout Management
    
    /// Returns the current child layout managed by this ScrollView.
    /// Used by LayoutContainer for identity-based updates.
    public func getChildLayout() -> (any Layout)? {
        return childLayout
    }
    
    /// Updates the child layout when ScrollView is reused during layout updates.
    /// Preserves scroll offset and only updates views if they actually changed.
    public func updateChildLayout(_ layout: any Layout) {
        let oldViews = childLayout?.extractViews() ?? []
        let newViews = layout.extractViews()
        
        let viewsChanged = oldViews.count != newViews.count || 
                          !oldViews.elementsEqual(newViews, by: { $0 === $1 })
        
        childLayout = layout
        
        if viewsChanged {
            // Invalidate cache when views change to force layout recalculation
            cachedContentSize = .zero
            cachedBounds = .zero
            
            contentView.subviews.forEach { $0.removeFromSuperview() }
            for view in newViews {
                contentView.addSubview(view)
            }
            updateContentLayout()
        } else {
            // Even if views haven't changed, we should update the layout
            // because the content might have changed (e.g., item order, counts)
            // But don't invalidate cache in this case - let updateContentLayout decide
            updateContentLayout()
        }
    }
    
    public init(_ axis: Axis = .vertical, @LayoutBuilder content: () -> any Layout) {
        self.axis = axis
        super.init(frame: .zero)
        
        setupScrollView()
        setContent(content())
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupScrollView()
    }
    
    /// Configures scroll view properties based on axis
    private func setupScrollView() {
        switch axis {
        case .vertical:
            showsVerticalScrollIndicator = true
            showsHorizontalScrollIndicator = false
            alwaysBounceVertical = true
            alwaysBounceHorizontal = false
        case .horizontal:
            showsVerticalScrollIndicator = false
            showsHorizontalScrollIndicator = true
            alwaysBounceVertical = false
            alwaysBounceHorizontal = true
        }

        contentView.backgroundColor = .clear
        addSubview(contentView)
        contentView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 0)
    }
    
    /// Sets the content layout (called during init or when content changes)
    private func setContent(_ layout: any Layout) {
        // If childLayout already exists, this is a reuse scenario (e.g., during layout updates)
        // Only update views if they actually changed to preserve scroll offset
        if childLayout != nil {
            let oldViews = childLayout?.extractViews() ?? []
            let newViews = layout.extractViews()
            let viewsChanged = oldViews.count != newViews.count || 
                              !oldViews.elementsEqual(newViews, by: { $0 === $1 })
            
            if viewsChanged {
                childLayout = layout
                contentView.subviews.forEach { $0.removeFromSuperview() }
                for view in newViews {
                    contentView.addSubview(view)
                }
                updateContentLayout()
            } else {
                childLayout = layout
            }
            return
        }
        
        // Initial setup: reset cache and add all views
        childLayout = layout
        cachedContentSize = .zero
        cachedBounds = .zero
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let views = layout.extractViews()
        for view in views {
            contentView.addSubview(view)
        }
        
        updateContentLayout()
    }
    
    /// Updates the content layout and applies frames to child views
    /// Uses caching to avoid unnecessary recalculations when bounds/content size haven't changed
    private func updateContentLayout() {
        guard let layout = childLayout else { 
            return 
        }
        if bounds.width == 0 || bounds.height == 0 { 
            return 
        }
        
        // Normalize bounds (UIScrollView's bounds.origin is negative of contentOffset)
        let normalizedBounds = CGRect(origin: .zero, size: bounds.size)
        
        // Calculate content size and layout result in one pass to avoid duplicate calculations
        let currentOffset = contentOffset
        let (expectedContentSize, preCalculatedResult): (CGSize, LayoutResult?)
        switch axis {
        case .vertical:
            let (height, result) = calculateActualContentHeightWithResult()
            expectedContentSize = CGSize(width: bounds.width, height: height)
            preCalculatedResult = result
        case .horizontal:
            let (width, result) = calculateActualContentWidthWithResult()
            expectedContentSize = CGSize(width: width, height: bounds.height)
            preCalculatedResult = result
        }
        
        // Check if bounds or content size changed
        let boundsChanged = cachedBounds.size != normalizedBounds.size
        let contentSizeChanged = cachedContentSize != expectedContentSize
        let shouldSkipLayout = !boundsChanged && !contentSizeChanged
        
        if shouldSkipLayout {
            // Still update contentView.frame and contentSize to ensure they're correct
            // This is important when ScrollView's frame changes but content size doesn't
            switch axis {
            case .vertical:
                let newContentViewFrame = CGRect(x: 0, y: 0, width: bounds.width, height: expectedContentSize.height)
                if contentView.frame != newContentViewFrame {
                    contentView.frame = newContentViewFrame
                }
            case .horizontal:
                let newContentViewFrame = CGRect(x: 0, y: 0, width: expectedContentSize.width, height: bounds.height)
                if contentView.frame != newContentViewFrame {
                    contentView.frame = newContentViewFrame
                }
            }
            if contentSize != expectedContentSize {
                contentSize = expectedContentSize
                // Preserve current offset when contentSize changes
                // UIScrollView will automatically clamp the offset to valid range
                // We just need to preserve the current value (including negative for safe area/bounce)
                if axis == .vertical {
                    contentOffset.y = currentOffset.y
                } else {
                    contentOffset.x = currentOffset.x
                }
            }
            return
        }
        
        // Update layout based on scroll axis, reuse pre-calculated result if available
        switch axis {
        case .vertical:
            updateVerticalLayout(layout, expectedSize: expectedContentSize, currentOffset: currentOffset, preCalculatedResult: preCalculatedResult)
        case .horizontal:
            updateHorizontalLayout(layout, expectedSize: expectedContentSize, currentOffset: currentOffset, preCalculatedResult: preCalculatedResult)
        }
        
        cachedContentSize = expectedContentSize
        cachedBounds = normalizedBounds
    }
    
    /// Updates vertical scroll layout and preserves scroll position
    private func updateVerticalLayout(_ layout: any Layout, expectedSize: CGSize, currentOffset: CGPoint, preCalculatedResult: LayoutResult? = nil) {
        let actualContentHeight = expectedSize.height
        let contentBounds = CGRect(x: 0, y: 0, width: bounds.width, height: actualContentHeight)
        // Reuse pre-calculated result if available and bounds match, otherwise recalculate
        let result: LayoutResult
        if let preCalculated = preCalculatedResult, preCalculated.totalSize.height == actualContentHeight {
            result = preCalculated
        } else {
            result = layout.calculateLayout(in: contentBounds)
        }
        
        contentView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: actualContentHeight)
        
        // Apply frames to child views
        let contentViews = layout.extractViews()
        for (view, frame) in result.frames {
            if contentViews.contains(view) {
                view.frame = frame
            }
        }

        contentSize = expectedSize
        
        // Preserve scroll offset after contentSize is set
        // Simply preserve the current offset - UIScrollView handles clamping automatically
        // The offset can be negative for bounce/safe area, and UIScrollView will handle it
        contentOffset.y = currentOffset.y
    }
    
    /// Updates horizontal scroll layout and preserves scroll position
    private func updateHorizontalLayout(_ layout: any Layout, expectedSize: CGSize, currentOffset: CGPoint, preCalculatedResult: LayoutResult? = nil) {
        let actualContentWidth = expectedSize.width
        let contentBounds = CGRect(x: 0, y: 0, width: actualContentWidth, height: bounds.height)
        // Reuse pre-calculated result if available and bounds match, otherwise recalculate
        let result: LayoutResult
        if let preCalculated = preCalculatedResult, preCalculated.totalSize.width == actualContentWidth {
            result = preCalculated
        } else {
            result = layout.calculateLayout(in: contentBounds)
        }

        contentView.frame = CGRect(x: 0, y: 0, width: actualContentWidth, height: bounds.height)

        // Apply frames to child views
        let contentViews = layout.extractViews()
        for (view, frame) in result.frames {
            if contentViews.contains(view) {
                view.frame = frame
            }
        }

        contentSize = expectedSize
        
        // Preserve scroll offset after contentSize is set
        // Simply preserve the current offset - UIScrollView handles clamping automatically
        contentOffset.x = currentOffset.x
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.width == 0 || bounds.height == 0 { return }
        updateContentLayout()
    }
    
    // MARK: - Layout Protocol
    
    /// Calculates the layout of ScrollView and its content
    /// Returns ScrollView's frame and the actual content size
    /// Internal content views are managed separately by updateContentLayout()
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        var frames: [UIView: CGRect] = [:]
        frames[self] = bounds
        
        // If bounds are invalid or no child layout, return bounds size
        if bounds.width == 0 || bounds.height == 0 {
            return LayoutResult(frames: frames, totalSize: bounds.size)
        }
        
        guard let layout = childLayout else {
            return LayoutResult(frames: frames, totalSize: bounds.size)
        }
        
        // Calculate actual content size based on axis
        let contentSize: CGSize
        switch axis {
        case .vertical:
            let contentHeight = calculateContentHeight(layout: layout, availableWidth: bounds.width)
            contentSize = CGSize(width: bounds.width, height: max(contentHeight, bounds.height))
        case .horizontal:
            let contentWidth = calculateContentWidth(layout: layout, availableHeight: bounds.height)
            contentSize = CGSize(width: max(contentWidth, bounds.width), height: bounds.height)
        }
        
        return LayoutResult(frames: frames, totalSize: contentSize)
    }
    
    /// Calculates content height for a given layout and available width
    private func calculateContentHeight(layout: any Layout, availableWidth: CGFloat) -> CGFloat {
        // Check if layout is directly a VStack
        if let vStack = layout as? VStack {
            let availableBounds = CGRect(x: 0, y: 0, width: availableWidth, height: CGFloat.greatestFiniteMagnitude)
            return vStack.calculateLayout(in: availableBounds).totalSize.height
        }
        
        // Check if layout is a TupleLayout containing a VStack
        if let tupleLayout = layout as? TupleLayout {
            for childLayout in tupleLayout.layouts {
                if let vStack = childLayout as? VStack {
                    let availableBounds = CGRect(x: 0, y: 0, width: availableWidth, height: CGFloat.greatestFiniteMagnitude)
                    return vStack.calculateLayout(in: availableBounds).totalSize.height
                }
            }
        }
        
        // Check if extractViews() returns a VStack (VStack.extractViews() returns [self])
        let views = layout.extractViews()
        for view in views {
            if let vStack = view as? VStack {
                let availableBounds = CGRect(x: 0, y: 0, width: availableWidth, height: CGFloat.greatestFiniteMagnitude)
                return vStack.calculateLayout(in: availableBounds).totalSize.height
            }
        }
        
        // Fallback: calculate layout directly with unlimited height
        let availableBounds = CGRect(x: 0, y: 0, width: availableWidth, height: CGFloat.greatestFiniteMagnitude)
        let result = layout.calculateLayout(in: availableBounds)
        return result.totalSize.height
    }
    
    /// Calculates content width for a given layout and available height
    private func calculateContentWidth(layout: any Layout, availableHeight: CGFloat) -> CGFloat {
        // Check if layout is directly an HStack
        if let hStack = layout as? HStack {
            let availableBounds = CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: availableHeight)
            return hStack.calculateLayout(in: availableBounds).totalSize.width
        }
        
        // Check if layout is a TupleLayout containing an HStack
        if let tupleLayout = layout as? TupleLayout {
            for childLayout in tupleLayout.layouts {
                if let hStack = childLayout as? HStack {
                    let availableBounds = CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: availableHeight)
                    return hStack.calculateLayout(in: availableBounds).totalSize.width
                }
            }
        }
        
        // Check if extractViews() returns an HStack (HStack.extractViews() returns [self])
        let views = layout.extractViews()
        for view in views {
            if let hStack = view as? HStack {
                let availableBounds = CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: availableHeight)
                return hStack.calculateLayout(in: availableBounds).totalSize.width
            }
        }
        
        // Fallback: calculate layout directly with unlimited width
        let availableBounds = CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: availableHeight)
        let result = layout.calculateLayout(in: availableBounds)
        return result.totalSize.width
    }
    
    public func extractViews() -> [UIView] {
        return [self]
    }
    
    public override var intrinsicContentSize: CGSize {
        guard childLayout != nil else {
            return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
        }
        
        switch axis {
        case .vertical:
            return CGSize(width: bounds.width, height: calculateActualContentHeight())
        case .horizontal:
            return CGSize(width: calculateActualContentWidth(), height: bounds.height)
        }
    }
    
    // MARK: - Private Methods
    
    /// Calculates the actual content height by finding and measuring VStack
    /// Returns both height and the layout result to avoid duplicate calculations
    private func calculateActualContentHeightWithResult() -> (CGFloat, LayoutResult?) {
        guard let layout = childLayout else { return (0, nil) }
        
        // Use calculateContentHeight which already handles VStack optimization
        let availableWidth = bounds.width
        let availableBounds = CGRect(x: 0, y: 0, width: availableWidth, height: CGFloat.greatestFiniteMagnitude)
        
        // Try to get result directly from layout calculation
        let result = layout.calculateLayout(in: availableBounds)
        let height = result.totalSize.height
        
        return (height, result)
    }
    
    /// Calculates the actual content height by finding and measuring VStack
    private func calculateActualContentHeight() -> CGFloat {
        return calculateActualContentHeightWithResult().0
    }
    
    /// Fallback method for direct contentView check (kept for compatibility)
    private func calculateActualContentHeightFallback() -> CGFloat {
        guard let layout = childLayout else { return 0 }
        
        let views = layout.extractViews()
        for view in views {
            if let vStack = view as? VStack {
                return calculateVStackContentHeight(vStack)
            }
        }
        
        // Fallback: check contentView directly
        if let vStack = contentView.subviews.first as? VStack {
            return calculateVStackContentHeight(vStack)
        }
        
        return layout.intrinsicContentSize.height
    }
    
    /// Calculates the actual content width by finding and measuring HStack
    /// Returns both width and the layout result to avoid duplicate calculations
    private func calculateActualContentWidthWithResult() -> (CGFloat, LayoutResult?) {
        guard let layout = childLayout else { return (0, nil) }
        
        // Use calculateContentWidth which already handles HStack optimization
        let availableHeight = bounds.height
        let availableBounds = CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: availableHeight)
        
        // Try to get result directly from layout calculation
        let result = layout.calculateLayout(in: availableBounds)
        let width = result.totalSize.width
        
        return (width, result)
    }
    
    /// Calculates the actual content width by finding and measuring HStack
    private func calculateActualContentWidth() -> CGFloat {
        return calculateActualContentWidthWithResult().0
    }
    
    /// Fallback method for direct contentView check (kept for compatibility)
    private func calculateActualContentWidthFallback() -> CGFloat {
        guard let layout = childLayout else { return 0 }
        
        let views = layout.extractViews()
        for view in views {
            if let hStack = view as? HStack {
                return calculateHStackContentWidth(hStack)
            }
        }
        
        // Fallback: check contentView directly
        if let hStack = contentView.subviews.first as? HStack {
            return calculateHStackContentWidth(hStack)
        }
        
        return layout.intrinsicContentSize.width
    }
    
    /// Calculates VStack's content height using layout system
    private func calculateVStackContentHeight(_ vStack: VStack) -> CGFloat {
        let availableBounds = CGRect(x: 0, y: 0, width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        return vStack.calculateLayout(in: availableBounds).totalSize.height
    }
    
    /// Calculates HStack's content width using layout system
    private func calculateHStackContentWidth(_ hStack: HStack) -> CGFloat {
        let availableBounds = CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: bounds.height)
        return hStack.calculateLayout(in: availableBounds).totalSize.width
    }
}
