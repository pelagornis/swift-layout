import Foundation

#if canImport(UIKit)
    import UIKit
#else
    import AppKit
#endif

public protocol Constraint {
    func constraints(item: NSObject, toItem: NSObject?, identifiers: ViewIdentifiers) -> [LayoutConstraint]
    func constraints(item: NSObject, toItem: NSObject?) -> [LayoutConstraint]
}

extension Array: Constraint where Element == Constraint {
    public func constraints(item: NSObject, toItem: NSObject?, identifiers: ViewIdentifiers) -> [LayoutConstraint] {
        flatMap { constraint in
            constraint.constraints(item: item, toItem: toItem, identifiers: identifiers)
        }
    }
    public func constraints(item: NSObject, toItem: NSObject?) -> [LayoutConstraint] {
        flatMap { constraint in
            constraint.constraints(item: item, toItem: toItem)
        }
    }
}
