import UIKit

/// A vertical stack layout that arranges child layouts in a column.
///
/// ``Vertical`` is equivalent to SwiftUI's VStack and arranges its children
/// vertically with customizable spacing, alignment, and padding.
///
/// ## Example Usage
///
/// ```swift
/// Vertical(spacing: 16, alignment: .leading) {
///     titleLabel.layout()
///     subtitleLabel.layout()
///     actionButton.layout()
/// }
/// .padding(20)
/// ```
public struct Vertical: Layout {
    /// Child layouts to arrange vertically
    public let children: [Layout]
    
    /// Spacing between child layouts
    public var spacing: CGFloat = 8
    
    /// Horizontal alignment of child layouts
    public var alignment: HorizontalAlignment = .center
    
    /// Padding around the entire stack
    public var padding: UIEdgeInsets = .zero
    
    /// Horizontal alignment options for vertical stacks
    public enum HorizontalAlignment {
        /// Align children to the leading edge
        case leading
        /// Center children horizontally
        case center
        /// Align children to the trailing edge
        case trailing
    }
    
    /// Creates a vertical stack layout.
    ///
    /// - Parameters:
    ///   - spacing: Spacing between children (default: 8)
    ///   - alignment: Horizontal alignment of children (default: .center)
    ///   - content: Layout builder closure containing child layouts
    public init(spacing: CGFloat = 8, alignment: HorizontalAlignment = .center, @LayoutBuilder content: () -> [Layout]) {
        self.children = content()
        self.spacing = spacing
        self.alignment = alignment
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
    
    /// Sets the spacing between child layouts.
    ///
    /// - Parameter spacing: The spacing amount
    /// - Returns: A new ``Vertical`` with updated spacing
    public func spacing(_ spacing: CGFloat) -> Vertical {
        var copy = self
        copy.spacing = spacing
        return copy
    }
    
    /// Sets padding around the stack using UIEdgeInsets.
    ///
    /// - Parameter insets: The padding insets
    /// - Returns: A new ``Vertical`` with updated padding
    public func padding(_ insets: UIEdgeInsets) -> Vertical {
        var copy = self
        copy.padding = insets
        return copy
    }
    
    /// Sets uniform padding around the stack.
    ///
    /// - Parameter value: The padding amount for all edges
    /// - Returns: A new ``Vertical`` with updated padding
    public func padding(_ value: CGFloat) -> Vertical {
        return padding(UIEdgeInsets(top: value, left: value, bottom: value, right: value))
    }
    
    /// Sets the horizontal alignment of child layouts.
    ///
    /// - Parameter alignment: The horizontal alignment
    /// - Returns: A new ``Vertical`` with updated alignment
    public func alignment(_ alignment: HorizontalAlignment) -> Vertical {
        var copy = self
        copy.alignment = alignment
        return copy
    }
}