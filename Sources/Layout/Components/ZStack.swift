import UIKit

/// A z-axis stack layout that layers child layouts on top of each other.
///
/// ``ZStack`` arranges its child layouts in layers, with later children appearing on top
/// of earlier ones. It supports flexible spacing and various alignment options.
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
        self.alignment = .center
        self.padding = .zero
        super.init(coder: coder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        
        // bounds가 유효하지 않은 경우 safeBounds 사용
        let safeBounds = bounds.width > 0 && bounds.height > 0 ? bounds : CGRect(x: 0, y: 0, width: 375, height: 600)
        let availableBounds = safeBounds.inset(by: padding)
        
        // 모든 subview들을 배치
        for subview in subviews {
            
            var size: CGSize
            if let layoutView = subview as? (any Layout) {
                // 자식 Layout에게 실제 사용 가능한 공간을 제공하여 정확한 크기 계산
                let layoutResult = layoutView.calculateLayout(in: availableBounds)
                size = layoutResult.totalSize
                // 음수 값 방지
                size = CGSize(width: max(size.width, 50), height: max(size.height, 20))
            } else if let label = subview as? UILabel {
                let textSize = label.sizeThatFits(CGSize(width: availableBounds.width, height: availableBounds.height))
                size = CGSize(width: max(textSize.width, 50), height: max(textSize.height, 20))
            } else if let button = subview as? UIButton {
                let buttonSize = button.sizeThatFits(CGSize(width: availableBounds.width, height: availableBounds.height))
                size = CGSize(width: max(buttonSize.width, 80), height: max(buttonSize.height, 30))
            } else {
                let intrinsicSize = subview.intrinsicContentSize
                size = CGSize(width: max(intrinsicSize.width, 50), height: max(intrinsicSize.height, 20))
            }
            
            // 음수 값 방지
            size = CGSize(width: max(size.width, 1), height: max(size.height, 1))
            
            // ZStack의 전체 bounds를 사용하여 중앙 정렬 (padding 제외)
            let (x, y) = calculatePosition(for: size, in: safeBounds, alignment: alignment)
            
            let frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            subview.frame = frame
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
            x = bounds.midX - size.width / 2
            y = bounds.minY
        case .topTrailing:
            x = bounds.maxX - size.width
            y = bounds.minY
        case .leading:
            x = bounds.minX
            y = bounds.midY - size.height / 2
        case .center:
            x = bounds.midX - size.width / 2
            y = bounds.midY - size.height / 2
        case .trailing:
            x = bounds.maxX - size.width
            y = bounds.midY - size.height / 2
        case .bottomLeading:
            x = bounds.minX
            y = bounds.maxY - size.height
        case .bottom:
            x = bounds.midX - size.width / 2
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
        
        // 실제 자식 뷰들의 크기를 정확하게 계산
        for subview in subviews {
            var size: CGSize
            
            // Layout 프로토콜을 구현하는 뷰들 (VStack, HStack, ZStack)의 경우
            if let layoutView = subview as? (any Layout) {
                // Layout 뷰의 경우 calculateLayout을 사용하여 정확한 크기 계산
                let layoutResult = layoutView.calculateLayout(in: CGRect(x: 0, y: 0, width: 375, height: 600))
                size = layoutResult.totalSize
                // 음수 값 방지
                size = CGSize(width: max(size.width, 50), height: max(size.height, 20))
            } else if let label = subview as? UILabel {
                // UILabel의 경우 텍스트 크기에 맞춰 계산
                let textSize = label.sizeThatFits(CGSize(width: 375, height: 600))
                size = CGSize(width: max(textSize.width, 50), height: max(textSize.height, 20))
            } else if let button = subview as? UIButton {
                // UIButton의 경우 버튼 크기에 맞춰 계산
                let buttonSize = button.sizeThatFits(CGSize(width: 375, height: 600))
                size = CGSize(width: max(buttonSize.width, 80), height: max(buttonSize.height, 30))
            } else {
                // 다른 뷰의 경우 intrinsicContentSize 사용
                let intrinsicSize = subview.intrinsicContentSize
                size = CGSize(width: max(intrinsicSize.width, 50), height: max(intrinsicSize.height, 20))
            }
            
            maxWidth = max(maxWidth, size.width)
            maxHeight = max(maxHeight, size.height)
        }
        
        // padding 추가
        maxWidth += padding.left + padding.right
        maxHeight += padding.top + padding.bottom
        
        // 최소 크기 보장 (자식 뷰가 없는 경우에도)
        maxWidth = max(maxWidth, 200)
        maxHeight = max(maxHeight, 100)
        
        return CGSize(width: maxWidth, height: maxHeight)
    }
    
    // MARK: - Layout Protocol
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        
        let safeBounds = bounds.inset(by: padding)
        var frames: [UIView: CGRect] = [:]
        var totalSize = CGSize.zero
        
        // Calculate layout for each child
        for subview in subviews {
            if let layoutView = subview as? (any Layout) {
                let childResult = layoutView.calculateLayout(in: safeBounds)
                frames.merge(childResult.frames) { _, new in new }
                totalSize.width = max(totalSize.width, childResult.totalSize.width)
                totalSize.height = max(totalSize.height, childResult.totalSize.height)
            } else {
                // For non-Layout views, calculate their size
                var size: CGSize
                if subview is Spacer {
                    size = .zero
                } else if let label = subview as? UILabel {
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
                totalSize.height = max(totalSize.height, size.height)
            }
        }
        
        // Add padding to total size
        totalSize.width += padding.left + padding.right
        totalSize.height += padding.top + padding.bottom
        
        // Set frame for ZStack itself using totalSize (actual content size)
        frames[self] = CGRect(x: 0, y: 0, width: totalSize.width, height: totalSize.height)
        
        
        return LayoutResult(frames: frames, totalSize: totalSize)
    }
    
    public func extractViews() -> [UIView] {
        return [self]
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

