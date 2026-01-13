#if canImport(UIKit)
import UIKit

#endif
/// A layout that represents an array of layouts
public struct ArrayLayout<Content: Layout>: Layout {
    public typealias Body = Never
    
    let content: [Content]
    
    public init(_ content: [Content]) {
        self.content = content
    }
    
    public var body: Never {
        neverLayout("ArrayLayout")
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        var allFrames: [UIView: CGRect] = [:]
        var currentY: CGFloat = 0
        var maxWidth: CGFloat = 0
        
        for layout in content {
            let childBounds = CGRect(x: 0, y: currentY, width: bounds.width, height: bounds.height - currentY)
            let result = layout.calculateLayout(in: childBounds)
            
            for (view, frame) in result.frames {
                var adjustedFrame = frame
                adjustedFrame.origin.y += currentY
                allFrames[view] = adjustedFrame
            }
            
            currentY += result.totalSize.height
            maxWidth = max(maxWidth, result.totalSize.width)
        }
        
        return LayoutResult(frames: allFrames, totalSize: CGSize(width: maxWidth, height: currentY))
    }
    
    public func extractViews() -> [UIView] {
        return content.flatMap { $0.extractViews() }
    }
}
