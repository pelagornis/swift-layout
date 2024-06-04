#if canImport(UIKit)
    import UIKit
#else
    import AppKit
#endif

extension Layout where Self: ViewType {
    
    public func makeAnchor<C>(_ anchors: () -> C) -> AnchorsLayout<C> where C: Constraint {
        .init(view: self, constraint: anchors())
    }
    
}

extension ViewLayout {
    public func anchors<C>(@AnchorsBuilder _ anchors: () -> C) -> AnchorsLayout<C> where C: Constraint {
        .init(superview: superview,
              view: view,
              constraint: anchors(),
              sublayouts: sublayouts,
              identifier: identifier,
              animationDisabled: animationDisabled)
    }
}
