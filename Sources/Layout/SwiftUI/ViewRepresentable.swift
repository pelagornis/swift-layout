#if canImport(SwiftUI)
import SwiftUI
#endif

#if canImport(SwiftUI) && canImport(UIKit)
    import UIKit
    public typealias ViewRepresentable = SwiftUI.UIViewRepresentable
#elseif canImport(SwiftUI) && canImport(AppKit)
    import AppKit
    public typealias ViewRepresentable = SwiftUI.NSViewRepresentable
#endif