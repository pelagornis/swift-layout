#if canImport(UIKit)
    import UIKit
#else
    import AppKit
#endif

#if canImport(UIKit)
    public typealias View = UIView
#else
    public typealias View = NSView
#endif
