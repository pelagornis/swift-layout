import Foundation
import UIKit

public protocol ViewContainable {
    var superview: ViewType? { get set }
    var view: UIView { get }
    var animationDisabled: Bool { get }
    var identifier: String? { get }
    
    func updateSuperview(_ superview: UIView?)
}

extension Layout where Self: ViewContainable {
    
    public var layoutViews: [ViewInformation] {
        [.init(superview: superview, view: view, identifier: identifier)] + sublayouts.layoutViews.map({ pair in
            if pair.superview == nil {
                return pair.updatingSuperview(view)
            } else {
                return pair
            }
        })
    }

    public var layoutConstraints: [NSLayoutConstraint] {
        sublayouts.layoutConstraints
    }

    public func prepareSuperview(_ superview: ViewType?) {
        updateSuperview(superview)
        sublayouts.prepareSuperview(view)
    }

    public func prepareConstraints(_ identifiers: ViewIdentifiers) {
        sublayouts.prepareConstraints(identifiers)
    }

    public func animation() {
        if animationDisabled {
            view.layer.removeAllAnimations()
            sublayouts.animationDisable()
        }
        sublayouts.animation()
    }

}
