#if canImport(UIKit)
    import UIKit
#else
    import AppKit
#endif

#if canImport(UIKit)
    public typealias ViewType = UIView
#else
    public typealias ViewType = NSView
#endif