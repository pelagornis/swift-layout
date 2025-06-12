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
    /// A type representing the body of this Layout.
    associatedtype Body: Layout
    
    /// Calculates the layout of all child views within the given bounds.
    ///
    /// - Parameter bounds: The available space for layout calculation
    /// - Returns: A ``LayoutResult`` containing view frames and total size
    func calculateLayout(in bounds: CGRect) -> LayoutResult
    
    /// Extracts all UIViews managed by this layout for automatic view hierarchy management.
    ///
    /// - Returns: An array of UIViews that should be added to the container
    func extractViews() -> [UIView]
    
    /// The content and behavior of a layout.
    @LayoutBuilder var body: Self.Body { get }
}

extension Never: Layout {
    public typealias Body = Never
    
    public var body: Never {
        fatalError("Never should not have a body")
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        fatalError("Never should not calculate layout")
    }
    
    public func extractViews() -> [UIView] {
        fatalError("Never should not extract views")
    }
}

extension Layout where Body: Layout {
    @discardableResult
    @inlinable
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        return self.body.calculateLayout(in: bounds)
    }

    @discardableResult
    @inlinable
    public func extractViews() -> [UIView] {
        return self.self.extractViews()
    }
}

extension Layout where Body == Never {
    /// Calls `fatalError` with an explanation that a given `type` is a primitive `Layout`
    public func neverLayout(_ type: String) -> Never {
        fatalError("\(type) is a primitive `Layout`, you're not supposed to access its `body`.")
    }
}
