#if canImport(UIKit)
import UIKit


public extension UIView {
    /// Creates a layout wrapper for this view with chainable modifiers.
    ///
    /// This method wraps the UIView in a ``ViewLayout`` that provides
    /// a fluent interface for applying layout modifiers.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// titleLabel.layout()
    ///     .size(width: 200, height: 44)
    ///     .centerX()
    ///     .offset(y: 20)
    /// ```
    ///
    /// - Returns: A ``ViewLayout`` wrapper for this view
    func layout() -> ViewLayout {
        return ViewLayout(self)
    }
}
#endif
