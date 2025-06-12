import UIKit

/// A layout for dynamically generating content from a collection.
///
/// ``ForEach`` is equivalent to SwiftUI's ForEach and creates layouts
/// for each item in a collection using a content closure.
///
/// ## Example Usage
///
/// ```swift
/// ForEach(items) { item in
///     item.layout()
///         .size(width: 80, height: 32)
/// }
/// ```
public struct ForEach<T>: Layout {
    public typealias Body = Never
    
    public let items: [T]
    public let content: (T) -> any Layout
    
    public init(_ items: [T], @LayoutBuilder content: @escaping (T) -> any Layout) {
        self.items = items
        self.content = content
    }
    
    public var body: Never {
        neverLayout("ForEach")
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        let layouts = items.map(content)
        
        // Arrange items vertically for simplicity
        var frames: [UIView: CGRect] = [:]
        var currentY: CGFloat = 0
        var maxWidth: CGFloat = 0
        
        for layout in layouts {
            let childResult = layout.calculateLayout(in: CGRect(x: 0, y: currentY, width: bounds.width, height: bounds.height - currentY))
            
            for (view, frame) in childResult.frames {
                var adjustedFrame = frame
                adjustedFrame.origin.y += currentY
                frames[view] = adjustedFrame
                maxWidth = max(maxWidth, frame.width)
            }
            
            currentY += childResult.totalSize.height
        }
        
        return LayoutResult(frames: frames, totalSize: CGSize(width: maxWidth, height: currentY))
    }
    
    public func extractViews() -> [UIView] {
        return items.flatMap { item in
            content(item).extractViews()
        }
    }
}
