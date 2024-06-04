#if canImport(UIKit)
    import UIKit
#else
    import AppKit
#endif

#if canImport(UIKit)
    public typealias ViewControllerType = UIViewController
#else
    public typealias ViewControllerType = NSViewController
#endif