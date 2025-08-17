import UIKit

/// Base protocol for all layout components in the ManualLayout system.
///
/// The `Layout` protocol is the foundation of the ManualLayout system, providing
/// a declarative way to define view layouts. Conforming types can calculate their
/// layout within given bounds and extract the UIViews they manage for automatic
/// view hierarchy management.
///
/// ## Overview
///
/// A layout represents a way to arrange views in a container. The layout system
/// automatically handles view hierarchy management, frame calculations, and
/// constraint-free positioning.
///
/// ## Key Features
///
/// - **Declarative Syntax**: Define layouts using a SwiftUI-like syntax
/// - **Automatic View Management**: Views are automatically added to containers
/// - **Flexible Sizing**: Support for intrinsic content sizing and explicit sizing
/// - **Composable**: Combine multiple layouts to create complex arrangements
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
///
/// ## Topics
///
/// ### Essential Methods
/// - ``calculateLayout(in:)``
/// - ``extractViews()``
/// - ``intrinsicContentSize``
///
/// ### Layout Composition
/// - ``overlay(_:)``
/// - ``background(_:)``
/// - ``cornerRadius(_:)``
public protocol Layout {
    /// A type representing the body of this Layout.
    ///
    /// The `Body` associated type defines the content of the layout. For primitive
    /// layouts like ``VStack``, ``HStack``, and ``ZStack``, this is `Never`.
    associatedtype Body: Layout
    
    /// Calculates the layout of all child views within the given bounds.
    ///
    /// This method is responsible for determining the position and size of all
    /// child views within the available space. The layout system calls this method
    /// to compute the final arrangement of views.
    ///
    /// - Parameter bounds: The available space for layout calculation
    /// - Returns: A ``LayoutResult`` containing view frames and total size
    func calculateLayout(in bounds: CGRect) -> LayoutResult
    
    /// Extracts all UIViews managed by this layout for automatic view hierarchy management.
    ///
    /// This method returns all UIViews that should be added to the container.
    /// The layout system uses this to automatically manage the view hierarchy
    /// without requiring manual `addSubview` calls.
    ///
    /// - Returns: An array of UIViews that should be added to the container
    func extractViews() -> [UIView]
    
    /// Returns the intrinsic content size of this layout.
    ///
    /// The intrinsic content size represents the natural size of the layout
    /// without any external constraints. This is used by the layout system
    /// to determine the appropriate size when no explicit size is provided.
    ///
    /// - Returns: The natural size of the layout
    var intrinsicContentSize: CGSize { get }
    
    /// The content and behavior of a layout.
    ///
    /// The `body` property defines the content of the layout. For primitive
    /// layouts, this property is not used and should not be accessed.
    @LayoutBuilder var body: Self.Body { get }
}

extension Layout {
    /// Applies this layout to a container view.
    ///
    /// This method automatically manages the view hierarchy by removing existing
    /// subviews, adding the layout's views, and calculating and applying the
    /// final frame positions.
    ///
    /// - Parameter container: The UIView to apply the layout to
    public func apply(to container: UIView) {
        // Remove existing subviews
        for subview in container.subviews {
            subview.removeFromSuperview()
        }
        
        // Extract views from layout
        let views = extractViews()
        
        // Add views to container
        for view in views {
            container.addSubview(view)
        }
        
        // Calculate and apply layout
        let result = calculateLayout(in: container.bounds)
        
        // Set frame for each view
        for (view, frame) in result.frames {
            view.frame = frame
        }
    }
    
    /// Adds overlay layouts on top of this layout.
    ///
    /// The overlay layout is positioned on top of the base layout, allowing
    /// for layered arrangements. Both layouts are calculated within the same bounds.
    ///
    /// - Parameter overlay: A closure that returns the overlay layout
    /// - Returns: An ``OverlayLayout`` that combines the base and overlay
    public func overlay(@LayoutBuilder _ overlay: () -> any Layout) -> OverlayLayout {
        return OverlayLayout(base: self, overlay: overlay())
    }
    
    /// Applies background color to this layout.
    ///
    /// This modifier sets the background color of all views in the layout.
    /// The background is applied to the base layout's views.
    ///
    /// - Parameter color: The background color to apply
    /// - Returns: A ``BackgroundLayout`` with the specified background color
    public func background(_ color: UIColor) -> BackgroundLayout {
        return BackgroundLayout(base: self, color: color)
    }
    
    /// Applies corner radius to this layout.
    ///
    /// This modifier sets the corner radius of all views in the layout.
    /// The corner radius is applied to the base layout's views.
    ///
    /// - Parameter radius: The corner radius to apply
    /// - Returns: A ``CornerRadiusLayout`` with the specified corner radius
    public func cornerRadius(_ radius: CGFloat) -> CornerRadiusLayout {
        return CornerRadiusLayout(base: self, radius: radius)
    }
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
    
    public var intrinsicContentSize: CGSize {
        fatalError("Never should not calculate intrinsic content size")
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
        return self.body.extractViews()
    }
    
    @inlinable
    public var intrinsicContentSize: CGSize {
        return self.body.intrinsicContentSize
    }
}

extension Layout where Body == Never {
    /// Calls `fatalError` with an explanation that a given `type` is a primitive `Layout`
    public func neverLayout(_ type: String) -> Never {
        fatalError("\(type) is a primitive `Layout`, you're not supposed to access its `body`.")
    }
}
