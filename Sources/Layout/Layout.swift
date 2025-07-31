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

extension Layout {
    /// Applies this layout to a container view
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
    
    /// Adds overlay layouts on top of this layout
    public func overlay(@LayoutBuilder _ overlay: () -> any Layout) -> OverlayLayout {
        return OverlayLayout(base: self, overlay: overlay())
    }
}

/// A layout that overlays another layout on top of a base layout
public struct OverlayLayout: Layout {
    public typealias Body = Never
    
    public var body: Never { neverLayout("OverlayLayout") }
    
    private let base: any Layout
    private let overlay: any Layout
    
    public init(base: any Layout, overlay: any Layout) {
        self.base = base
        self.overlay = overlay
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        // Calculate base layout
        let baseResult = base.calculateLayout(in: bounds)
        
        // Calculate overlay layout
        let overlayResult = overlay.calculateLayout(in: bounds)
        
        // Combine frames
        var allFrames = baseResult.frames
        for (view, frame) in overlayResult.frames {
            allFrames[view] = frame
        }
        
        // Use the larger size to ensure overlay is fully visible
        let totalSize = CGSize(
            width: max(baseResult.totalSize.width, overlayResult.totalSize.width),
            height: max(baseResult.totalSize.height, overlayResult.totalSize.height)
        )
        
        return LayoutResult(frames: allFrames, totalSize: totalSize)
    }
    
    public func extractViews() -> [UIView] {
        return base.extractViews() + overlay.extractViews()
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
}

extension Layout where Body == Never {
    /// Calls `fatalError` with an explanation that a given `type` is a primitive `Layout`
    public func neverLayout(_ type: String) -> Never {
        fatalError("\(type) is a primitive `Layout`, you're not supposed to access its `body`.")
    }
}

/// A scrollable layout that wraps content in a UIScrollView
public struct ScrollView: Layout {
    public typealias Body = Never
    
    public var body: Never {
        neverLayout("ScrollView")
    }
    
    /// The content layout to be made scrollable
    public let content: any Layout
    
    /// Scroll view configuration
    public var showsVerticalScrollIndicator: Bool
    public var showsHorizontalScrollIndicator: Bool
    public var isScrollEnabled: Bool
    public var bounces: Bool
    
    /// Creates a scrollable layout
    ///
    /// - Parameters:
    ///   - showsVerticalScrollIndicator: Whether to show vertical scroll indicator
    ///   - showsHorizontalScrollIndicator: Whether to show horizontal scroll indicator
    ///   - isScrollEnabled: Whether scrolling is enabled
    ///   - bounces: Whether the scroll view bounces
    ///   - content: The content layout to be made scrollable
    public init(
        showsVerticalScrollIndicator: Bool = true,
        showsHorizontalScrollIndicator: Bool = false,
        isScrollEnabled: Bool = true,
        bounces: Bool = true,
        @LayoutBuilder content: () -> any Layout
    ) {
        self.content = content()
        self.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        self.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
        self.isScrollEnabled = isScrollEnabled
        self.bounces = bounces
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        // Calculate content layout with unlimited height for proper sizing
        let unlimitedBounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let contentResult = content.calculateLayout(in: unlimitedBounds)
        
        // Create a UIScrollView for the content
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        scrollView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
        scrollView.isScrollEnabled = isScrollEnabled
        scrollView.bounces = bounces
        
        // Set scroll view frame to bounds
        scrollView.frame = bounds
        
        // Set content size based on content layout (ensure minimum height)
        let contentSize = CGSize(
            width: max(contentResult.totalSize.width, bounds.width),
            height: max(contentResult.totalSize.height, bounds.height)
        )
        scrollView.contentSize = contentSize
        
        // Add content views to scroll view with their calculated frames
        for (view, frame) in contentResult.frames {
            view.frame = frame
            scrollView.addSubview(view)
        }
        
        // Return scroll view as the main view with bounds size
        return LayoutResult(
            frames: [scrollView: bounds],
            totalSize: bounds.size
        )
    }
    
    public func extractViews() -> [UIView] {
        // Extract views from content layout
        return content.extractViews()
    }
}
