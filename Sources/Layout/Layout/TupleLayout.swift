#if canImport(UIKit)
import UIKit

#endif
/// A layout that represents a tuple of layouts
/// Automatically arranges multiple layouts vertically like a VStack when not wrapped in an explicit container
public struct TupleLayout: Layout {
    public typealias Body = Never
    
    public let layouts: [any Layout]
    public let spacing: CGFloat
    public let alignment: HorizontalAlignment
    
    /// Horizontal alignment options for TupleLayout
    public enum HorizontalAlignment {
        case leading, center, trailing
    }
    
    public init(_ layouts: [any Layout], spacing: CGFloat = 10, alignment: HorizontalAlignment = .center) {
        self.layouts = layouts
        self.spacing = spacing
        self.alignment = alignment
    }
    
    public var body: Never { neverLayout("TupleLayout") }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        var allFrames: [UIView: CGRect] = [:]
        var currentY: CGFloat = 0
        var maxWidth: CGFloat = 0
        
        // Arrange layouts vertically like a VStack
        for (index, layout) in layouts.enumerated() {
            // Calculate available bounds for this layout
            let availableHeight = max(0, bounds.height - currentY)
            let layoutBounds = CGRect(
                x: bounds.minX,
                y: bounds.minY,
                width: bounds.width,
                height: availableHeight
            )
            
            let result = layout.calculateLayout(in: layoutBounds)
            
            // Apply horizontal alignment and adjust frames to current vertical position
            for (view, frame) in result.frames {
                var adjustedFrame = frame
                
                // Apply horizontal alignment for each view
                switch alignment {
                case .leading:
                    adjustedFrame.origin.x = bounds.minX
                case .center:
                    adjustedFrame.origin.x = bounds.minX + (bounds.width - adjustedFrame.width) / 2
                case .trailing:
                    adjustedFrame.origin.x = bounds.maxX - adjustedFrame.width
                }
                
                adjustedFrame.origin.y = frame.origin.y + currentY
                allFrames[view] = adjustedFrame
            }
            
            // Update position for next layout
            currentY += result.totalSize.height
            if index < layouts.count - 1 { // Add spacing except for last item
                currentY += spacing
            }
            
            maxWidth = max(maxWidth, result.totalSize.width)
        }
        
        let finalSize = CGSize(width: maxWidth, height: currentY)
        
        return LayoutResult(frames: allFrames, totalSize: finalSize)
    }
    
    public func extractViews() -> [UIView] {
        var allViews: [UIView] = []
        
        for layout in layouts {
            let extractedViews = layout.extractViews()
            allViews.append(contentsOf: extractedViews)
        }
        
        return allViews
    }
}
