#if canImport(SwiftUI)
import SwiftUI
#endif

#if canImport(SwiftUI) && canImport(UIKit)
    import UIKit
    public typealias ViewControllerRepresentable = SwiftUI.UIViewControllerRepresentable
#elseif canImport(SwiftUI) && canImport(AppKit)
    import AppKit
    public typealias ViewControllerRepresentable = SwiftUI.NSViewControllerRepresentable
#endif