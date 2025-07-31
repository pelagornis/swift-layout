import UIKit

/// A horizontal stack layout that arranges child layouts horizontally.
///
/// ``HStack`` arranges its child layouts in a horizontal row with optional spacing
/// and alignment. It supports flexible spacing with ``Spacer`` and various alignment options.
///
/// ## Example Usage
///
/// ```swift
/// HStack(spacing: 20, alignment: .center) {
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
    
    /// Vertical alignment options for HStack
    public enum VerticalAlignment {
        case top, center, bottom
    }
    
    /// Creates an HStack with the specified spacing, alignment, and padding.
    /// - Parameters:
    ///   - spacing: The spacing between child views
    ///   - alignment: The vertical alignment of child views
    ///   - padding: The padding around the HStack
    ///   - children: A closure that returns the child layouts
    public init(spacing: CGFloat = 0, alignment: VerticalAlignment = .center, @LayoutBuilder children: () -> any Layout) {
        self.spacing = spacing
        self.alignment = alignment
        self.padding = .zero
        
        super.init(frame: .zero)
        
        
        // 자식 레이아웃을 생성하고 뷰로 변환
        let layout = children()
        
        // TupleLayout인 경우 자식들을 직접 추출
        if let tupleLayout = layout as? TupleLayout {
            
            // TupleLayout의 layouts 배열에서 직접 뷰들을 추출
            for (index, childLayout) in tupleLayout.layouts.enumerated() {
                
                let childViews = childLayout.extractViews()
                
                // 각 자식 레이아웃의 뷰들을 처리
                for (viewIndex, childView) in childViews.enumerated() {
                    
                    // 스택 컴포넌트인 경우 직접 추가 (자신의 자식으로)
                    if childView is VStack || childView is HStack || childView is ZStack {
                        addSubview(childView)
                        continue
                    }
                    
                    // 일반 뷰들도 직접 추가
                    addSubview(childView)
                    
                    // UILabel이나 UIButton의 경우 텍스트 정보도 출력
                    if let label = childView as? UILabel {
                    } else if let button = childView as? UIButton {
                    }
                }
            }
            
            for (index, subview) in subviews.enumerated() {
                if let label = subview as? UILabel {
                } else if let button = subview as? UIButton {
                }
            }
        } else {
            // 일반적인 경우 (TupleLayout이 아닌 경우)
            let allChildViews = layout.extractViews()
            
            // 각 자식 뷰의 타입 출력
            for (index, childView) in allChildViews.enumerated() {
            }
            
            // 각 자식 뷰를 subviews에 추가
            for (index, childView) in allChildViews.enumerated() {
                addSubview(childView)
                
                // UILabel이나 UIButton의 경우 텍스트 정보도 출력
                if let label = childView as? UILabel {
                } else if let button = childView as? UIButton {
                }
            }
        }
        
        
        // 최종 subviews 상태 출력
        for (index, subview) in subviews.enumerated() {
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
        
        // 실제 자식 뷰들의 크기를 정확하게 계산
        for subview in subviews {
            var size: CGSize
            
            // Layout 프로토콜을 구현하는 뷰들 (VStack, HStack, ZStack)의 경우
            if let layoutView = subview as? (any Layout) {
                // Layout 뷰의 경우 calculateLayout을 사용하여 정확한 크기 계산
                // 실제 사용 가능한 높이를 사용하되, 최소값 보장
                let availableHeight = max(100, bounds.height > 0 ? bounds.height : 100)
                let availableWidth = max(100, bounds.width > 0 ? bounds.width : 100)
                let layoutResult = layoutView.calculateLayout(in: CGRect(x: 0, y: 0, width: availableWidth, height: availableHeight))
                size = layoutResult.totalSize
                // 음수 값 방지
                size = CGSize(width: max(size.width, 50), height: max(size.height, 20))
            } else if let label = subview as? UILabel {
                // UILabel의 경우 텍스트 크기에 맞춰 계산
                let textSize = label.sizeThatFits(CGSize(width: bounds.width > 0 ? bounds.width : 100, height: bounds.height > 0 ? bounds.height : 100))
                size = CGSize(width: max(textSize.width, 50), height: max(textSize.height, 20))
            } else if let button = subview as? UIButton {
                // UIButton의 경우 버튼 크기에 맞춰 계산
                let buttonSize = button.sizeThatFits(CGSize(width: bounds.width > 0 ? bounds.width : 100, height: bounds.height > 0 ? bounds.height : 100))
                size = CGSize(width: max(buttonSize.width, 80), height: max(buttonSize.height, 30))
            } else {
                // 다른 뷰의 경우 intrinsicContentSize 사용
                let intrinsicSize = subview.intrinsicContentSize
                size = CGSize(width: max(intrinsicSize.width, 50), height: max(intrinsicSize.height, 20))
            }
            
            totalWidth += size.width
            maxHeight = max(maxHeight, size.height)
        }
        
        // spacing 추가 (subviews.count - 1) * spacing
        if subviews.count > 1 {
            totalWidth += spacing * CGFloat(subviews.count - 1)
        }
        
        // padding 추가
        totalWidth += padding.left + padding.right
        maxHeight += padding.top + padding.bottom
        
        // 최소 크기 보장 (자식 뷰가 없는 경우에도)
        totalWidth = max(totalWidth, 200)
        maxHeight = max(maxHeight, 100)
        

        return CGSize(width: totalWidth, height: maxHeight)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        
        // bounds가 유효하지 않은 경우 safeBounds 사용
        let safeBounds = bounds.width > 0 && bounds.height > 0 ? bounds : CGRect(x: 0, y: 0, width: 375, height: 600)
        let availableBounds = safeBounds.inset(by: padding)
        
        // 먼저 고정 콘텐츠 너비를 계산 (Spacer 제외)
        var fixedContentWidth: CGFloat = 0
        var nonSpacerSubviews: [(UIView, CGSize)] = []
        var spacerCount: Int = 0
        
        for subview in subviews {
            // Spacer 감지
            if subview is Spacer {
                spacerCount += 1
            } else {
                var size: CGSize
                if let layoutView = subview as? (any Layout) {
                    let layoutResult = layoutView.calculateLayout(in: availableBounds)
                    size = layoutResult.totalSize
                    size = CGSize(width: max(size.width, 50), height: max(size.height, 20))
                } else if let label = subview as? UILabel {
                    let textSize = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: availableBounds.height))
                    size = CGSize(width: max(textSize.width, 50), height: max(textSize.height, 20))
                } else if let button = subview as? UIButton {
                    let buttonSize = button.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: availableBounds.height))
                    size = CGSize(width: max(buttonSize.width, 80), height: max(buttonSize.height, 30))
                } else {
                    let intrinsicSize = subview.intrinsicContentSize
                    size = CGSize(width: max(intrinsicSize.width, 50), height: max(intrinsicSize.height, 20))
                }
                nonSpacerSubviews.append((subview, size))
                fixedContentWidth += size.width
            }
        }
        
        // 전체 spacing 계산 (모든 subview 간)
        let totalSpacing = subviews.count > 1 ? spacing * CGFloat(subviews.count - 1) : 0
        
        // Spacer를 위한 남은 공간 계산 (SwiftUI처럼 사용 가능한 공간을 모두 차지)
        let totalAvailableWidthForContent = availableBounds.width
        let remainingWidthForSpacers = max(0, totalAvailableWidthForContent - fixedContentWidth - totalSpacing)
        let finalSpacerWidth = spacerCount > 0 ? remainingWidthForSpacers / CGFloat(spacerCount) : 0
        
        
        // 배치 시작 위치 계산
        var currentX: CGFloat = availableBounds.minX
        
        // 모든 subview들을 배치
        for subview in subviews {
            
            var size: CGSize
            
            // Spacer 감지
            if subview is Spacer {
                size = CGSize(width: finalSpacerWidth, height: availableBounds.height)
            } else {
                // nonSpacerSubviews에서 해당 subview의 크기 찾기
                if let found = nonSpacerSubviews.first(where: { $0.0 === subview }) {
                    size = found.1
                } else {
                    size = CGSize(width: 50, height: 20) // 기본 크기
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
    
    // Spacer가 있을 때의 레이아웃 계산
    private func calculateLayoutWithSpacers(in bounds: CGRect) -> LayoutResult {
        
        let safeBounds = bounds.inset(by: padding)
        var frames: [UIView: CGRect] = [:]
        var totalSize = CGSize.zero
        
        // 먼저 Spacer가 아닌 뷰들의 크기를 계산
        var fixedContentWidth: CGFloat = 0
        var spacerCount: Int = 0
        
        for subview in subviews {
            if let layoutView = subview as? (any Layout) {
                let childResult = layoutView.calculateLayout(in: safeBounds)
                frames.merge(childResult.frames) { _, new in new }
                totalSize.height = max(totalSize.height, childResult.totalSize.height)
                fixedContentWidth += childResult.totalSize.width
            } else if subview is Spacer {
                spacerCount += 1
            } else {
                var size: CGSize
                if let label = subview as? UILabel {
                    let textSize = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: safeBounds.height))
                    size = CGSize(width: max(textSize.width, 50), height: max(textSize.height, 20))
                } else if let button = subview as? UIButton {
                    let buttonSize = button.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: safeBounds.height))
                    size = CGSize(width: max(buttonSize.width, 80), height: max(buttonSize.height, 30))
                } else {
                    let intrinsicSize = subview.intrinsicContentSize
                    size = CGSize(width: max(intrinsicSize.width, 50), height: max(intrinsicSize.height, 20))
                }
                frames[subview] = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                totalSize.height = max(totalSize.height, size.height)
                fixedContentWidth += size.width
            }
        }
        
        // Spacer 계산
        let totalSpacing = subviews.count > 1 ? spacing * CGFloat(subviews.count - 1) : 0
        let remainingWidthForSpacers = max(0, safeBounds.width - fixedContentWidth - totalSpacing)
        let spacerWidth = spacerCount > 0 ? remainingWidthForSpacers / CGFloat(spacerCount) : 0
        
        // Spacer들에 대해 계산된 크기 설정
        for subview in subviews {
            if subview is Spacer {
                frames[subview] = CGRect(x: 0, y: 0, width: spacerWidth, height: safeBounds.height)
                totalSize.height = max(totalSize.height, safeBounds.height)
            }
        }
        
        // 전체 사용 가능한 공간을 사용
        totalSize.width = safeBounds.width
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
        
        for subview in subviews {
            if let layoutView = subview as? (any Layout) {
                let childResult = layoutView.calculateLayout(in: safeBounds)
                frames.merge(childResult.frames) { _, new in new }
                totalSize.width += childResult.totalSize.width
                totalSize.height = max(totalSize.height, childResult.totalSize.height)
            } else {
                var size: CGSize
                if let label = subview as? UILabel {
                    let textSize = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: safeBounds.height))
                    size = CGSize(width: max(textSize.width, 50), height: max(textSize.height, 20))
                } else if let button = subview as? UIButton {
                    let buttonSize = button.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: safeBounds.height))
                    size = CGSize(width: max(buttonSize.width, 80), height: max(buttonSize.height, 30))
                } else {
                    let intrinsicSize = subview.intrinsicContentSize
                    size = CGSize(width: max(intrinsicSize.width, 50), height: max(intrinsicSize.height, 20))
                }
                frames[subview] = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                totalSize.width += size.width
                totalSize.height = max(totalSize.height, size.height)
            }
        }
        
        // spacing 추가
        if subviews.count > 1 {
            totalSize.width += spacing * CGFloat(subviews.count - 1)
        }
        
        // padding 추가
        totalSize.width += padding.left + padding.right
        totalSize.height += padding.top + padding.bottom
        
        frames[self] = CGRect(x: 0, y: 0, width: totalSize.width, height: totalSize.height)
        
        return LayoutResult(frames: frames, totalSize: totalSize)
    }

    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        
        // Spacer가 있는지 확인
        let hasSpacers = subviews.contains { $0 is Spacer }
        
        if hasSpacers {
            return calculateLayoutWithSpacers(in: bounds)
        } else {
            return calculateLayoutWithoutSpacers(in: bounds)
        }
    }
    
    public func extractViews() -> [UIView] {
        return [self]
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


