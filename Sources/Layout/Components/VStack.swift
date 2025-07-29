import UIKit

/// A vertical stack layout that arranges child layouts vertically.
///
/// ``VStack`` arranges its child layouts in a vertical column with optional spacing
/// and alignment. It supports flexible spacing with ``Spacer`` and various alignment options.
///
/// ## Example Usage
///
/// ```swift
/// VStack(spacing: 20, alignment: .center) {
///     titleLabel.layout()
///         .size(width: 280, height: 40)
///     actionButton.layout()
///         .size(width: 180, height: 44)
///     Spacer()
///     footerLabel.layout()
/// }
/// .padding(40)
/// ```
public class VStack: UIView, Layout {
    public typealias Body = Never
    
    public var body: Never {
        fatalError("VStack body should not be called")
    }
    
    /// Spacing between child layouts
    public var spacing: CGFloat
    
    /// Horizontal alignment of child layouts
    public var alignment: HorizontalAlignment
    
    /// Padding around the entire stack
    public var padding: UIEdgeInsets
    
    /// Explicit size override
    public var explicitSize: CGSize = .zero
    
    /// Horizontal alignment options for VStack
    public enum HorizontalAlignment {
        case leading, center, trailing
    }
    
    /// Creates a VStack with the specified spacing, alignment, and padding.
    /// - Parameters:
    ///   - spacing: The spacing between child views
    ///   - alignment: The horizontal alignment of child views
    ///   - padding: The padding around the VStack
    ///   - children: A closure that returns the child layouts
    public init(spacing: CGFloat = 0, alignment: HorizontalAlignment = .center, padding: UIEdgeInsets = .zero, @LayoutBuilder children: () -> any Layout) {
        self.spacing = spacing
        self.alignment = alignment
        self.padding = padding
        
        super.init(frame: .zero)
        
        print("🔧 VStack - init with spacing: \(spacing), alignment: \(alignment)")
        
        // 자식 레이아웃을 생성하고 뷰로 변환
        let layout = children()
        
        // TupleLayout인 경우 내부 레이아웃들을 추출
        let childLayouts: [any Layout]
        if let tupleLayout = layout as? TupleLayout {
            childLayouts = tupleLayout.getLayouts()
            print("🔧 VStack - TupleLayout detected with \(tupleLayout.getLayouts().count) layouts")
        } else if layout is VStack || layout is HStack || layout is ZStack {
            childLayouts = [layout]
        } else {
            childLayouts = layout.extractViews().isEmpty ? [] : [layout]
        }
        
        // 각 레이아웃을 UIView로 변환하여 subviews에 추가
        for childLayout in childLayouts {
            if let childView = childLayout as? UIView {
                addSubview(childView)
                print("🔧 VStack - Added child view: \(type(of: childView))")
            } else {
                // ViewLayout이나 다른 Layout의 경우 extractViews() 사용
                let extractedViews = childLayout.extractViews()
                for view in extractedViews {
                    addSubview(view)
                    print("🔧 VStack - Added extracted view: \(type(of: view))")
                }
            }
        }
        
        print("🔧 VStack - init completed with \(subviews.count) subviews")
    }
    
