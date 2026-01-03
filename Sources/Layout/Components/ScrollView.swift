import UIKit

/// A scrollable container view that allows content to be scrolled when it exceeds the available space.
///
/// ``ScrollView`` provides scrolling functionality similar to SwiftUI's ScrollView,
/// automatically enabling scrolling when content is larger than the available bounds.
///
/// ## Overview
///
/// `ScrollView` is a container that enables scrolling when its content exceeds
/// the available space. It extends `UIScrollView` and provides a declarative
/// interface for creating scrollable layouts.
///
/// ## Key Features
///
/// - **Automatic Scrolling**: Enables scrolling when content is larger than bounds
/// - **Axis Support**: Supports both vertical and horizontal scrolling
/// - **Scroll Indicators**: Configurable scroll indicator visibility
/// - **Content Insets**: Support for content insets and padding
/// - **Layout Integration**: Seamlessly works with other layout components
///
/// ## Example Usage
///
/// ```swift
/// ScrollView {
///     VStack(spacing: 20) {
///         ForEach(0..<20) { index in
///             Text("Item \(index)")
///                 .frame(height: 60)
///         }
///     }
/// }
/// ```
///
/// ## Topics
///
/// ### Initialization
/// - ``init(_:content:)``
///
/// ### Configuration
/// - ``showsVerticalScrollIndicator``
/// - ``showsHorizontalScrollIndicator``
/// - ``contentInset``
/// - ``axis``
///
/// ### Layout Behavior
/// - ``calculateLayout(in:)``
/// - ``extractViews()``
/// - ``intrinsicContentSize``
public class ScrollView: UIScrollView, Layout {
    public typealias Body = Never
    
    public var body: Never {
        fatalError("ScrollView body should not be called")
    }
    
    /// The content view that holds the scrollable content
    private let contentView = UIView()
    
    /// The child layout
    private var childLayout: (any Layout)?
    
    /// Gets the current child layout (for LayoutContainer to update during reuse)
    internal func getChildLayout() -> (any Layout)? {
        return childLayout
    }
    
    /// Updates the child layout without resetting scroll offset or cache
    /// This should be called when the ScrollView instance is reused during layout updates
    internal func updateChildLayout(_ layout: any Layout) {
        // Get old views before updating
        let oldViews = childLayout?.extractViews() ?? []
        let newViews = layout.extractViews()
        
        // Check if views actually changed
        let viewsChanged = oldViews.count != newViews.count || 
                          !oldViews.elementsEqual(newViews, by: { $0 === $1 })
        
        // Update childLayout reference
        childLayout = layout
        
        // Only update views if they actually changed
        if viewsChanged {
            // Remove all old views from contentView FIRST
            // This must be done synchronously to ensure old views are completely removed
            // before new views are added, preventing visual artifacts/ghosting
            let viewsToRemove = contentView.subviews
            for view in viewsToRemove {
                view.removeFromSuperview()
            }
            
            // Ensure views are removed from the hierarchy immediately
            // Force layout to update before adding new views
            contentView.setNeedsLayout()
            contentView.layoutIfNeeded()
            
            // Extract views from new layout and add to contentView
            for view in newViews {
                contentView.addSubview(view)
            }
            
            // Trigger layout update - updateContentLayout will handle scroll offset preservation
            // It will use the current contentOffset as the base for preservation
            updateContentLayout()
        }
        // If views haven't changed, no need to update anything
    }
    
    /// Cached content size to detect changes
    private var cachedContentSize: CGSize = .zero
    
    /// Cached bounds to detect changes
    private var cachedBounds: CGRect = .zero
    
    /// Flag to prevent recursive calls to updateContentLayout
    private var isUpdatingContentLayout: Bool = false
    
    /// Scroll axis
    public var axis: Axis = .vertical
    
    /// Scroll axis options
    public enum Axis {
        case vertical, horizontal
    }
    
    /// Creates a ScrollView with the specified content
    /// - Parameters:
    ///   - axis: The scroll axis (vertical or horizontal)
    ///   - content: A closure that returns the scrollable content
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
    
