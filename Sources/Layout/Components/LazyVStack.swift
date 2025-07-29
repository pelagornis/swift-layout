import UIKit

/// A vertical stack layout that only renders views that are visible.
///
/// ``LazyVStack`` is equivalent to SwiftUI's LazyVStack and provides
/// performance optimization by only calculating and rendering visible views.
///
/// ## Example Usage
///
/// ```swift
/// LazyVStack(spacing: 16, alignment: .center) {
///     ForEach(0..<100) { index in
///         Text("Item \(index)")
///             .layout()
///             .size(width: 280, height: 44)
///     }
/// }
/// ```
public struct LazyVStack: Layout {
    public typealias Body = Never
    
    private let children: [any Layout]
    public var spacing: CGFloat = 8
    public var alignment: HorizontalAlignment = .center
    public var padding: UIEdgeInsets = .zero
    
    public enum HorizontalAlignment {
        case leading, center, trailing
    }
    
    public init<Content: Layout>(spacing: CGFloat = 8, alignment: HorizontalAlignment = .center, @LayoutBuilder content: () -> Content) {
        let builtContent = content()
        self.children = Self.extractChildren(from: builtContent)
        self.spacing = spacing
        self.alignment = alignment
    }
    
    private static func extractChildren(from content: any Layout) -> [any Layout] {
        if let tupleLayout = content as? TupleLayout {
            return tupleLayout.getLayouts()
        } else {
            return [content]
        }
    }
    
    public var body: Never {
        neverLayout("LazyVStack")
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        // Safe Area를 고려한 available bounds 계산
        let safeAreaInsets = UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
        let availableBounds = CGRect(
            x: bounds.origin.x + padding.left + safeAreaInsets.left,
            y: bounds.origin.y + padding.top + safeAreaInsets.top,
            width: bounds.width - padding.left - padding.right - safeAreaInsets.left - safeAreaInsets.right,
            height: bounds.height - padding.top - padding.bottom - safeAreaInsets.top - safeAreaInsets.bottom
        )
        
        var frames: [UIView: CGRect] = [:]
        var maxWidth: CGFloat = 0
        var currentY: CGFloat = availableBounds.origin.y
        var totalHeight: CGFloat = 0
        
        // 각 child를 순차적으로 배치 (lazy loading)
        for child in children {
            let childResult = child.calculateLayout(in: availableBounds)
            let childSize = childResult.totalSize
            
            // X 위치 계산 (alignment 적용)
            var childX: CGFloat = availableBounds.origin.x
            switch alignment {
            case .leading:
                childX = availableBounds.origin.x
            case .center:
                childX = availableBounds.origin.x + (availableBounds.width - childSize.width) / 2
            case .trailing:
                childX = availableBounds.origin.x + availableBounds.width - childSize.width
            }
            
            // child를 계산된 위치에서 레이아웃
            let childBounds = CGRect(
                x: childX,
                y: currentY,
                width: childSize.width,
                height: childSize.height
            )
            
            let finalChildResult = child.calculateLayout(in: childBounds)
            
            // child의 모든 뷰를 최종 위치로 이동
            for (view, childFrame) in finalChildResult.frames {
                frames[view] = childFrame
            }
            
            currentY += childSize.height + spacing
            maxWidth = max(maxWidth, childSize.width)
            totalHeight += childSize.height + spacing
        }
        
        // 마지막 spacing 제거
        if !children.isEmpty {
            totalHeight -= spacing
        }
        
        let totalSize = CGSize(
            width: maxWidth + padding.left + padding.right,
            height: totalHeight + padding.top + padding.bottom
        )
        
        return LayoutResult(frames: frames, totalSize: totalSize)
    }
    
    public func extractViews() -> [UIView] {
        return children.flatMap { $0.extractViews() }
    }
    
    // MARK: - Modifier Methods
    
    public func spacing(_ spacing: CGFloat) -> Self {
        var copy = self
        copy.spacing = spacing
        return copy
    }
    
    public func padding(_ insets: UIEdgeInsets) -> Self {
        var copy = self
        copy.padding = insets
        return copy
    }
    
    public func padding(_ value: CGFloat) -> Self {
        return padding(UIEdgeInsets(top: value, left: value, bottom: value, right: value))
    }
    
    public func alignment(_ alignment: HorizontalAlignment) -> Self {
        var copy = self
        copy.alignment = alignment
        return copy
    }
} 