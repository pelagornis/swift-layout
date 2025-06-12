import SwiftUI
import UIKit

// MARK: - UIKit to SwiftUI Bridge

/// UIKit to SwiftUI conversion extension.
///
/// This extension provides seamless integration between UIKit views and SwiftUI,
/// allowing UIKit components to be used directly in SwiftUI layouts.
@available(iOS 13.0, *)
public extension UIView {
    /// Converts the UIKit view to a SwiftUI view.
    ///
    /// This property wraps the UIKit view in a ``UIViewWrapper`` that conforms
    /// to SwiftUI's `UIViewRepresentable` protocol.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// struct MySwiftUIView: View {
    ///     var body: some View {
    ///         VStack {
    ///             Text("SwiftUI Text")
    ///             
    ///             myUIKitView.swiftui // ← Convert UIKit to SwiftUI
    ///                 .frame(height: 100)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Returns: A SwiftUI view wrapper for this UIKit view
    var swiftui: UIViewWrapper {
        return UIViewWrapper(uiView: self)
    }
    
    /// Converts the UIKit view to SwiftUI with custom configuration.
    ///
    /// - Parameter content: ViewBuilder closure for additional SwiftUI configuration
    /// - Returns: The result of the content closure
    func swiftui<Content: View>(@ViewBuilder content: @escaping (UIViewWrapper) -> Content) -> Content {
        return content(UIViewWrapper(uiView: self))
    }
}

/// SwiftUI wrapper for UIKit views.
///
/// ``UIViewWrapper`` conforms to `UIViewRepresentable` and provides
/// a bridge for using UIKit views within SwiftUI layouts.
@available(iOS 13.0, *)
public struct UIViewWrapper: UIViewRepresentable {
    /// The wrapped UIKit view
    public let uiView: UIView
    
    /// Optional update handler for SwiftUI state changes
    public var updateHandler: ((UIView, Context) -> Void)?
    
    /// Creates a UIView wrapper.
    ///
    /// - Parameter uiView: The UIKit view to wrap
    public init(uiView: UIView) {
        self.uiView = uiView
    }
    
    public func makeUIView(context: Context) -> UIView {
        return uiView
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
        updateHandler?(uiView, context)
    }
    
    /// Adds a custom update handler for SwiftUI state changes.
    ///
    /// - Parameter handler: Closure called when SwiftUI requests view updates
    /// - Returns: A new wrapper with the update handler attached
    public func onUpdate(_ handler: @escaping (UIView, Context) -> Void) -> UIViewWrapper {
        var wrapper = self
        wrapper.updateHandler = handler
        return wrapper
    }
}

// MARK: - SwiftUI to UIKit Bridge

/// SwiftUI to UIKit conversion extension.
///
/// This extension provides methods to embed SwiftUI views within UIKit
/// view controllers and view hierarchies.
@available(iOS 13.0, *)
public extension View {
    /// Converts the SwiftUI view to a UIKit view controller.
    ///
    /// This property wraps the SwiftUI view in a `UIHostingController`
    /// for embedding in UIKit view controller hierarchies.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let swiftUIView = Text("Hello SwiftUI")
    /// let hostingController = swiftUIView.uikit
    /// addChild(hostingController)
    /// view.addSubview(hostingController.view)
    /// ```
    ///
    /// - Returns: A UIHostingController containing this SwiftUI view
    var uikit: UIHostingController<Self> {
        return UIHostingController(rootView: self)
    }
    
    /// Converts the SwiftUI view to a UIKit view.
    ///
    /// This property creates a UIHostingController and returns its view
    /// for direct addition to UIKit view hierarchies.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let swiftUIView = Text("Hello SwiftUI")
    /// let uikitView = swiftUIView.uikitView
    /// parentView.addSubview(uikitView)
    /// ```
    ///
    /// - Returns: The UIView from a UIHostingController
    var uikitView: UIView {
        let hostingController = UIHostingController(rootView: self)
        return hostingController.view
    }
    
    /// Converts the SwiftUI view to UIKit with custom configuration.
    ///
    /// - Parameter configure: Closure for configuring the UIHostingController
    /// - Returns: The configured UIHostingController
    func uikit(configure: @escaping (UIHostingController<Self>) -> Void) -> UIHostingController<Self> {
        let controller = UIHostingController(rootView: self)
        configure(controller)
        return controller
    }
}
