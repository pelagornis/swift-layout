import UIKit

/// A layout that applies corner radius to its base layout
public struct CornerRadiusLayout: Layout {
    public typealias Body = Never
    
    public var body: Never { neverLayout("CornerRadiusLayout") }
    
    private let base: any Layout
    private let radius: CGFloat
    
    public init(base: any Layout, radius: CGFloat) {
        self.base = base
        self.radius = radius
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        let result = base.calculateLayout(in: bounds)
        
        // Apply corner radius to all views in the base layout
        for view in base.extractViews() {
            view.layer.cornerRadius = radius
        }
        
        return result
    }
    
    public func extractViews() -> [UIView] {
        return base.extractViews()
    }
}
