import UIKit

/// Base protocol for all layout components in the ManualLayout system.
///
/// Conforming types can calculate their layout within given bounds and extract
/// the UIViews they manage for automatic view hierarchy management.
///
/// ## Example Implementation
///
/// ```swift
/// struct CustomLayout: Layout {
///     func calculateLayout(in bounds: CGRect) -> LayoutResult {
///         // Calculate and return layout frames
///         return LayoutResult(frames: [:], totalSize: bounds.size)
///     }
///     
///     func extractViews() -> [UIView] {
///         // Return managed views for automatic hierarchy management
///         return []
///     }
/// }
/// ```
public protocol Layout {
    /// Calculates the layout of all child views within the given bounds.
    ///
    /// - Parameter bounds: The available space for layout calculation
    /// - Returns: A ``LayoutResult`` containing view frames and total size
    func calculateLayout(in bounds: CGRect) -> LayoutResult
    
    /// Extracts all UIViews managed by this layout for automatic view hierarchy management.
    ///
    /// - Returns: An array of UIViews that should be added to the container
    func extractViews() -> [UIView]
}