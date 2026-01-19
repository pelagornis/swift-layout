import UIKit

/// Layout element that separates identity from layout logic
///
/// `LayoutElement` is the core building block of the improved layout system.
/// It separates identity (for diffing and view reuse) from layout logic (measurement
/// and placement), enabling efficient updates and animations.
///
/// ## Overview
///
/// `LayoutElement` combines:
/// - **Identity**: Unique identifier for diffing and view reuse
/// - **Node**: Layout logic (measurement and placement)
/// - **Children**: Child elements (forming the layout tree)
/// - **View**: Associated UIView (if any)
/// - **Environment**: Environment values for this element
///
/// ## Example
///
/// ```swift
/// let element = LayoutElement(
///     id: AnyHashable("my-view"),
///     node: viewNode,
///     children: [],
///     view: myView,
///     environment: environmentValues
/// )
/// ```
@MainActor
public struct LayoutElement {
    /// Unique identity for diffing and view reuse
    public let id: LayoutID
    
    /// The layout node (measurement + placement logic)
    public let node: any NewLayoutNode
    
    /// Child elements (identity + node)
    public let children: [LayoutElement]
    
    /// Associated view (if any)
    public weak var view: UIView?
    
    /// Environment values for this element
    public let environment: EnvironmentValues
    
    /// Creates a new layout element
    ///
    /// - Parameters:
    ///   - id: Unique identifier for this element
    ///   - node: Layout node that handles measurement and placement
    ///   - children: Child elements (empty for leaf nodes)
    ///   - view: Associated UIView (nil for container nodes)
    ///   - environment: Environment values for this element
    public init(
        id: LayoutID,
        node: any NewLayoutNode,
        children: [LayoutElement] = [],
        view: UIView? = nil,
        environment: EnvironmentValues
    ) {
        self.id = id
        self.node = node
        self.children = children
        self.view = view
        self.environment = environment
    }
    
    /// Measures this element
    ///
    /// - Parameter proposal: Size proposal from parent
    /// - Returns: Measured size
    /// 
    /// Note: Caching is handled by the node itself or external cache
    public func measure(_ proposal: SizeProposal) -> MeasuredSize {
        return node.measure(proposal)
    }
    
    /// Invalidates this element
    ///
    /// - Parameter reason: Reason for invalidation
    public func invalidate(_ reason: LayoutInvalidationReason) {
        node.invalidate(reason)
    }
    
    /// Collects all views managed by this element and its children
    ///
    /// - Returns: Array of all UIViews in this subtree
    public func collectViews() -> [UIView] {
        var views: [UIView] = []
        if let view = view {
            views.append(view)
        }
        for child in children {
            views.append(contentsOf: child.collectViews())
        }
        return views
    }
}