    private func setupScrollView() {
        // Configure scroll view based on axis
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

        // Configure content view
        contentView.backgroundColor = .clear
        
        // Add content view to scroll view (self)
        addSubview(contentView)
        
        // Set initial contentView frame
        contentView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 0)
    }
    
    private func setContent(_ layout: any Layout) {
        // setContent should only be called during init, not during layout updates
        // If childLayout already exists, this means ScrollView is being reused
        // In this case, we should NOT reset cache or views - just update the layout reference
        // This preserves scroll offset and existing views during layout updates
        if childLayout != nil {
            print("⚠️ [ScrollView] setContent called when childLayout already exists - preserving scroll offset and views")
            // Preserve scroll offset before updating
            let savedOffset = contentOffset
            print("  - Preserving scroll offset: \(savedOffset)")
            
            // Check if the layout content actually changed by comparing extracted views
            let oldViews = childLayout?.extractViews() ?? []
            let newViews = layout.extractViews()
            
            // Only update views if they actually changed
            let viewsChanged = oldViews.count != newViews.count || 
                              !oldViews.elementsEqual(newViews, by: { $0 === $1 })
            
            if viewsChanged {
                print("  - Views changed, updating content")
                // Update the layout reference
                childLayout = layout
                
                // Update views - remove old ones and add new ones
                contentView.subviews.forEach { $0.removeFromSuperview() }
                for view in newViews {
                    contentView.addSubview(view)
                }
                
                // Update layout - this will recalculate and apply frames
                updateContentLayout()
                
                // Restore scroll offset after layout update
                if abs(savedOffset.y) > 0.1 {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        if abs(self.contentOffset.y - savedOffset.y) > 10 {
                            print("  - 🔄 Restoring scroll offset from \(self.contentOffset.y) to \(savedOffset.y)")
                            self.contentOffset.y = savedOffset.y
                        }
                    }
                }
            } else {
                print("  - Views unchanged, skipping layout update")
                // Views haven't changed, just update the layout reference
                // Don't call updateContentLayout to avoid unnecessary recalculation
                // This preserves the existing layout and scroll offset
                childLayout = layout
            }
            return
        }
        
        childLayout = layout
        
        // Reset cache when content changes (only during initial setup)
        cachedContentSize = .zero
        cachedBounds = .zero
        
        // Remove existing content
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        // Extract views from layout
        let views = layout.extractViews()
        
        // Add views to content view
        for view in views {
            contentView.addSubview(view)
        }
        
        // Update layout (this will preserve scroll offset if needed)
        updateContentLayout()
    }
    
    private func updateContentLayout() {
        guard let layout = childLayout else { return }
                
        // Handle zero bounds case
        if bounds.width == 0 || bounds.height == 0 {
            return
        }
        
        // Calculate expected content size first to check if layout is needed
        let expectedContentSize: CGSize
        switch axis {
        case .vertical:
            let height = calculateActualContentHeight()
            expectedContentSize = CGSize(width: bounds.width, height: height)
        case .horizontal:
            let width = calculateActualContentWidth()
            expectedContentSize = CGSize(width: width, height: bounds.height)
        }
        
        // Normalize bounds for comparison (bounds origin should always be (0,0))
        // UIScrollView's bounds.origin is the negative of contentOffset, so we normalize it
        let normalizedBounds = CGRect(origin: .zero, size: bounds.size)
        
        // Store current scroll offset before any changes (need this even if we skip layout)
        let currentOffset = contentOffset
        
        // Only log when layout will actually update (not during scrolling when nothing changed)
        let boundsChanged = cachedBounds.size != normalizedBounds.size
        let contentSizeChanged = cachedContentSize != expectedContentSize
        if boundsChanged || contentSizeChanged {
            print("📜 [ScrollView] updateContentLayout:")
            print("  - cachedBounds: \(cachedBounds)")
            print("  - bounds: \(bounds)")
            print("  - normalizedBounds: \(normalizedBounds)")
            print("  - cachedContentSize: \(cachedContentSize)")
            print("  - expectedContentSize: \(expectedContentSize)")
            print("  - bounds.size changed: \(boundsChanged)")
            print("  - contentSize changed: \(contentSizeChanged)")
            print("  - currentScrollOffset before layout: \(currentOffset)")
            print("  - oldOffset.y: \(currentOffset.y)")
        }
        
        // Skip layout if bounds size and content size haven't changed
        if cachedBounds.size == normalizedBounds.size && cachedContentSize == expectedContentSize {
            // Only update contentSize if it doesn't match (shouldn't happen, but safety check)
            if contentSize != expectedContentSize {
                contentSize = expectedContentSize
            }
            // Even when skipping layout, preserve scroll offset to prevent UIScrollView from resetting it
            // Use async to ensure it's applied after any automatic adjustments
            if abs(currentOffset.y) > 0.1 {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if abs(self.contentOffset.y - currentOffset.y) > 0.1 {
                        print("  - 🔄 Restoring scroll offset: \(currentOffset.y) (current: \(self.contentOffset.y))")
                        self.contentOffset.y = currentOffset.y
                    }
                }
            }
            return
        }
        
        // Calculate layout differently based on axis
        switch axis {
        case .vertical:
            updateVerticalLayout(layout, expectedSize: expectedContentSize, currentOffset: currentOffset)
        case .horizontal:
            updateHorizontalLayout(layout, expectedSize: expectedContentSize, currentOffset: currentOffset)
        }
        
        // Cache the values (normalize bounds to ensure origin is always (0,0))
        cachedContentSize = expectedContentSize
        cachedBounds = normalizedBounds
        
        print("  - scrollView.contentOffset after layout: \(contentOffset)")
        print("  - ✅ Layout update complete")
    }
    
    private func updateVerticalLayout(_ layout: any Layout, expectedSize: CGSize, currentOffset: CGPoint) {
        let actualContentHeight = expectedSize.height
        
        // Set contentBounds with actual content height
        let contentBounds = CGRect(x: 0, y: 0, width: bounds.width, height: actualContentHeight)
        let result = layout.calculateLayout(in: contentBounds)
        
        // Get old content height for scroll position preservation
        let oldContentHeight = cachedContentSize.height
        
        // Calculate the scroll offset we want to preserve BEFORE changing contentSize
        // UIScrollView automatically adjusts offset when contentSize changes, so we need to
        // calculate and apply the desired offset after setting contentSize
        let hasExistingScrollOffset = abs(currentOffset.y) > 0.1
        let desiredOffset: CGFloat?
        if oldContentHeight > 0 || hasExistingScrollOffset {
            let maxOffset = actualContentHeight - bounds.height
            if currentOffset.y < 0 {
                desiredOffset = currentOffset.y
            } else {
                desiredOffset = min(currentOffset.y, maxOffset)
            }
        } else {
            desiredOffset = nil
        }
        
        // Set contentView frame
        contentView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: actualContentHeight)
        
        // Apply child views' frames
        let contentViews = layout.extractViews()
        for (view, frame) in result.frames {
            if contentViews.contains(view) {
                view.frame = frame
            }
        }
        
        // Set contentSize - this may cause UIScrollView to adjust offset automatically
        contentSize = expectedSize
        
        // Immediately restore the desired scroll offset if we calculated one
        if let offset = desiredOffset {
            contentOffset.y = offset
        }
        
        // Debug logging for scroll offset preservation
        print("📜 [ScrollView] updateVerticalLayout:")
        print("  - oldContentHeight: \(oldContentHeight)")
        print("  - currentOffset.y (before): \(currentOffset.y)")
        print("  - oldOffset.y: \(currentOffset.y) (same as currentOffset before layout)")
        print("  - actualContentHeight: \(actualContentHeight)")
        print("  - bounds.height: \(bounds.height)")
        print("  - desiredOffset: \(desiredOffset?.description ?? "nil")")
        print("  - contentOffset.y (after): \(contentOffset.y)")
    }
    
    private func updateHorizontalLayout(_ layout: any Layout, expectedSize: CGSize, currentOffset: CGPoint) {
        let actualContentWidth = expectedSize.width

        // Set contentBounds with actual content width
        let contentBounds = CGRect(x: 0, y: 0, width: actualContentWidth, height: bounds.height)
        let result = layout.calculateLayout(in: contentBounds)

        // Get old content width for scroll position preservation
        let oldContentWidth = cachedContentSize.width

        // Set contentView frame
        contentView.frame = CGRect(x: 0, y: 0, width: actualContentWidth, height: bounds.height)

        // Apply child views' frames
        let contentViews = layout.extractViews()
        for (view, frame) in result.frames {
            if contentViews.contains(view) {
                view.frame = frame
            }
        }

        // Set contentSize first
        contentSize = expectedSize
        
        // Only adjust scroll position if content size actually changed (not first layout)
        // UIScrollView automatically maintains offset when contentSize changes, but we
        // need to ensure it's within valid bounds if content size decreased
        if oldContentWidth > 0 && actualContentWidth != oldContentWidth {
            let maxOffset = max(0, actualContentWidth - bounds.width)
            let newOffset = min(currentOffset.x, maxOffset)
            
            // Only update offset if it's different and would be out of bounds
            if newOffset < currentOffset.x || abs(contentOffset.x - newOffset) > 0.1 {
                contentOffset.x = newOffset
            }
        }
        // First layout: don't touch offset, let UIScrollView handle it (defaults to 0)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // Handle zero bounds case
        if bounds.width == 0 || bounds.height == 0 {
            return
        }
        
        // Update content layout
        updateContentLayout()
    }
    
    // MARK: - Layout Protocol
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        // IMPORTANT: ScrollView only returns itself in the frames dictionary
        // Internal content views are managed by ScrollView's updateContentLayout method
        // This prevents LayoutContainer from applying frames to internal views,
        // which would conflict with ScrollView's own layout management
        
        // Handle zero bounds case
        if bounds.width == 0 || bounds.height == 0 {
            return LayoutResult(frames: [self: bounds], totalSize: bounds.size)
        }
        
        // ScrollView itself takes the full bounds
        // We do NOT include internal content views here - they are managed separately
        // by updateContentLayout() and updateVerticalLayout()/updateHorizontalLayout()
        return LayoutResult(frames: [self: bounds], totalSize: bounds.size)
    }
    
    public func extractViews() -> [UIView] {
        return [self]
    }
    
    // MARK: - Intrinsic Content Size
    
    public override var intrinsicContentSize: CGSize {
        guard childLayout != nil else {
            return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
        }
        
        // Calculate size differently based on axis
        switch axis {
        case .vertical:
            let actualHeight = calculateActualContentHeight()
            return CGSize(width: bounds.width, height: actualHeight)
        case .horizontal:
            let actualWidth = calculateActualContentWidth()
            return CGSize(width: actualWidth, height: bounds.height)
        }
    }
    
    // MARK: - Public Properties
    // All UIScrollView properties (showsVerticalScrollIndicator, showsHorizontalScrollIndicator, contentInset, etc.) are directly available
    
    // MARK: - Private Methods
    
    /// Calculate actual content height using Manual Layout (frame calculations)
    private func calculateActualContentHeight() -> CGFloat {
        
        guard let layout = childLayout else {
            return 0
        }
        
        // Extract actual UIView from ViewLayout
        let views = layout.extractViews()
        
        // Find VStack directly
        for view in views {
            if let vStack = view as? VStack {
                return calculateVStackContentHeight(vStack)
            }
        }
        
        // If VStack not found, find it directly from contentView
        if let vStack = contentView.subviews.first as? VStack {
            return calculateVStackContentHeight(vStack)
        }
        
        // Default fallback
        return layout.intrinsicContentSize.height
    }
    
    /// Calculate actual content width using Manual Layout (frame calculations)
    private func calculateActualContentWidth() -> CGFloat {
        
        guard let layout = childLayout else {
            return 0
        }
        
        // Extract actual UIView from ViewLayout
        let views = layout.extractViews()
        
        // Find HStack directly
        for view in views {
            if let hStack = view as? HStack {
                return calculateHStackContentWidth(hStack)
            }
        }
        
        // If HStack not found, find it directly from contentView
        if let hStack = contentView.subviews.first as? HStack {
            return calculateHStackContentWidth(hStack)
        }
        
        // Default fallback
        return layout.intrinsicContentSize.width
    }
    
    /// Calculate actual content height of VStack
    private func calculateVStackContentHeight(_ vStack: VStack) -> CGFloat {
        // Call VStack's calculateLayout for accurate layout calculation
        let availableBounds = CGRect(x: 0, y: 0, width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let layoutResult = vStack.calculateLayout(in: availableBounds)
        
        return layoutResult.totalSize.height
    }
    
    /// Calculate actual content width of HStack
    private func calculateHStackContentWidth(_ hStack: HStack) -> CGFloat {
        // Call HStack's calculateLayout for accurate layout calculation
        let availableBounds = CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: bounds.height)
        let layoutResult = hStack.calculateLayout(in: availableBounds)
        
        return layoutResult.totalSize.width
    }
}
