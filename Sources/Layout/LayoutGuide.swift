#if canImport(UIKit)
    import UIKit
#else
    import AppKit
#endif


#if canImport(UIKit)
    public typealias LayoutGuide = UILayoutGuide
#else
    public typealias LayoutGuide = NSLayoutGuide
#endif