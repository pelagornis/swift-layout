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
                
        // bounds가 0인 경우 처리
        if bounds.width == 0 || bounds.height == 0 {
            return
        }
        
        // Axis에 따라 다른 방식으로 레이아웃 계산
        switch axis {
        case .vertical:
            updateVerticalLayout(layout)
        case .horizontal:
            updateHorizontalLayout(layout)
        }
    }
    
    private func updateVerticalLayout(_ layout: any Layout) {
        // Auto Layout 방식: 자식 뷰들의 실제 크기를 직접 계산
        let actualContentHeight = calculateActualContentHeight()
        
        // 실제 콘텐츠 높이로 contentBounds 설정
        let contentBounds = CGRect(x: 0, y: 0, width: bounds.width, height: actualContentHeight)
        let result = layout.calculateLayout(in: contentBounds)
        
        // contentView frame 설정
        contentView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: actualContentHeight)
        
        // 자식 뷰들의 frame 적용
        let contentViews = layout.extractViews()
        for (view, frame) in result.frames {
            if contentViews.contains(view) {
                view.frame = frame
            }
        }
        
        // scrollView contentSize 설정
        scrollView.contentSize = CGSize(width: bounds.width, height: actualContentHeight)
    }
    
    private func updateHorizontalLayout(_ layout: any Layout) {
        // Auto Layout 방식: 자식 뷰들의 실제 크기를 직접 계산
        let actualContentWidth = calculateActualContentWidth()
        
        // 실제 콘텐츠 너비로 contentBounds 설정
        let contentBounds = CGRect(x: 0, y: 0, width: actualContentWidth, height: bounds.height)
        let result = layout.calculateLayout(in: contentBounds)
        
        // contentView frame 설정
        contentView.frame = CGRect(x: 0, y: 0, width: actualContentWidth, height: bounds.height)
        
        // 자식 뷰들의 frame 적용
        let contentViews = layout.extractViews()
        for (view, frame) in result.frames {
            if contentViews.contains(view) {
                view.frame = frame
            }
        }
        
        // scrollView contentSize 설정
        scrollView.contentSize = CGSize(width: actualContentWidth, height: bounds.height)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // bounds가 0인 경우 처리
        if bounds.width == 0 || bounds.height == 0 {
            return
        }
        
        // Update scroll view frame to match bounds - 전체 화면 사용
        scrollView.frame = bounds
        
        // Update content layout
        updateContentLayout()
    }
    
    // MARK: - Layout Protocol
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        var frames: [UIView: CGRect] = [:]
        
        // bounds가 0인 경우 처리
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
        guard let layout = childLayout else {
            return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
        }
        
        // Axis에 따라 다른 방식으로 크기 계산
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
    
    /// Auto Layout 방식으로 실제 콘텐츠 높이를 계산
    private func calculateActualContentHeight() -> CGFloat {
        
        guard let layout = childLayout else { 
            return 0
        }
        
        // ViewLayout에서 실제 UIView를 추출
        let views = layout.extractViews()
        
        // VStack을 직접 찾기
        for view in views {
            if let vStack = view as? VStack {
                return calculateVStackContentHeight(vStack)
            }
        }
        
        // VStack을 찾지 못한 경우, contentView에서 직접 VStack 찾기
        if let vStack = contentView.subviews.first as? VStack {
            return calculateVStackContentHeight(vStack)
        }
        
        // 기본 fallback
        return layout.intrinsicContentSize.height
    }
    
    /// Auto Layout 방식으로 실제 콘텐츠 너비를 계산
    private func calculateActualContentWidth() -> CGFloat {
        
        guard let layout = childLayout else { 
            return 0
        }
        
        // ViewLayout에서 실제 UIView를 추출
        let views = layout.extractViews()
        
        // HStack을 직접 찾기
        for view in views {
            if let hStack = view as? HStack {
                return calculateHStackContentWidth(hStack)
            }
        }
        
        // HStack을 찾지 못한 경우, contentView에서 직접 HStack 찾기
        if let hStack = contentView.subviews.first as? HStack {
            return calculateHStackContentWidth(hStack)
        }
        
        // 기본 fallback
        return layout.intrinsicContentSize.width
    }
    
    /// VStack의 실제 콘텐츠 높이를 계산
    private func calculateVStackContentHeight(_ vStack: VStack) -> CGFloat {
        print("🔧 [ScrollView] calculateVStackContentHeight 호출됨, VStack subviews: \(vStack.subviews.count)개")
        
        // VStack의 calculateLayout을 호출해서 정확한 레이아웃 계산
        let availableBounds = CGRect(x: 0, y: 0, width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let layoutResult = vStack.calculateLayout(in: availableBounds)
        
        print("🔧 [ScrollView] VStack calculateLayout 결과 - totalSize: \(layoutResult.totalSize)")
        
        return layoutResult.totalSize.height
    }
    
    /// HStack의 실제 콘텐츠 너비를 계산
    private func calculateHStackContentWidth(_ hStack: HStack) -> CGFloat {
        print("🔧 [ScrollView] calculateHStackContentWidth 호출됨, HStack subviews: \(hStack.subviews.count)개")
        
        // HStack의 calculateLayout을 호출해서 정확한 레이아웃 계산
        let availableBounds = CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: bounds.height)
        let layoutResult = hStack.calculateLayout(in: availableBounds)
        
        print("🔧 [ScrollView] HStack calculateLayout 결과 - totalSize: \(layoutResult.totalSize)")
        
        return layoutResult.totalSize.width
    }
}

