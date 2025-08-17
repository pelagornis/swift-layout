import UIKit

/// A grid layout that arranges child layouts in a grid pattern.
///
/// ``Grid`` arranges child layouts in a grid with customizable columns,
/// spacing, and alignment. It's useful for creating card layouts or
/// photo galleries.
///
/// ## Overview
///
/// `Grid` is a layout component that arranges child views in a grid pattern,
/// similar to CSS Grid or SwiftUI's `LazyVGrid`. It's perfect for creating
/// card layouts, photo galleries, or any grid-based arrangement.
///
/// ## Key Features
///
/// - **Flexible Columns**: Configurable number of columns
/// - **Customizable Spacing**: Adjustable spacing between grid items
/// - **Alignment Options**: Support for leading, center, and trailing alignment
/// - **Safe Area Aware**: Automatically considers safe area insets
/// - **Dynamic Sizing**: Items automatically size to fit available space
///
/// ## Example Usage
///
/// ```swift
/// Grid(columns: 2, spacing: 16) {
///     ForEach(items) { item in
///         itemView.layout()
///             .size(width: 160, height: 120)
///     }
/// }
///
/// Grid(columns: 3, spacing: 8, alignment: .leading) {
///     ForEach(photos) { photo in
///         photoView.layout()
///     }
/// }
/// ```
///
/// ## Topics
///
/// ### Initialization
/// - ``init(columns:spacing:alignment:content:)``
///
/// ### Configuration
/// - ``columns``
/// - ``spacing``
/// - ``alignment``
/// - ``padding``
///
/// ### Layout Behavior
/// - ``calculateLayout(in:)``
/// - ``extractViews()``
public struct Grid: Layout {
    public typealias Body = Never
    
    private let children: [any Layout]
    public var columns: Int
    public var spacing: CGFloat = 8
    public var alignment: Alignment = .center
    public var padding: UIEdgeInsets = .zero
    
    public enum Alignment {
        case leading, center, trailing
    }
    
    public init(columns: Int, spacing: CGFloat = 8, alignment: Alignment = .center, @LayoutBuilder content: () -> any Layout) {
        let builtContent = content()
        self.children = Self.extractChildren(from: builtContent)
        self.columns = max(1, columns)
        self.spacing = spacing
        self.alignment = alignment
    }
    
    private static func extractChildren(from content: any Layout) -> [any Layout] {
        if let tupleLayout = content as? TupleLayout {
            // TupleLayout의 extractViews()를 사용하여 자식 뷰들을 추출
            let views = tupleLayout.extractViews()
            // ViewLayout으로 변환
            return views.map { ViewLayout($0) }
        } else {
            return [content]
        }
    }
    
    public var body: Never {
        neverLayout("Grid")
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
        
        guard !children.isEmpty else {
            return LayoutResult(frames: [:], totalSize: .zero)
        }
        
        // 그리드 계산
        let itemWidth = (availableBounds.width - spacing * CGFloat(columns - 1)) / CGFloat(columns)
        let rows = (children.count + columns - 1) / columns
        
        var frames: [UIView: CGRect] = [:]
        var maxHeight: CGFloat = 0
        
        for (index, child) in children.enumerated() {
            let row = index / columns
            let column = index % columns
            
            let x = availableBounds.origin.x + CGFloat(column) * (itemWidth + spacing)
            let y = availableBounds.origin.y + CGFloat(row) * (itemWidth + spacing)
            
            let childBounds = CGRect(
                x: x,
                y: y,
                width: itemWidth,
                height: itemWidth
            )
            
            let childResult = child.calculateLayout(in: childBounds)
            
            // child의 모든 뷰를 최종 위치로 이동
            for (view, childFrame) in childResult.frames {
                frames[view] = childFrame
            }
            
            maxHeight = max(maxHeight, y + itemWidth)
        }
        
        let totalSize = CGSize(
            width: availableBounds.width + padding.left + padding.right,
            height: maxHeight - availableBounds.origin.y + padding.top + padding.bottom
        )
        
        return LayoutResult(frames: frames, totalSize: totalSize)
    }
    
    public func extractViews() -> [UIView] {
        return children.flatMap { $0.extractViews() }
    }
    
    // MARK: - Modifier Methods
    
    public func columns(_ columns: Int) -> Self {
        var copy = self
        copy.columns = max(1, columns)
        return copy
    }
    
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
    
    public func alignment(_ alignment: Alignment) -> Self {
        var copy = self
        copy.alignment = alignment
        return copy
    }
} 