    required init?(coder: NSCoder) {
        self.spacing = 0
        self.alignment = .center
        self.padding = .zero
        super.init(coder: coder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLog("🔧 VStack - layoutSubviews - bounds: \(bounds)")
        NSLog("🔧 VStack - layoutSubviews - frame: \(frame)")
        print("🔧 VStack - layoutSubviews - bounds: \(bounds)")
        print("🔧 VStack - layoutSubviews - subviews count: \(subviews.count)")
        
        // bounds가 유효하지 않은 경우 레이아웃 건너뛰기
        guard bounds.width > 0 && bounds.height > 0 else {
            NSLog("🔧 VStack - Invalid bounds (\(bounds)), skipping layout")
            print("🔧 VStack - Invalid bounds (\(bounds)), skipping layout")
            return
        }
        
        let availableBounds = bounds.inset(by: padding)
        print("🔧 VStack - layoutSubviews - availableBounds: \(availableBounds)")
        
        // availableBounds도 유효한지 확인
        guard availableBounds.width > 0 && availableBounds.height > 0 else {
            NSLog("🔧 VStack - Invalid availableBounds, skipping layout")
            print("🔧 VStack - Invalid availableBounds, skipping layout")
            return
        }
        
        var currentY: CGFloat = availableBounds.minY
        
        // Spacer가 아닌 뷰들의 총 높이를 먼저 계산
        var nonSpacerViews: [UIView] = []
        var totalNonSpacerHeight: CGFloat = 0
        
        for subview in subviews {
            if subview is Spacer {
                continue
            }
            
            nonSpacerViews.append(subview)
            
            var size: CGSize
            if let layoutView = subview as? (any Layout) {
                let availableWidth = max(availableBounds.width, 50)
                let layoutResult = layoutView.calculateLayout(in: CGRect(x: 0, y: 0, width: availableWidth, height: availableBounds.height))
                size = layoutResult.totalSize
                size = CGSize(width: max(size.width, 50), height: max(size.height, 20))
            } else if let label = subview as? UILabel {
                let textSize = label.sizeThatFits(CGSize(width: availableBounds.width, height: .greatestFiniteMagnitude))
                size = CGSize(width: max(textSize.width, 50), height: max(textSize.height, 20))
            } else if let button = subview as? UIButton {
                let buttonSize = button.sizeThatFits(CGSize(width: availableBounds.width, height: .greatestFiniteMagnitude))
                size = CGSize(width: max(buttonSize.width, 80), height: max(buttonSize.height, 30))
            } else {
                let intrinsicSize = subview.intrinsicContentSize
                size = CGSize(width: max(intrinsicSize.width, 50), height: max(intrinsicSize.height, 20))
            }
            
            totalNonSpacerHeight += size.height
        }
        
        // Spacer가 아닌 뷰들 사이의 spacing 계산
        if nonSpacerViews.count > 1 {
            totalNonSpacerHeight += spacing * CGFloat(nonSpacerViews.count - 1)
        }
        
        // Spacer가 차지할 수 있는 공간 계산 (더 합리적인 제한)
        let availableSpaceForSpacers = max(0, availableBounds.height - totalNonSpacerHeight)
        let spacerCount = subviews.filter { $0 is Spacer }.count
        let spacerHeight = spacerCount > 0 ? max(5, availableSpaceForSpacers / CGFloat(spacerCount)) : 0
        
        // 이제 모든 뷰들을 배치
        for subview in subviews {
            NSLog("🔧 VStack - Processing subview: \(type(of: subview))")
            print("🔧 VStack - Processing subview: \(type(of: subview))")
            print("🔧 VStack - Subview text: \((subview as? UILabel)?.text ?? "N/A")")
            print("🔧 VStack - Subview isHidden: \(subview.isHidden)")
            print("🔧 VStack - Subview alpha: \(subview.alpha)")
            print("🔧 VStack - Subview backgroundColor: \(subview.backgroundColor?.description ?? "nil")")
            
            var size: CGSize
            if subview is Spacer {
                // Spacer는 사용 가능한 공간을 채움 (더 합리적인 제한)
                size = CGSize(width: min(availableBounds.width, 20), height: max(spacerHeight, 5))
            } else if let layoutView = subview as? (any Layout) {
                let availableWidth = max(availableBounds.width, 50)
                let layoutResult = layoutView.calculateLayout(in: CGRect(x: 0, y: 0, width: availableWidth, height: availableBounds.height))
                size = layoutResult.totalSize
                size = CGSize(width: max(size.width, 50), height: max(size.height, 20))
            } else if let label = subview as? UILabel {
                let textSize = label.sizeThatFits(CGSize(width: availableBounds.width, height: .greatestFiniteMagnitude))
                size = CGSize(width: max(textSize.width, 50), height: max(textSize.height, 20))
            } else if let button = subview as? UIButton {
                let buttonSize = button.sizeThatFits(CGSize(width: availableBounds.width, height: .greatestFiniteMagnitude))
                size = CGSize(width: max(buttonSize.width, 80), height: max(buttonSize.height, 30))
            } else {
                let intrinsicSize = subview.intrinsicContentSize
                size = CGSize(width: max(intrinsicSize.width, 50), height: max(intrinsicSize.height, 20))
            }
            
            let x: CGFloat
            switch alignment {
            case .leading: x = availableBounds.minX
            case .center: x = availableBounds.midX - size.width / 2
            case .trailing: x = availableBounds.maxX - size.width
            }
            
            let frame = CGRect(x: x, y: currentY, width: size.width, height: size.height)
            NSLog("🔧 VStack - Setting frame for \(type(of: subview)): \(frame)")
            print("🔧 VStack - Setting frame for \(type(of: subview)): \(frame)")
            subview.frame = frame
            
            currentY += size.height + spacing
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        var totalHeight: CGFloat = 0
        var maxWidth: CGFloat = 0
        
        // 실제 자식 뷰들의 크기를 정확하게 계산
        for subview in subviews {
            var size: CGSize
            
            // Layout 프로토콜을 구현하는 뷰들 (VStack, HStack, ZStack)의 경우
            if let layoutView = subview as? (any Layout) {
                // Layout 뷰의 경우 calculateLayout을 사용하여 정확한 크기 계산
                // 실제 사용 가능한 너비를 사용하되, 최소값 보장
                let availableWidth = max(375, bounds.width > 0 ? bounds.width : 375)
                let availableHeight = max(100, bounds.height > 0 ? bounds.height : 100)
                let layoutResult = layoutView.calculateLayout(in: CGRect(x: 0, y: 0, width: availableWidth, height: availableHeight))
                size = layoutResult.totalSize
                // 음수 값 방지
                size = CGSize(width: max(size.width, 50), height: max(size.height, 20))
            } else if let label = subview as? UILabel {
                // UILabel의 경우 텍스트 크기에 맞춰 계산
                let availableWidth = max(375, bounds.width > 0 ? bounds.width : 375)
                let availableHeight = max(100, bounds.height > 0 ? bounds.height : 100)
                let textSize = label.sizeThatFits(CGSize(width: availableWidth, height: availableHeight))
                size = CGSize(width: max(textSize.width, 50), height: max(textSize.height, 20))
            } else if let button = subview as? UIButton {
                // UIButton의 경우 버튼 크기에 맞춰 계산
                let availableWidth = max(375, bounds.width > 0 ? bounds.width : 375)
                let availableHeight = max(100, bounds.height > 0 ? bounds.height : 100)
                let buttonSize = button.sizeThatFits(CGSize(width: availableWidth, height: availableHeight))
                size = CGSize(width: max(buttonSize.width, 80), height: max(buttonSize.height, 30))
            } else {
                // 다른 뷰의 경우 intrinsicContentSize 사용
                let intrinsicSize = subview.intrinsicContentSize
                size = CGSize(width: max(intrinsicSize.width, 50), height: max(intrinsicSize.height, 20))
            }
            
            totalHeight += size.height
            maxWidth = max(maxWidth, size.width)
        }
        
        // spacing 추가 (subviews.count - 1) * spacing
        if subviews.count > 1 {
            totalHeight += spacing * CGFloat(subviews.count - 1)
        }
        
        // padding 추가
        totalHeight += padding.top + padding.bottom
        maxWidth += padding.left + padding.right
        
        // 최소 크기 보장 (자식 뷰가 없는 경우에도)
        maxWidth = max(maxWidth, 200)
        totalHeight = max(totalHeight, 100)
        
        print("🔧 VStack - intrinsicContentSize: \(CGSize(width: maxWidth, height: totalHeight))")
        return CGSize(width: maxWidth, height: totalHeight)
    }
    
    // MARK: - Layout Protocol
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        print("🔧 VStack - calculateLayout in bounds: \(bounds)")
        
        let availableBounds = bounds.inset(by: padding)
        var frames: [UIView: CGRect] = [:]
        var currentY: CGFloat = availableBounds.minY
        var maxWidth: CGFloat = 0
        
        // VStack 자체를 frames에 추가
        frames[self] = bounds
        
        // subviews를 사용하여 자식 뷰들을 처리
        for subview in subviews {
            var size: CGSize
            
            if let layoutView = subview as? (any Layout) {
                let availableWidth = max(availableBounds.width, 50)
                let layoutResult = layoutView.calculateLayout(in: CGRect(x: 0, y: 0, width: availableWidth, height: availableBounds.height))
                size = layoutResult.totalSize
                size = CGSize(width: max(size.width, 50), height: max(size.height, 20))
            } else if let label = subview as? UILabel {
                let textSize = label.sizeThatFits(CGSize(width: availableBounds.width, height: .greatestFiniteMagnitude))
                size = CGSize(width: max(textSize.width, 50), height: max(textSize.height, 20))
            } else if let button = subview as? UIButton {
                let buttonSize = button.sizeThatFits(CGSize(width: availableBounds.width, height: .greatestFiniteMagnitude))
                size = CGSize(width: max(buttonSize.width, 80), height: max(buttonSize.height, 30))
            } else {
                let intrinsicSize = subview.intrinsicContentSize
                size = CGSize(width: max(intrinsicSize.width, 50), height: max(intrinsicSize.height, 20))
            }
            
            let x: CGFloat
            switch alignment {
            case .leading: x = availableBounds.minX
            case .center: x = availableBounds.midX - size.width / 2
            case .trailing: x = availableBounds.maxX - size.width
            }
            
            let frame = CGRect(x: x, y: currentY, width: size.width, height: size.height)
            frames[subview] = frame
            currentY += size.height + spacing
            maxWidth = max(maxWidth, size.width)
        }
        
        // 전체 크기 계산
        let totalHeight = currentY - spacing + padding.top + padding.bottom
        let totalWidth = maxWidth + padding.left + padding.right
        
        let totalSize = CGSize(width: totalWidth, height: totalHeight)
        print("🔧 VStack - calculated totalSize: \(totalSize)")
        
        return LayoutResult(frames: frames, totalSize: totalSize)
    }
    
    public func extractViews() -> [UIView] {
        // VStack 자체와 모든 자식 뷰들을 반환
        var views: [UIView] = [self]
        views.append(contentsOf: subviews)
        return views
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
            overlayLayouts = tupleLayout.getLayouts()
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


