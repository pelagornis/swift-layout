import UIKit

/// A layout that represents a tuple of layouts
public struct TupleLayout: Layout {
    public typealias Body = Never
    
    private let layouts: [any Layout]
    
    public init(_ layouts: [any Layout]) {
        self.layouts = layouts
    }
    
    public var body: Never { neverLayout("TupleLayout") }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        var allFrames: [UIView: CGRect] = [:]
        var currentY: CGFloat = 0
        var maxWidth: CGFloat = 0
        
        for layout in layouts {
            let result = layout.calculateLayout(in: CGRect(x: 0, y: currentY, width: bounds.width, height: bounds.height - currentY))
            
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
        return layouts.flatMap { $0.extractViews() }
    }
    
    // 내부 레이아웃들을 반환하는 메서드 (Vertical이 사용)
    public func getLayouts() -> [any Layout] {
        return layouts
    }
}
