#if canImport(UIKit)
import UIKit

#endif
/// A layout that applies background color to its base layout
public struct BackgroundLayout: Layout {
    public typealias Body = Never
    
    public var body: Never { neverLayout("BackgroundLayout") }
    
    private let base: any Layout
    private let color: UIColor
    
    public init(base: any Layout, color: UIColor) {
        self.base = base
        self.color = color
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        let result = base.calculateLayout(in: bounds)
        
        // Apply background color to all views in the base layout
        for view in base.extractViews() {
            view.backgroundColor = color
        }
        
        return result
    }
    
    public func extractViews() -> [UIView] {
        return base.extractViews()
    }
}

