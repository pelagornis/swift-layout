/// Protocol for views that can provide a declarative layout body.
///
/// Implement this protocol to create custom layout containers with SwiftUI-style syntax.
///
/// ```swift
/// class MyCustomView: UIView, LayoutBuildable {
///     @LayoutBuilder var body: Layout {
///         Vertical(spacing: 16) {
///             // Layout content here
///         }
///     }
/// }
/// ```
public protocol LayoutBuildable {
    /// The layout body using declarative syntax.
    @LayoutBuilder var body: Layout { get }
}