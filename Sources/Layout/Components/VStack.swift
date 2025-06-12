import UIKit

/// A vertical stack layout that arranges child layouts in a column.
///
/// ``VStack`` is equivalent to SwiftUI's VStack and arranges its children
/// vertically with customizable spacing, alignment, and padding.
///
/// ## Example Usage
///
/// ```swift
/// VStack(spacing: 16, alignment: .leading) {
///     titleLabel.layout()
///     subtitleLabel.layout()
///     actionButton.layout()
/// }
/// .padding(20)
/// ```
public struct VStack: Layout {
    public typealias Body = Never
    
    public let children: [any Layout]
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
        neverLayout("Vertical")
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        var frames: [UIView: CGRect] = [:]
        var currentY: CGFloat = padding.top
        let availableWidth = bounds.width - padding.left - padding.right
        var maxWidth: CGFloat = 0
                
        for child in children {
            let childBounds = CGRect(x: 0, y: 0, width: availableWidth, height: bounds.height - currentY - padding.bottom)
            let childResult = child.calculateLayout(in: childBounds)
                    
            for (view, childFrame) in childResult.frames {
                var finalFrame = childFrame
                        
                // Apply horizontal alignment
                switch alignment {
                case .leading:
                    finalFrame.origin.x = padding.left
                case .center:
                    finalFrame.origin.x = padding.left + (availableWidth - childFrame.width) / 2
                case .trailing:
                    finalFrame.origin.x = bounds.width - padding.right - childFrame.width
                }
                
                finalFrame.origin.y = currentY
                frames[view] = finalFrame
                
                maxWidth = max(maxWidth, childFrame.width)
            }
            
            currentY += childResult.totalSize.height + spacing
        }
        
        // Remove last spacing
        if !children.isEmpty {
            currentY -= spacing
        }
        
        currentY += padding.bottom
                
        let totalSize = CGSize(width: maxWidth + padding.left + padding.right, height: currentY)
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
