#if canImport(UIKit)
import UIKit
#endif

/// A layout that represents a conditional layout
public enum ConditionalLayout<TrueContent: Layout, FalseContent: Layout>: Layout {
    public typealias Body = Never
    
    case first(TrueContent)
    case second(FalseContent)
    
    public var body: Never {
        neverLayout("ConditionalLayout")
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        switch self {
        case .first(let content):
            return content.calculateLayout(in: bounds)
        case .second(let content):
            return content.calculateLayout(in: bounds)
        }
    }
    
    public func extractViews() -> [UIView] {
        switch self {
        case .first(let content):
            return content.extractViews()
        case .second(let content):
            return content.extractViews()
        }
    }
}
