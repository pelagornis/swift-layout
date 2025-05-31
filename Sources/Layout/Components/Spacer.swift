import UIKit

/// A flexible space layout for pushing other layouts apart.
///
/// ``Spacer`` is equivalent to SwiftUI's Spacer and expands to fill
/// available space in stack layouts, or uses a minimum length if specified.
///
/// ## Example Usage
///
/// ```swift
/// Horizontal {
///     leftButton.layout()
///     Spacer() // Pushes buttons apart
///     rightButton.layout()
/// }
/// ```
public struct Spacer: Layout {
    /// Optional minimum length for the spacer
    public let minLength: CGFloat?
    
    /// Creates a spacer layout.
    ///
    /// - Parameter minLength: Optional minimum length (default: nil for flexible spacing)
    public init(minLength: CGFloat? = nil) {
        self.minLength = minLength
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        let size = CGSize(width: minLength ?? bounds.width, height: minLength ?? bounds.height)
        return LayoutResult(totalSize: size)
    }
    
    public func extractViews() -> [UIView] {
        return []
    }
}