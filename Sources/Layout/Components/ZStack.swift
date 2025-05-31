import UIKit

/// A z-stack layout that overlays child layouts on top of each other.
///
/// ``ZStack`` is equivalent to SwiftUI's ZStack and places all children
/// at the same position with customizable alignment.
///
/// ## Example Usage
///
/// ```swift
/// ZStack(alignment: .topLeading) {
///     backgroundView.layout()
///     overlayLabel.layout()
///     actionButton.layout()
/// }
/// ```
public struct ZStack: Layout {
    /// Child layouts to overlay
    public let children: [Layout]
    
    /// Alignment for positioning children
    public var alignment: Alignment = .center
    
    /// Alignment options for z-stack positioning
    public enum Alignment {
        /// Top-leading corner
        case topLeading
        /// Top center
        case top
        /// Top-trailing corner
        case topTrailing
        /// Leading center
        case leading
        /// Center
        case center
        /// Trailing center
        case trailing
        /// Bottom-leading corner
        case bottomLeading
        /// Bottom center
        case bottom
        /// Bottom-trailing corner
        case bottomTrailing
    }
    
    /// Creates a z-stack layout.
    ///
    /// - Parameters:
    ///   - alignment: Alignment for positioning children (default: .center)
    ///   - content: Layout builder closure containing child layouts
    public init(alignment: Alignment = .center, @LayoutBuilder content: () -> [Layout]) {
        self.children = content()
        self.alignment = alignment
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        var frames: [UIView: CGRect] = [:]
        var maxWidth: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        for child in children {
            let childResult = child.calculateLayout(in: bounds)
            
            for (view, childFrame) in childResult.frames {
                var finalFrame = childFrame
                
                // Apply alignment
                switch alignment {
                case .topLeading:
                    finalFrame.origin = .zero
                case .top:
                    finalFrame.origin.x = (bounds.width - childFrame.width) / 2
                    finalFrame.origin.y = 0
                case .topTrailing:
                    finalFrame.origin.x = bounds.width - childFrame.width
                    finalFrame.origin.y = 0
                case .leading:
                    finalFrame.origin.x = 0
                    finalFrame.origin.y = (bounds.height - childFrame.height) / 2
                case .center:
                    finalFrame.origin.x = (bounds.width - childFrame.width) / 2
                    finalFrame.origin.y = (bounds.height - childFrame.height) / 2
                case .trailing:
                    finalFrame.origin.x = bounds.width - childFrame.width
                    finalFrame.origin.y = (bounds.height - childFrame.height) / 2
                case .bottomLeading:
                    finalFrame.origin.x = 0
                    finalFrame.origin.y = bounds.height - childFrame.height
                case .bottom:
                    finalFrame.origin.x = (bounds.width - childFrame.width) / 2
                    finalFrame.origin.y = bounds.height - childFrame.height
                case .bottomTrailing:
                    finalFrame.origin.x = bounds.width - childFrame.width
                    finalFrame.origin.y = bounds.height - childFrame.height
                }
                
                frames[view] = finalFrame
                maxWidth = max(maxWidth, finalFrame.maxX)
                maxHeight = max(maxHeight, finalFrame.maxY)
            }
        }
        
        return LayoutResult(frames: frames, totalSize: CGSize(width: maxWidth, height: maxHeight))
    }
    
    public func extractViews() -> [UIView] {
        return children.flatMap { $0.extractViews() }
    }
}