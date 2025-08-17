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
    
    /// ScrollView 감지 여부를 캐시
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
            for (index, childLayout) in tupleLayout.layouts.enumerated() {
                
                let childViews = childLayout.extractViews()
                
                // Process views from each child layout
                for (viewIndex, childView) in childViews.enumerated() {
                    
                    
                    // Add stack components directly (as own children)
                    if childView is VStack || childView is HStack || childView is ZStack {
                        addSubview(childView)
                        continue
                    }
                    
                    // Also add regular views directly
                    addSubview(childView)
                    
                    // ViewLayout 정보 저장
                    if let viewLayout = childLayout as? ViewLayout {
                        storeViewLayout(viewLayout, for: childView)
                    }
                }
            }
        } else {
            // 일반적인 경우 (TupleLayout이 아닌 경우)
            let allChildViews = layout.extractViews()
            // 각 자식 뷰를 subviews에 추가
            for (index, childView) in allChildViews.enumerated() {
                // 모든 뷰에서 Auto Layout 비활성화
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
        
        // calculateLayout을 호출하여 ViewLayout의 계산된 프레임을 가져옴
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
                // calculateLayout에서 계산된 프레임 사용
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
        
        // ScrollView 내부에 있는지 감지
        let isInsideScrollView = isInsideScrollView()
        
        let remainingHeightForSpacers: CGFloat
        if isInsideScrollView {
            // ScrollView 내부에서는 Spacer를 완전히 무시
            remainingHeightForSpacers = 0
        } else {
            // 일반적인 경우
            remainingHeightForSpacers = max(0, totalAvailableHeightForContent - fixedContentHeight - totalSpacing - totalMinLength)
        }
        
        let finalSpacerHeight: CGFloat
        if isInsideScrollView {
            // ScrollView 내부에서는 Spacer가 매우 작은 공간만 차지
            let reasonableSpacerHeight = min(remainingHeightForSpacers / CGFloat(max(spacerCount, 1)), 10) // 최대 10포인트로 제한
            finalSpacerHeight = reasonableSpacerHeight
        } else {
            finalSpacerHeight = spacerCount > 0 ? (remainingHeightForSpacers / CGFloat(spacerCount)) : 0
        }
        
        // Calculate starting position for layout
        var currentY: CGFloat = availableBounds.minY
        
        // Layout all subviews
        for subview in subviews {
            // ScrollView 내부에서는 Spacer를 완전히 무시
            if isInsideScrollView && subview is Spacer {
                continue
            }
            
            var size: CGSize
            
            // Spacer 감지
            if let spacer = subview as? Spacer {
                let minLength = spacer.minLength ?? 0
                let actualHeight: CGFloat
                
                if isInsideScrollView {
                    // ScrollView 내부에서는 Spacer 높이를 0으로 설정
                    actualHeight = 0
                } else {
                    // 일반적인 경우
                    actualHeight = max(finalSpacerHeight + minLength, minLength)
                }
                
                size = CGSize(width: availableBounds.width, height: actualHeight)
            } else {
                // calculateLayout에서 계산된 프레임 사용
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
        
        // ScrollView 내부에 있는지 감지
        let isInsideScrollView = isInsideScrollView()
        
        // intrinsicContentSize는 제약이 없을 때의 자연스러운 크기를 계산
        // bounds에 의존하지 않고 자식 뷰들의 intrinsicContentSize를 기반으로 계산
        
        for subview in subviews {
            // ScrollView 내부에서는 Spacer를 완전히 무시
            if isInsideScrollView && subview is Spacer {
                continue
            }
            
            var size: CGSize
            
            // Spacer 특별 처리
            if subview is Spacer {
                // Spacer는 intrinsicContentSize에서 최소한의 공간만 차지
                size = CGSize(width: 0, height: 0)
            } else if let layoutView = subview as? (any Layout) {
                // Layout 뷰의 경우 intrinsicContentSize 사용
                size = layoutView.intrinsicContentSize
            } else if let label = subview as? UILabel {
                // UILabel의 경우 텍스트 크기에 맞춰 계산
                let textSize = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
                size = textSize
            } else if let button = subview as? UIButton {
                // UIButton의 경우 버튼 크기에 맞춰 계산
                let buttonSize = button.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
                size = buttonSize
            } else {
                // 다른 뷰의 경우 intrinsicContentSize 사용
                size = subview.intrinsicContentSize
            }
            
            totalHeight += size.height
            maxWidth = max(maxWidth, size.width)
        }
        
        // spacing 추가 - ScrollView 내부에서는 Spacer를 고려하지 않음
        let effectiveSubviews = isInsideScrollView ? subviews.filter { !($0 is Spacer) } : subviews
        if effectiveSubviews.count > 1 {
            totalHeight += spacing * CGFloat(effectiveSubviews.count - 1)
        }
        
        // padding 추가
        totalHeight += padding.top + padding.bottom
        maxWidth += padding.left + padding.right
        
        return CGSize(width: maxWidth, height: totalHeight)
    }
    
    // MARK: - Layout Protocol
    
    // Spacer가 있을 때의 레이아웃 계산
    private func calculateLayoutWithSpacers(in bounds: CGRect) -> LayoutResult {
        let safeBounds = bounds.inset(by: padding)
        var frames: [UIView: CGRect] = [:]
        var totalSize = CGSize.zero
        
        // ScrollView 내부에 있는지 감지
        let isInsideScrollView = isInsideScrollView()
        
        // 먼저 Spacer가 아닌 뷰들의 크기를 계산
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
        
        // 무제한 높이 감지 및 제한
        let maxReasonableHeight: CGFloat = 10000 // 10000pt 제한
        if fixedContentHeight > maxReasonableHeight {
            fixedContentHeight = maxReasonableHeight
        }
        
        // Spacer 계산 - ScrollView 내부에 있으면 Spacer 높이를 제한
        let totalSpacing = subviews.count > 1 ? spacing * CGFloat(subviews.count - 1) : 0
        let remainingHeightForSpacers: CGFloat
        
        if isInsideScrollView {
            // ScrollView 내부에 있으면 Spacer가 실제 콘텐츠 크기를 늘리지 않도록 제한
            let maxSpacerHeight: CGFloat = 10 // Spacer 최대 높이 제한 (SwiftUI와 유사하게 매우 작게)
            remainingHeightForSpacers = min(maxSpacerHeight, max(0, safeBounds.height - fixedContentHeight - totalSpacing))
        } else {
            // 일반적인 경우
            remainingHeightForSpacers = max(0, safeBounds.height - fixedContentHeight - totalSpacing)
        }
        
        let spacerHeight = spacerCount > 0 ? remainingHeightForSpacers / CGFloat(spacerCount) : 0
        
        // Spacer들에 대해 계산된 크기 설정
        for subview in subviews {
            if subview is Spacer {
                frames[subview] = CGRect(x: 0, y: 0, width: safeBounds.width, height: spacerHeight)
                totalSize.width = max(totalSize.width, safeBounds.width)
            }
        }
        
        // 전체 높이 계산 - ScrollView 내부에 있으면 bounds를 초과하지 않도록 제한
        let finalHeight: CGFloat
        if isInsideScrollView {
            // ScrollView 내부에서는 Spacer 높이를 포함한 실제 콘텐츠 높이 사용
            let spacerHeight = spacerCount > 0 ? remainingHeightForSpacers / CGFloat(spacerCount) : 0
            let totalSpacerHeight = spacerHeight * CGFloat(spacerCount)
            let contentHeight = fixedContentHeight + totalSpacing + totalSpacerHeight
            finalHeight = min(contentHeight, safeBounds.height)
        } else {
            // 일반적인 경우
            finalHeight = min(safeBounds.height, maxReasonableHeight)
        }
        
        totalSize.height = finalHeight
        totalSize.width += padding.left + padding.right
        totalSize.height += padding.top + padding.bottom
        
        frames[self] = CGRect(x: 0, y: 0, width: totalSize.width, height: totalSize.height)
        
        return LayoutResult(frames: frames, totalSize: totalSize)
    }
    
    // Spacer가 없을 때의 레이아웃 계산
    private func calculateLayoutWithoutSpacers(in bounds: CGRect) -> LayoutResult {
        let safeBounds = bounds.inset(by: padding)
        var frames: [UIView: CGRect] = [:]
        var totalSize = CGSize.zero
        
        // ScrollView 내부에 있는지 감지
        let isInsideScrollView = isInsideScrollView()
        
        // 무한대 높이 감지 및 제한
        let isInfiniteHeight = bounds.height > 10000 // 10000pt 이상이면 무한대로 간주
        let maxWidth = min(safeBounds.width, bounds.width)
        let maxHeight = isInfiniteHeight ? 1000 : min(safeBounds.height, bounds.height) // 무한대면 1000pt로 제한
        
        for subview in subviews {
            // ScrollView 내부에서는 Spacer를 완전히 무시
            if isInsideScrollView && subview is Spacer {
                print("🔧 [VStack] ScrollView 내부에서 Spacer 무시됨")
                continue
            }
            if let layoutView = subview as? (any Layout) {
                // 자식 레이아웃에 제한된 크기 전달 (무한대 방지)
                let childBounds = CGRect(x: 0, y: 0, width: maxWidth, height: maxHeight)
                let childResult = layoutView.calculateLayout(in: childBounds)
                frames.merge(childResult.frames) { _, new in new }
                
                // 크기 제한 적용
                let limitedWidth = min(childResult.totalSize.width, maxWidth)
                let limitedHeight = min(childResult.totalSize.height, maxHeight)
                totalSize.width = max(totalSize.width, limitedWidth)
                totalSize.height += limitedHeight
            } else {
                // 저장된 ViewLayout 정보가 있는지 확인
                if let storedViewLayout = getViewLayout(for: subview) {
                    // 저장된 ViewLayout 정보를 사용하여 calculateLayout 호출
                    let viewResult = storedViewLayout.calculateLayout(in: CGRect(x: 0, y: 0, width: maxWidth, height: maxHeight))
                    
                    if let frame = viewResult.frames[subview] {
                        frames[subview] = frame
                        totalSize.width = max(totalSize.width, frame.width)
                        totalSize.height += frame.height

                    } else {
                        // Fallback: 기존 로직 사용
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
                    // 저장된 ViewLayout 정보가 없는 경우 기존 로직 사용
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
        
        // spacing 추가 - ScrollView 내부에서는 Spacer를 고려하지 않음
        let effectiveSubviews = isInsideScrollView ? subviews.filter { !($0 is Spacer) } : subviews
        if effectiveSubviews.count > 1 {
            totalSize.height += spacing * CGFloat(effectiveSubviews.count - 1)
        }
        
        // padding 추가
        totalSize.width += padding.left + padding.right
        totalSize.height += padding.top + padding.bottom
        
        // 무제한 높이 감지 및 제한
        let maxReasonableHeight: CGFloat = 10000 // 10000pt 제한
        if totalSize.height > maxReasonableHeight {
            totalSize.height = maxReasonableHeight
        }
        
        // alignment가 설정되어 있으면 전체 width 사용
        if alignment != .leading {
            totalSize.width = bounds.width
        } else {
            // 최종 크기 제한 적용
            totalSize.width = min(totalSize.width, bounds.width)
        }
        totalSize.height = min(totalSize.height, bounds.height)
        
        frames[self] = CGRect(x: 0, y: 0, width: totalSize.width, height: totalSize.height)
        
        return LayoutResult(frames: frames, totalSize: totalSize)
    }

    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        
        // Spacer가 있는지 확인
        let hasSpacers = subviews.contains { $0 is Spacer }
        
        // ScrollView 내부에 있는지 감지
        let isInsideScrollView = isInsideScrollView()
        
        if hasSpacers && isInsideScrollView {
            // ScrollView 내부에 Spacer가 있는 경우: Spacer를 무시하고 실제 콘텐츠만 계산
            print("🔧 [VStack] ScrollView 내부에서 Spacer 감지됨 - WithoutSpacer 모드로 전환")
            return calculateLayoutWithoutSpacers(in: bounds)
        } else if hasSpacers {
            // 일반적인 경우에 Spacer가 있는 경우
            return calculateLayoutWithSpacers(in: bounds)
        } else {
            // Spacer가 없는 경우
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
    
    /// ScrollView 내부에 있는지 감지하는 메서드
    private func isInsideScrollView() -> Bool {
        // 캐시된 값이 있으면 반환
        if let cached = isInsideScrollViewCache {
            return cached
        }
        
        // 부모 뷰를 따라가면서 ScrollView 찾기
        var currentView: UIView? = self.superview
        while let view = currentView {
            if view is UIScrollView || view is ScrollView {
                isInsideScrollViewCache = true
                return true
            }
            currentView = view.superview
        }
        
        // bounds.height가 매우 큰 경우도 ScrollView 내부로 간주
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
            // TupleLayout의 extractViews()를 사용하여 자식 뷰들을 추출
            let views = tupleLayout.extractViews()
            // ViewLayout으로 변환
            overlayLayouts = views.map { ViewLayout($0) }
        } else {
            overlayLayouts = [overlayLayout]
        }
        
        // Overlay 뷰들을 추가 (Layout 뷰들은 제외)
        for overlayLayout in overlayLayouts {
            let overlayViews = overlayLayout.extractViews()
            for overlayView in overlayViews {
                // Layout 뷰들은 추가하지 않음 (이미 자식 뷰들이 추가됨)
                if !(overlayView is VStack || overlayView is HStack || overlayView is ZStack) {
                    self.addSubview(overlayView)
                }
            }
        }
        
        return self
    }
}
