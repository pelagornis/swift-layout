#if canImport(UIKit)
    import UIKit
#else
    import AppKit
#endif


#if canImport(UIKit)
    public typealias EdgeInsets = UIEdgeInsets
#else
    public typealias EdgeInsets = NSEdgeInsets
#endif