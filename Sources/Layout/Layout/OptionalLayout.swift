#if canImport(UIKit)
import UIKit
#endif

/// A layout that represents an optional layout
public struct OptionalLayout<Content: Layout>: Layout {
    public typealias Body = Never
    
    let content: Content?
    
    public init(_ content: Content?) {
        self.content = content
    }
    
    public var body: Never {
        neverLayout("OptionalLayout")
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        guard let content = content else {
            return LayoutResult()
        }
        return content.calculateLayout(in: bounds)
    }
    
    public func extractViews() -> [UIView] {
        return content?.extractViews() ?? []
    }
}
