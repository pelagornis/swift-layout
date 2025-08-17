import UIKit

public extension UIView {
    /// Creates a layout wrapper for this view with chainable modifiers.
    ///
    /// This method wraps the UIView in a ``ViewLayout`` that provides
    /// a fluent interface for applying layout modifiers.
    ///
    /// ## Overview
    ///
    /// The `layout()` method is the primary way to integrate UIKit views
    /// with the ManualLayout system. It creates a ``ViewLayout`` wrapper
    /// that provides a fluent, chainable interface for applying layout
    /// modifiers like sizing, positioning, and styling.
    ///
    /// ## Key Features
    ///
    /// - **View Integration**: Converts any UIView to a layout component
    /// - **Chainable Interface**: Fluent API for applying multiple modifiers
    /// - **Type Safety**: Compile-time type checking for modifier combinations
    /// - **Auto Layout Disabled**: Automatically disables Auto Layout constraints
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// titleLabel.layout()
    ///     .size(width: 200, height: 44)
    ///     .centerX()
    ///     .offset(y: 20)
    ///     .background(.systemBlue)
    ///     .cornerRadius(8)
    /// ```
    ///
    /// - Returns: A ``ViewLayout`` wrapper for this view
    func layout() -> ViewLayout {
        return ViewLayout(self)
    }
}
