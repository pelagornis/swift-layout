import UIKit

/// A Z-stack layout that overlays child layouts on top of each other.
///
/// ``ZStack`` arranges its child layouts in layers, with each child positioned
/// on top of the previous ones. It supports alignment and padding options.
///
/// ## Example Usage
///
/// ```swift
/// ZStack(alignment: .center) {
///     backgroundView.layout()
///         .size(width: 300, height: 200)
///     overlayView.layout()
///         .position(x: 0, y: -20)
///     iconView.layout()
///         .size(width: 40, height: 40)
///         .position(x: 0, y: 20)
/// }
/// .padding(40)
/// ```
public class ZStack: UIView, Layout {
    public typealias Body = Never
    
    public var body: Never {
        fatalError("ZStack body should not be called")
    }
    
    /// Alignment of child layouts within the stack
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
    
    /// Edge options for padding
    public struct Edge: OptionSet {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let top = Edge(rawValue: 1 << 0)
        public static let leading = Edge(rawValue: 1 << 1)
        public static let bottom = Edge(rawValue: 1 << 2)
        public static let trailing = Edge(rawValue: 1 << 3)
        public static let all: Edge = [.top, .leading, .bottom, .trailing]
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
        
        print("🔧 ZStack - init with alignment: \(alignment)")
        
        // 자식 레이아웃을 생성하고 뷰로 변환
        let layout = children()
        
        // TupleLayout인 경우 내부 레이아웃들을 추출
        let childLayouts: [any Layout]
        if let tupleLayout = layout as? TupleLayout {
            childLayouts = tupleLayout.getLayouts()
            print("🔧 ZStack - TupleLayout detected with \(tupleLayout.getLayouts().count) layouts")
        } else if layout is VStack || layout is HStack || layout is ZStack {
            childLayouts = [layout]
        } else {
            childLayouts = layout.extractViews().isEmpty ? [] : [layout]
        }
        
        // 각 레이아웃을 UIView로 변환하여 subviews에 추가
        for childLayout in childLayouts {
            if let childView = childLayout as? UIView {
                addSubview(childView)
                print("🔧 ZStack - Added child view: \(type(of: childView))")
            } else {
                // ViewLayout이나 다른 Layout의 경우 extractViews() 사용
                let extractedViews = childLayout.extractViews()
                for view in extractedViews {
                    addSubview(view)
                    print("🔧 ZStack - Added extracted view: \(type(of: view))")
                }
            }
        }
        
        print("🔧 ZStack - init completed with \(subviews.count) subviews")
    }
    
    required init?(coder: NSCoder) {
        self.alignment = .center
        self.padding = .zero
        super.init(coder: coder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let availableBounds = bounds.inset(by: padding)
        print("🔧 ZStack - layoutSubviews - bounds: \(bounds)")
        print("🔧 ZStack - layoutSubviews - availableBounds: \(availableBounds)")
        print("🔧 ZStack - layoutSubviews - subviews count: \(subviews.count)")
        
        for subview in subviews {
            print("🔧 ZStack - Processing subview: \(type(of: subview))")
            print("🔧 ZStack - Subview isHidden: \(subview.isHidden)")
            print("🔧 ZStack - Subview alpha: \(subview.alpha)")
            print("🔧 ZStack - Subview backgroundColor: \(subview.backgroundColor?.description ?? "nil")")
            
            // intrinsicContentSize 대신 직접 크기 계산
            let size: CGSize
            if let label = subview as? UILabel {
                size = label.sizeThatFits(CGSize(width: availableBounds.width, height: CGFloat.greatestFiniteMagnitude))
            } else if let button = subview as? UIButton {
                size = button.sizeThatFits(CGSize(width: availableBounds.width, height: CGFloat.greatestFiniteMagnitude))
            } else if let vStack = subview as? VStack {
                size = vStack.intrinsicContentSize
            } else {
                size = subview.intrinsicContentSize
            }
            
            let frame = calculateFrame(for: size, in: availableBounds, alignment: alignment)
            print("🔧 ZStack - Setting frame for \(type(of: subview)): \(frame)")
            subview.frame = frame
            
            // subview가 실제로 뷰 계층에 추가되었는지 확인
            if subview.superview == nil {
                print("🔧 ZStack - Adding subview to hierarchy: \(type(of: subview))")
                self.addSubview(subview)
            }
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        var maxWidth: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.intrinsicContentSize
            maxWidth = max(maxWidth, size.width)
            maxHeight = max(maxHeight, size.height)
        }
        
        // padding 추가
        maxWidth += padding.left + padding.right
        maxHeight += padding.top + padding.bottom
        
        // 최소 크기 보장 (자식 뷰들이 없어도)
        maxWidth = max(maxWidth, 100)
        maxHeight = max(maxHeight, 50)
        
        print("🔧 ZStack - intrinsicContentSize: \(CGSize(width: maxWidth, height: maxHeight))")
        return CGSize(width: maxWidth, height: maxHeight)
    }
    
    private func calculateFrame(for size: CGSize, in bounds: CGRect, alignment: Alignment) -> CGRect {
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
        
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
    
    // MARK: - Layout Protocol
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        let availableBounds = bounds.inset(by: padding)
        print("🔧 ZStack - calculateLayout - bounds: \(bounds)")
        print("🔧 ZStack - calculateLayout - availableBounds: \(availableBounds)")
        var frames: [UIView: CGRect] = [:]
        // ZStack 자체를 frames에 추가
        frames[self] = bounds
        for subview in subviews {
            let size: CGSize
            if let vStack = subview as? VStack {
                size = vStack.intrinsicContentSize
            } else {
                size = subview.intrinsicContentSize
            }
            let frame = calculateFrame(for: size, in: availableBounds, alignment: alignment)
            frames[subview] = frame
        }
        return LayoutResult(frames: frames, totalSize: bounds.size)
    }
    
    public func extractViews() -> [UIView] {
        // ZStack 자체와 모든 자식 뷰들을 반환
        var views: [UIView] = [self]
        views.append(contentsOf: subviews)
        return views
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
    
    public func padding(_ edges: Edge = .all, _ length: CGFloat) -> Self {
        var insets = UIEdgeInsets.zero
        if edges.contains(.top) { insets.top = length }
        if edges.contains(.leading) { insets.left = length }
        if edges.contains(.bottom) { insets.bottom = length }
        if edges.contains(.trailing) { insets.right = length }
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
}


