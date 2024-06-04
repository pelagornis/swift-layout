#if canImport(UIKit)
import UIKit
extension ViewRepresentable where Self: UIView, Self: ViewLayout {

    public func makeUIView(context: Context) -> Self {
        return self
    }

    public func updateUIView(_ uiView: Self, context: Context) {
        uiView.updateLayout()
    }

}

extension ViewControllerRepresentable where Self: ViewControllerType, Self: ViewLayout {

    public func makeUIViewController(context: Context) -> Self {
        return self
    }

    public func updateUIViewController(_ uiViewController: Self, context: Context) {
        uiViewController.updateLayout()
    }

}

#else
import AppKit
extension ViewRepresentable where Self: ViewType, Self: ViewLayout {

    public func makeNSView(context: Context) -> Self {
        return self
    }

    public func updateNSView(_ uiView: Self, context: Context) {
        uiView.updateLayout()
    }

}

extension ViewControllerRepresentable where Self: ViewControllerType, Self: ViewLayout {

    public func makeNSViewController(context: Context) -> Self {
        return self
    }

    public func updateNSViewController(_ uiViewController: Self, context: Context) {
        uiViewController.updateLayout()
    }

}
#endif

public protocol LayoutViewRepresentable: ViewRepresentable where Self: ViewType, Self: Layout {
    static var layoutPreviews: Self { get }
}

extension LayoutViewRepresentable {
    public static var layoutPreviews: Self {
        Self.init(frame: .zero)
    }
}

public protocol LayoutViewControllerRepresentable: ViewControllerRepresentable where Self: ViewControllerType, Self: Layout {
    static var layoutPreviews: Self { get }
}

extension LayoutViewControllerRepresentable {
    public static var layoutPreviews: Self {
        Self.init(nibName: nil, bundle: nil)
    }
}