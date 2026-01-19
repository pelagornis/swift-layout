import UIKit

/// A layout that overlays another layout on top of a base layout
public struct OverlayLayout: Layout {
    public typealias Body = Never
    
    public var body: Never { neverLayout("OverlayLayout") }
    
    private let base: any Layout
    private let overlay: any Layout
    
    public init(base: any Layout, overlay: any Layout) {
        self.base = base
        self.overlay = overlay
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        // Calculate base layout
        let baseResult = base.calculateLayout(in: bounds)
        
        // Calculate overlay layout
        let overlayResult = overlay.calculateLayout(in: bounds)
        
        // Combine frames
        var allFrames = baseResult.frames
        for (view, frame) in overlayResult.frames {
            allFrames[view] = frame
        }
        
        // Use the larger size to ensure overlay is fully visible
        let totalSize = CGSize(
            width: max(baseResult.totalSize.width, overlayResult.totalSize.width),
            height: max(baseResult.totalSize.height, overlayResult.totalSize.height)
        )
        
        return LayoutResult(frames: allFrames, totalSize: totalSize)
    }
    
    public func extractViews() -> [UIView] {
        return base.extractViews() + overlay.extractViews()
    }
}
