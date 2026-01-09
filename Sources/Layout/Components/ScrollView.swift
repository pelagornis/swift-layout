import UIKit

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
        let expectedContentSize: CGSize
        switch axis {
        case .vertical:
            expectedContentSize = CGSize(width: bounds.width, height: calculateActualContentHeight())
        case .horizontal:
            expectedContentSize = CGSize(width: calculateActualContentWidth(), height: bounds.height)
        }
        
        let currentOffset = contentOffset
        
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
        
        // Update layout based on scroll axis
        switch axis {
        case .vertical:
            updateVerticalLayout(layout, expectedSize: expectedContentSize, currentOffset: currentOffset)
        case .horizontal:
            updateHorizontalLayout(layout, expectedSize: expectedContentSize, currentOffset: currentOffset)
        }
        
        cachedContentSize = expectedContentSize
        cachedBounds = normalizedBounds
    }
    
    /// Updates vertical scroll layout and preserves scroll position
    private func updateVerticalLayout(_ layout: any Layout, expectedSize: CGSize, currentOffset: CGPoint) {
        let actualContentHeight = expectedSize.height
        let contentBounds = CGRect(x: 0, y: 0, width: bounds.width, height: actualContentHeight)
        let result = layout.calculateLayout(in: contentBounds)
        
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
    private func updateHorizontalLayout(_ layout: any Layout, expectedSize: CGSize, currentOffset: CGPoint) {
        let actualContentWidth = expectedSize.width
        let contentBounds = CGRect(x: 0, y: 0, width: actualContentWidth, height: bounds.height)
        let result = layout.calculateLayout(in: contentBounds)

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
    
    /// Returns only ScrollView itself in the layout result
    /// Internal content views are managed separately by updateContentLayout()
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        if bounds.width == 0 || bounds.height == 0 {
            return LayoutResult(frames: [self: bounds], totalSize: bounds.size)
        }
        return LayoutResult(frames: [self: bounds], totalSize: bounds.size)
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
    private func calculateActualContentHeight() -> CGFloat {
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
    private func calculateActualContentWidth() -> CGFloat {
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
