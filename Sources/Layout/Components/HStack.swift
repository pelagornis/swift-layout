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
    public init(spacing: CGFloat = 0, alignment: VerticalAlignment = .center, padding: UIEdgeInsets = .zero, @LayoutBuilder children: () -> any Layout) {
        self.spacing = spacing
        self.alignment = alignment
        self.padding = padding
        
        super.init(frame: .zero)
        
        print("🔧 HStack - init with spacing: \(spacing), alignment: \(alignment)")
        
        // 자식 레이아웃을 생성하고 뷰로 변환
        let layout = children()
        
        // TupleLayout인 경우 내부 레이아웃들을 추출
        let childLayouts: [any Layout]
        if let tupleLayout = layout as? TupleLayout {
            childLayouts = tupleLayout.getLayouts()
            print("🔧 HStack - TupleLayout detected with \(tupleLayout.getLayouts().count) layouts")
        } else if layout is VStack || layout is HStack || layout is ZStack {
            childLayouts = [layout]
        } else {
            childLayouts = layout.extractViews().isEmpty ? [] : [layout]
        }
        
        // 각 레이아웃을 UIView로 변환하여 subviews에 추가
        for childLayout in childLayouts {
            if let childView = childLayout as? UIView {
                addSubview(childView)
                print("🔧 HStack - Added child view: \(type(of: childView))")
            } else {
                // ViewLayout이나 다른 Layout의 경우 extractViews() 사용
                let extractedViews = childLayout.extractViews()
                for view in extractedViews {
                    addSubview(view)
                    print("🔧 HStack - Added extracted view: \(type(of: view))")
                }
            }
        }
        
        print("🔧 HStack - init completed with \(subviews.count) subviews")
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
        
        print("�� HStack - intrinsicContentSize: \(CGSize(width: totalWidth, height: maxHeight))")
        return CGSize(width: totalWidth, height: maxHeight)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLog("🔧 HStack - layoutSubviews - bounds: \(bounds)")
        NSLog("🔧 HStack - layoutSubviews - frame: \(frame)")
        print("🔧 HStack - layoutSubviews - bounds: \(bounds)")
        print("🔧 HStack - layoutSubviews - subviews count: \(subviews.count)")
        
        // bounds가 유효하지 않은 경우 레이아웃 건너뛰기
        guard bounds.width > 0 && bounds.height > 0 else {
            NSLog("🔧 HStack - Invalid bounds, skipping layout")
            print("🔧 HStack - Invalid bounds, skipping layout")
            return
        }
        
        let availableBounds = bounds.inset(by: padding)
        print("🔧 HStack - layoutSubviews - availableBounds: \(availableBounds)")
        
        // availableBounds도 유효한지 확인
        guard availableBounds.width > 0 && availableBounds.height > 0 else {
            NSLog("🔧 HStack - Invalid availableBounds, skipping layout")
            print("🔧 HStack - Invalid availableBounds, skipping layout")
            return
        }
        
        var currentX: CGFloat = availableBounds.minX
        
        // 먼저 Spacer가 아닌 뷰들의 총 크기를 계산
        var nonSpacerViews: [UIView] = []
        var totalNonSpacerWidth: CGFloat = 0
        
        for subview in subviews {
            if subview is Spacer {
                continue
            }
            
            nonSpacerViews.append(subview)
            
            var size: CGSize
            if let layoutView = subview as? (any Layout) {
                let availableHeight = max(availableBounds.height, 50)
                let layoutResult = layoutView.calculateLayout(in: CGRect(x: 0, y: 0, width: availableBounds.width, height: availableHeight))
                size = layoutResult.totalSize
                size = CGSize(width: max(size.width, 50), height: max(size.height, 20))
            } else if let label = subview as? UILabel {
                let textSize = label.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: availableBounds.height))
                size = CGSize(width: max(textSize.width, 50), height: max(textSize.height, 20))
            } else if let button = subview as? UIButton {
                let buttonSize = button.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: availableBounds.height))
                size = CGSize(width: max(buttonSize.width, 80), height: max(buttonSize.height, 30))
            } else {
                let intrinsicSize = subview.intrinsicContentSize
                size = CGSize(width: max(intrinsicSize.width, 50), height: max(intrinsicSize.height, 20))
            }
            
            totalNonSpacerWidth += size.width
        }
        
        // Spacer가 아닌 뷰들 사이의 spacing 계산
        if nonSpacerViews.count > 1 {
            totalNonSpacerWidth += spacing * CGFloat(nonSpacerViews.count - 1)
        }
        
        // Spacer가 차지할 수 있는 공간 계산 (더 엄격한 제한)
        let availableSpaceForSpacers = max(0, availableBounds.width - totalNonSpacerWidth)
        let spacerCount = subviews.filter { $0 is Spacer }.count
        let spacerWidth = spacerCount > 0 ? min(100, max(10, availableSpaceForSpacers / CGFloat(spacerCount))) : 0
        
        // 이제 모든 뷰들을 배치
        for subview in subviews {
            NSLog("🔧 HStack - Processing subview: \(type(of: subview))")
            print("🔧 HStack - Processing subview: \(type(of: subview))")
            print("🔧 HStack - Subview text: \((subview as? UILabel)?.text ?? "N/A")")
            print("🔧 HStack - Subview isHidden: \(subview.isHidden)")
            print("🔧 HStack - Subview alpha: \(subview.alpha)")
            print("🔧 HStack - Subview backgroundColor: \(subview.backgroundColor?.description ?? "nil")")
            
            var size: CGSize
            if subview is Spacer {
                // Spacer는 사용 가능한 공간을 채움 (더 엄격한 제한)
                size = CGSize(width: max(spacerWidth, 10), height: min(availableBounds.height, 30))
            } else if let layoutView = subview as? (any Layout) {
                let availableHeight = max(availableBounds.height, 50)
                let layoutResult = layoutView.calculateLayout(in: CGRect(x: 0, y: 0, width: availableBounds.width, height: availableHeight))
                size = layoutResult.totalSize
                size = CGSize(width: max(size.width, 50), height: max(size.height, 20))
            } else if let label = subview as? UILabel {
                let textSize = label.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: availableBounds.height))
                size = CGSize(width: max(textSize.width, 50), height: max(textSize.height, 20))
            } else if let button = subview as? UIButton {
                let buttonSize = button.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: availableBounds.height))
                size = CGSize(width: max(buttonSize.width, 80), height: max(buttonSize.height, 30))
            } else {
                let intrinsicSize = subview.intrinsicContentSize
                size = CGSize(width: max(intrinsicSize.width, 50), height: max(intrinsicSize.height, 20))
            }
            
            let y: CGFloat
            switch alignment {
            case .top: y = availableBounds.minY
            case .center: y = availableBounds.midY - size.height / 2
            case .bottom: y = availableBounds.maxY - size.height
            }
            
            let frame = CGRect(x: currentX, y: y, width: size.width, height: size.height)
            NSLog("🔧 HStack - Setting frame for \(type(of: subview)): \(frame)")
            print("🔧 HStack - Setting frame for \(type(of: subview)): \(frame)")
            subview.frame = frame
            
            // subview가 실제로 뷰 계층에 추가되었는지 확인 (Layout 뷰들은 제외)
            if subview.superview == nil && !(subview is VStack || subview is HStack || subview is ZStack) {
                NSLog("🔧 HStack - Adding subview to hierarchy: \(type(of: subview))")
                print("🔧 HStack - Adding subview to hierarchy: \(type(of: subview))")
                self.addSubview(subview)
            }
            
            currentX += size.width + spacing
        }
    }
    
    // MARK: - Layout Protocol
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        print("🔧 HStack - calculateLayout in bounds: \(bounds)")
        
        let availableBounds = bounds.inset(by: padding)
        var frames: [UIView: CGRect] = [:]
        var currentX: CGFloat = availableBounds.minX
        var maxHeight: CGFloat = 0
        
        // HStack 자체를 frames에 추가
        frames[self] = bounds
        
        // subviews를 사용하여 자식 뷰들을 처리
        for subview in subviews {
            var size: CGSize
            
            if let layoutView = subview as? (any Layout) {
                let availableHeight = max(availableBounds.height, 50)
                let layoutResult = layoutView.calculateLayout(in: CGRect(x: 0, y: 0, width: availableBounds.width, height: availableHeight))
                size = layoutResult.totalSize
                size = CGSize(width: max(size.width, 50), height: max(size.height, 20))
            } else if let label = subview as? UILabel {
                let textSize = label.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: availableBounds.height))
                size = CGSize(width: max(textSize.width, 50), height: max(textSize.height, 20))
            } else if let button = subview as? UIButton {
                let buttonSize = button.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: availableBounds.height))
                size = CGSize(width: max(buttonSize.width, 80), height: max(buttonSize.height, 30))
            } else {
                let intrinsicSize = subview.intrinsicContentSize
                size = CGSize(width: max(intrinsicSize.width, 50), height: max(intrinsicSize.height, 20))
            }
            
            let y: CGFloat
            switch alignment {
            case .top: y = availableBounds.minY
            case .center: y = availableBounds.midY - size.height / 2
            case .bottom: y = availableBounds.maxY - size.height
            }
            
            let frame = CGRect(x: currentX, y: y, width: size.width, height: size.height)
            frames[subview] = frame
            currentX += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }
        
        // 전체 크기 계산
        let totalWidth = currentX - spacing + padding.left + padding.right
        let totalHeight = maxHeight + padding.top + padding.bottom
        
        let totalSize = CGSize(width: totalWidth, height: totalHeight)
        print("🔧 HStack - calculated totalSize: \(totalSize)")
        
        return LayoutResult(frames: frames, totalSize: totalSize)
    }
    
    public func extractViews() -> [UIView] {
        // HStack 자체와 모든 자식 뷰들을 반환
        var views: [UIView] = [self]
        views.append(contentsOf: subviews)
        return views
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


