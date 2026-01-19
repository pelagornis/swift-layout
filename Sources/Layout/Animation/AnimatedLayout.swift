import UIKit

/// A layout that applies animations to its content
@MainActor
public struct AnimatedLayout: Layout {
    public typealias Body = Never
    
    public var body: Never {
        fatalError("AnimatedLayout is a primitive layout")
    }
    
    private let base: any Layout
    private let animation: LayoutAnimation
    private let transition: TransitionConfig?
    
    public init(
        base: any Layout,
        animation: LayoutAnimation = .default,
        transition: TransitionConfig? = nil
    ) {
        self.base = base
        self.animation = animation
        self.transition = transition
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        return base.calculateLayout(in: bounds)
    }
    
    public func extractViews() -> [UIView] {
        return base.extractViews()
    }
    
    public var intrinsicContentSize: CGSize {
        return base.intrinsicContentSize
    }
}
