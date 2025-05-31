import UIKit

/// A horizontal stack layout that arranges child layouts in a row.
///
/// ``Horizontal`` is equivalent to SwiftUI's HStack and arranges its children
/// horizontally with customizable spacing, alignment, and padding.
///
/// ## Example Usage
///
/// ```swift
/// Horizontal(spacing: 12, alignment: .center) {
///     profileImage.layout()
///     nameLabel.layout()
///     Spacer()
///     actionButton.layout()
/// }
/// .padding(16)
/// ```
public struct Horizontal: Layout {
    /// Child layouts to arrange horizontally
    public let children: [Layout]
    
    /// Spacing between child layouts
    public var spacing: CGFloat = 8
    
    /// Vertical alignment of child layouts
    public var alignment: VerticalAlignment = .center
    
    /// Padding around the entire stack
    public var padding: UIEdgeInsets = .zero
    
    /// Vertical alignment options for horizontal stacks
    public enum VerticalAlignment {
        /// Align children to the top edge
        case top
        /// Center children vertically
        case center
        /// Align children to the bottom edge
        case bottom
    }
    
    /// Creates a horizontal stack layout.
    ///
    /// - Parameters:
    ///   - spacing: Spacing between children (default: 8)
    ///   - alignment: Vertical alignment of children (default: .center)
    ///   - content: Layout builder closure containing child layouts
    public init(spacing: CGFloat = 8, alignment: VerticalAlignment = .center, @LayoutBuilder content: () -> [Layout]) {
        self.children = content()
        self.spacing = spacing
        self.alignment = alignment
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        var frames: [UIView: CGRect] = [:]
        var currentX: CGFloat = padding.left
        let availableHeight = bounds.height - padding.top - padding.bottom
        var maxHeight: CGFloat = 0
        
        for child in children {
            let childBounds = CGRect(x: 0, y: 0, width: bounds.width - currentX - padding.right, height: availableHeight)
            let childResult = child.calculateLayout(in: childBounds)
            
            for (view, childFrame) in childResult.frames {
                var finalFrame = childFrame
                
                // Apply vertical alignment
                switch alignment {
                case .top:
                    finalFrame.origin.y = padding.top
                case .center:
                    finalFrame.origin.y = padding.top + (availableHeight - childFrame.height) / 2
                case .bottom:
                    finalFrame.origin.y = bounds.height - padding.bottom - childFrame.height
                }
                
                finalFrame.origin.x = currentX
                frames[view] = finalFrame
                
                maxHeight = max(maxHeight, childFrame.height)
            }
            
            currentX += childResult.totalSize.width + spacing
        }
        
        // Remove last spacing
        if !children.isEmpty {
            currentX -= spacing
        }
        
        currentX += padding.right
        
        let totalSize = CGSize(width: currentX, height: maxHeight + padding.top + padding.bottom)
        return LayoutResult(frames: frames, totalSize: totalSize)
    }
    
    public func extractViews() -> [UIView] {
        return children.flatMap { $0.extractViews() }
    }
    
    // MARK: - Modifier Methods
    
    /// Sets the spacing between child layouts.
    ///
    /// - Parameter spacing: The spacing amount
    /// - Returns: A new ``Horizontal`` with updated spacing
    public func spacing(_ spacing: CGFloat) -> Horizontal {
        var copy = self
        copy.spacing = spacing
        return copy
    }
    
    /// Sets padding around the stack using UIEdgeInsets.
    ///
    /// - Parameter insets: The padding insets
    /// - Returns: A new ``Horizontal`` with updated padding
    public func padding(_ insets: UIEdgeInsets) -> Horizontal {
        var copy = self
        copy.padding = insets
        return copy
    }
    
    /// Sets uniform padding around the stack.
    ///
    /// - Parameter value: The padding amount for all edges
    /// - Returns: A new ``Horizontal`` with updated padding
    public func padding(_ value: CGFloat) -> Horizontal {
        return padding(UIEdgeInsets(top: value, left: value, bottom: value, right: value))
    }
    
    /// Sets the vertical alignment of child layouts.
    ///
    /// - Parameter alignment: The vertical alignment
    /// - Returns: A new ``Horizontal`` with updated alignment
    public func alignment(_ alignment: VerticalAlignment) -> Horizontal {
        var copy = self
        copy.alignment = alignment
        return copy
    }
}