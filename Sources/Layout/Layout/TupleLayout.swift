import UIKit

/// A layout that represents a tuple of layouts
/// Simply passes through to child layouts without forcing any arrangement
public struct TupleLayout: Layout {
    public typealias Body = Never
    
    public let layouts: [any Layout]
    
    public init(_ layouts: [any Layout]) {
        self.layouts = layouts
    }
    
    public var body: Never { neverLayout("TupleLayout") }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        
        var allFrames: [UIView: CGRect] = [:]
        var maxWidth: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        // 각 자식 레이아웃에 전체 bounds를 전달하여 자체적으로 처리하도록 함
        for (index, layout) in layouts.enumerated() {
            let result = layout.calculateLayout(in: bounds)
            
            for (view, frame) in result.frames {
                allFrames[view] = frame
            }
            
            maxWidth = max(maxWidth, result.totalSize.width)
            maxHeight = max(maxHeight, result.totalSize.height)
        }
        
        return LayoutResult(frames: allFrames, totalSize: CGSize(width: maxWidth, height: maxHeight))
    }
    
    public func extractViews() -> [UIView] {
        
        var allViews: [UIView] = []
        
        for (index, layout) in layouts.enumerated() {
            
            let extractedViews = layout.extractViews()
            
            for (viewIndex, view) in extractedViews.enumerated() {
                
                // UILabel이나 UIButton의 경우 텍스트 정보도 출력
                if let label = view as? UILabel {
                } else if let button = view as? UIButton {
                }
            }
            
            // 모든 뷰를 추가 (스택 컴포넌트 포함)
            allViews.append(contentsOf: extractedViews)
        }
        
        for (index, view) in allViews.enumerated() {
            if let label = view as? UILabel {
            } else if let button = view as? UIButton {
            }
        }
        return allViews
    }
}
