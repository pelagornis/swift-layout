/// SwiftUI-style result builder for creating declarative layout syntax.
///
/// ``LayoutBuilder`` enables the use of SwiftUI-like syntax for defining layouts,
/// including support for conditional statements, loops, and optional content.
///
/// ## Features
///
/// - Support for multiple layout components
/// - Conditional layouts with `if` statements
/// - Optional content handling
/// - Array flattening for dynamic content
///
/// ## Example Usage
///
/// ```swift
/// @LayoutBuilder var body: Layout {
///     Vertical(spacing: 16) {
///         titleLabel.layout()
///         
///         if showSubtitle {
///             subtitleLabel.layout()
///         }
///         
///         ForEach(items) { item in
///             item.layout()
///         }
///     }
/// }
/// ```
@resultBuilder
public struct LayoutBuilder {
    /// Builds a layout from multiple components.
    public static func buildBlock(_ components: Layout...) -> [Layout] {
        return components
    }
    
    /// Builds a layout from arrays of components.
    public static func buildBlock(_ components: [Layout]...) -> [Layout] {
        return components.flatMap { $0 }
    }
    
    /// Builds a layout from optional content.
    ///
    /// - Parameter component: Optional layout component
    /// - Returns: Array containing the component if present, empty array otherwise
    public static func buildOptional(_ component: Layout?) -> [Layout] {
        return component.map { [$0] } ?? []
    }
    
    /// Builds a layout from the first branch of a conditional.
    ///
    /// - Parameter component: Layout from the first conditional branch
    /// - Returns: Array containing the component
    public static func buildEither(first component: Layout) -> [Layout] {
        return [component]
    }
    
    /// Builds a layout from the second branch of a conditional.
    ///
    /// - Parameter component: Layout from the second conditional branch
    /// - Returns: Array containing the component
    public static func buildEither(second component: Layout) -> [Layout] {
        return [component]
    }
    
    /// Builds a layout from an array of components.
    ///
    /// - Parameter components: Array of layout components
    /// - Returns: The same array of components
    public static func buildArray(_ components: [Layout]) -> [Layout] {
        return components
    }
    
    /// Builds a layout from a single expression.
    ///
    /// - Parameter expression: Single layout component
    /// - Returns: The component unchanged
    public static func buildExpression(_ expression: Layout) -> Layout {
        return expression
    }
    
    /// Builds a layout from an array expression.
    ///
    /// - Parameter expression: Array of layout components
    /// - Returns: The same array of components
    public static func buildExpression(_ expression: [Layout]) -> [Layout] {
        return expression
    }
}