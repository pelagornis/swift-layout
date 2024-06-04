import Foundation

#if canImport(UIKit)
    import UIKit
#if swift(>=4.2)
    typealias LayoutRelation = NSLayoutConstraint.Relation
    typealias LayoutAttribute = NSLayoutConstraint.Attribute
#else
    typealias LayoutRelation = NSLayoutRelation
    typealias LayoutAttribute = NSLayoutAttribute
#endif
    typealias LayoutPriority = UILayoutPriority
#else
    import AppKit
    typealias LayoutRelation = NSLayoutConstraint.Relation
    typealias LayoutAttribute = NSLayoutConstraint.Attribute
    typealias LayoutPriority = NSLayoutConstraint.Priority
#endif