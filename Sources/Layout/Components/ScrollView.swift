import UIKit

/// A scrollable container view that allows content to be scrolled when it exceeds the available space.
///
/// ``ScrollView`` provides scrolling functionality similar to SwiftUI's ScrollView,
/// automatically enabling scrolling when content is larger than the available bounds.
///
/// ## Overview
///
/// `ScrollView` is a container that enables scrolling when its content exceeds
/// the available space. It wraps a `UIScrollView` and provides a declarative
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
public class ScrollView: UIView, Layout {
    public typealias Body = Never
    
    public var body: Never {
        fatalError("ScrollView body should not be called")
    }
    
    /// The scroll view instance
    private let scrollView = UIScrollView()
    
    /// The content view that holds the scrollable content
    private let contentView = UIView()
    
    /// The child layout
    private var childLayout: (any Layout)?
    
    /// Scroll indicators visibility
    public var showsVerticalScrollIndicator: Bool {
        get { scrollView.showsVerticalScrollIndicator }
        set { scrollView.showsVerticalScrollIndicator = newValue }
    }
    
    public var showsHorizontalScrollIndicator: Bool {
        get { scrollView.showsHorizontalScrollIndicator }
        set { scrollView.showsHorizontalScrollIndicator = newValue }
    }
    
    /// Content insets
    public var contentInset: UIEdgeInsets {
        get { scrollView.contentInset }
        set { scrollView.contentInset = newValue }
    }
    
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
            scrollView.showsVerticalScrollIndicator = true
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.alwaysBounceVertical = true
            scrollView.alwaysBounceHorizontal = false
        case .horizontal:
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = true
            scrollView.alwaysBounceVertical = false
            scrollView.alwaysBounceHorizontal = true
        }

        // Configure content view
        contentView.backgroundColor = .clear
        
        // Add scroll view to self
        addSubview(scrollView)
        
        // Add content view to scroll view
        scrollView.addSubview(contentView)
        
        // Set initial frames
        scrollView.frame = bounds
        contentView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 0)
    }
    
    private func setContent(_ layout: any Layout) {
        childLayout = layout
        
        // Remove existing content
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        // Extract views from layout
        let views = layout.extractViews()
        
        // Add views to content view
        for view in views {
            contentView.addSubview(view)
        }
        
        // Update layout
        updateContentLayout()
    }
    
    private func updateContentLayout() {
        guard let layout = childLayout else { return }
                
        // Handle zero bounds case
        if bounds.width == 0 || bounds.height == 0 {
            return
        }
        
        // Calculate layout differently based on axis
        switch axis {
        case .vertical:
            updateVerticalLayout(layout)
        case .horizontal:
            updateHorizontalLayout(layout)
        }
    }
    
    private func updateVerticalLayout(_ layout: any Layout) {
        // Auto Layout approach: directly calculate child views' actual size
        let actualContentHeight = calculateActualContentHeight()
        
        // Set contentBounds with actual content height
        let contentBounds = CGRect(x: 0, y: 0, width: bounds.width, height: actualContentHeight)
        let result = layout.calculateLayout(in: contentBounds)
        
        // Set contentView frame
        contentView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: actualContentHeight)
        
        // Apply child views' frames
        let contentViews = layout.extractViews()
        for (view, frame) in result.frames {
            if contentViews.contains(view) {
                view.frame = frame
            }
        }
        
        // Set scrollView contentSize
        scrollView.contentSize = CGSize(width: bounds.width, height: actualContentHeight)
    }
    
    private func updateHorizontalLayout(_ layout: any Layout) {
        // Auto Layout approach: directly calculate child views' actual size
        let actualContentWidth = calculateActualContentWidth()
        
        // Set contentBounds with actual content width
        let contentBounds = CGRect(x: 0, y: 0, width: actualContentWidth, height: bounds.height)
        let result = layout.calculateLayout(in: contentBounds)
        
        // Set contentView frame
        contentView.frame = CGRect(x: 0, y: 0, width: actualContentWidth, height: bounds.height)
        
        // Apply child views' frames
        let contentViews = layout.extractViews()
        for (view, frame) in result.frames {
            if contentViews.contains(view) {
                view.frame = frame
            }
        }
        
        // Set scrollView contentSize
        scrollView.contentSize = CGSize(width: actualContentWidth, height: bounds.height)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // Handle zero bounds case
        if bounds.width == 0 || bounds.height == 0 {
            return
        }
        
        // Update scroll view frame to match bounds - use full screen
        scrollView.frame = bounds
        
        // Update content layout
        updateContentLayout()
    }
    
    // MARK: - Layout Protocol
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        var frames: [UIView: CGRect] = [:]
        
        // Handle zero bounds case
        if bounds.width == 0 || bounds.height == 0 {
            return LayoutResult(frames: [self: bounds], totalSize: bounds.size)
        }
        
        // ScrollView itself takes the full bounds
        frames[self] = bounds
        
        // Calculate content layout based on axis
        if let layout = childLayout {
            switch axis {
            case .vertical:
                let actualContentHeight = calculateActualContentHeight()
                let contentBounds = CGRect(x: 0, y: 0, width: bounds.width, height: actualContentHeight)
                let contentResult = layout.calculateLayout(in: contentBounds)
                
                let childViews = layout.extractViews()
                for (view, frame) in contentResult.frames {
                    if childViews.contains(view) {
                        frames[view] = frame
                    }
                }
                
                for view in childViews {
                    if !frames.keys.contains(view) {
                        frames[view] = CGRect(x: 0, y: 0, width: bounds.width, height: 44)
                    }
                }
                
            case .horizontal:
                let actualContentWidth = calculateActualContentWidth()
                let contentBounds = CGRect(x: 0, y: 0, width: actualContentWidth, height: bounds.height)
                let contentResult = layout.calculateLayout(in: contentBounds)
                
                let childViews = layout.extractViews()
                for (view, frame) in contentResult.frames {
                    if childViews.contains(view) {
                        frames[view] = frame
                    }
                }
                
                for view in childViews {
                    if !frames.keys.contains(view) {
                        frames[view] = CGRect(x: 0, y: 0, width: 44, height: bounds.height)
                    }
                }
            }
        }
        
        return LayoutResult(frames: frames, totalSize: bounds.size)
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
    
    // MARK: - Private Methods
    
    /// Calculate actual content height using Auto Layout approach
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
    
    /// Calculate actual content width using Auto Layout approach
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

