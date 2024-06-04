import Foundation

#if canImport(UIKit)
    import UIKit
#else
    import AppKit
#endif

public protocol ViewLayout: CustomDebugStringConvertible {
    
    var sublayouts: [ViewLayout] { get }
    
    var layoutViews: [ViewInformation] { get }
    var layoutConstraints: [LayoutConstraint] { get }
    
    func prepareSuperview(_ superview: ConstraintView?)
    func prepareConstraints(_ identifiers: ViewIdentifiers)
    
    func animation()
    @discardableResult
    func animationDisable() -> Self
}

extension ViewLayout {

    public func active() -> Activatorable {
        return Activation(self)
    }

    func prepare() -> Self {
        prepareSuperview(nil)
        prepareConstraints(ViewIdentifiers(views: Set(layoutViews)))
        return self
    }

    public func prepareConstraints(_ identifiers: ViewIdentifiers) {
        sublayouts.prepareConstraints(identifiers)
    }

    @discardableResult
    public func animationDisable() -> Self {
        sublayouts.animationDisable()
        return self
    }

    public func animation() {
        sublayouts.animation()
    }

}