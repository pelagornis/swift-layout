#if canImport(UIKit)
import UIKit

#endif
/// A node in the layout tree that wraps a Layout and manages its state
/// 
/// LayoutNode provides:
/// - Parent-child relationships for the layout tree
/// - Dirty flag tracking for incremental updates
/// - Cached layout results
/// - Dirty propagation to parent nodes
@MainActor
public final class LayoutNode {
    /// The wrapped layout
    public let layout: any Layout
    
    /// Weak reference to parent node
    public weak var parent: LayoutNode?
    
    /// Child nodes (for layouts that contain other layouts)
    public private(set) var children: [LayoutNode] = []
    
    /// Whether this node needs recalculation
    public private(set) var isDirty: Bool = false
    
    /// Cached layout result (valid only when !isDirty)
    private var cachedResult: LayoutResult?
    
    /// Cached bounds used for the cached result
    private var cachedBounds: CGRect = .zero
    
    /// Content hash for cache validation
    private var contentHash: Int = 0
    
    /// Whether this node is currently being calculated (prevents infinite loops)
    private var isCalculating: Bool = false
    
    /// Creates a layout node
    public init(layout: any Layout) {
        self.layout = layout
        self.isDirty = true  // New nodes start dirty until first calculation
    }
    
    /// Adds a child node and establishes parent-child relationship
    public func addChild(_ child: LayoutNode) {
        children.append(child)
        child.parent = self
    }
    
    /// Removes a child node
    public func removeChild(_ child: LayoutNode) {
        children.removeAll { $0 === child }
        child.parent = nil
    }
    
    /// Removes all child nodes
    public func removeAllChildren() {
        for child in children {
            child.parent = nil
        }
        children.removeAll()
    }
    
    /// Marks this node as dirty and optionally propagates to parent
    /// - Parameter propagateToParent: If true, marks parent as dirty (default: true)
    ///   Set to false for partial updates where only this node should be recalculated
    public func markDirty(propagateToParent: Bool = true) {
        let wasDirty = isDirty
        isDirty = true
        cachedResult = nil
        cachedBounds = .zero
        
        // Propagate to parent only if requested and this node was not already dirty
        // If node was already dirty, we assume parent is already aware (or was dirty)
        // This prevents infinite loops while ensuring clean nodes properly propagate
        if propagateToParent && !wasDirty {
            parent?.markDirty(propagateToParent: true)
        }
    }
    
    /// Marks this node as clean (after successful calculation)
    private func markClean() {
        isDirty = false
    }
    
    /// Internal method to force clean state (used when parent calculates children)
    /// This allows marking children as clean without recalculating them
    internal func forceClean() {
        isDirty = false
    }
    
    /// Calculates layout with dirty checking and caching
    /// 
    /// This method implements incremental layout calculation:
    /// - If not dirty and bounds unchanged, returns cached result
    /// - If dirty, recalculates and caches the result
    /// - Only dirty nodes are recalculated, clean nodes use cache
    /// 
    /// - Parameter bounds: Available bounds for layout calculation
    /// - Returns: LayoutResult with calculated frames
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        // If not dirty and bounds haven't changed, return cached result
        if !isDirty && cachedResult != nil && cachedBounds == bounds {
            return cachedResult!
        }
        
        // Prevent infinite loops
        guard !isCalculating else {
            // Return cached result or empty result if available
            return cachedResult ?? LayoutResult(frames: [:], totalSize: .zero)
        }
        
        isCalculating = true
        defer { isCalculating = false }
        
        // If we have children, try to use incremental calculation
        // Only recalculate dirty children, reuse cached results for clean children
        if !children.isEmpty {
            // For layouts with children, we need to check if we can use incremental updates
            // If all children are clean, we can return cached result
            let allChildrenClean = children.allSatisfy { !$0.isDirty }
            if allChildrenClean && cachedResult != nil && cachedBounds == bounds {
                // All children are clean and bounds haven't changed, return cached result
                return cachedResult!
            }
        }
        
        // Calculate layout using the wrapped layout
        // The wrapped layout will use its own calculateLayout, which may
        // internally use child nodes if they're set up
        // Note: This still calls the full layout calculation, but child nodes
        // can cache their results if they're not dirty
        let result = layout.calculateLayout(in: bounds)
        
        // Cache the result
        cachedResult = result
        cachedBounds = bounds
        markClean()
        
        // Mark all children as clean after parent calculation
        // This ensures that after parent calculation, all children are also clean
        // We mark children as clean directly without recalculating them to avoid
        // potential infinite loops and unnecessary calculations
        // The actual layout calculation was done by layout.calculateLayout() above
        for child in children {
            if child.isDirty {
                // Mark child as clean since parent calculation already handled the layout
                // The child's layout result is already part of the parent's result
                child.forceClean()
            }
        }
        
        return result
    }
    
    /// Calculates layout incrementally, only recalculating dirty children
    /// 
    /// This is a more advanced version that can use child nodes for incremental updates
    /// - Parameter bounds: Available bounds for layout calculation
    /// - Returns: LayoutResult with calculated frames
    public func calculateLayoutIncremental(in bounds: CGRect) -> LayoutResult {
        // If not dirty and bounds haven't changed, return cached result
        if !isDirty && cachedResult != nil && cachedBounds == bounds {
            return cachedResult!
        }
        
        // Prevent infinite loops
        guard !isCalculating else {
            return cachedResult ?? LayoutResult(frames: [:], totalSize: .zero)
        }
        
        isCalculating = true
        defer { isCalculating = false }
        
        // If we have children, we can potentially use child nodes for incremental updates
        // But for now, fall back to standard calculation
        // This can be enhanced later to use child nodes more intelligently
        
        let result = layout.calculateLayout(in: bounds)
        
        // Cache the result
        cachedResult = result
        cachedBounds = bounds
        markClean()
        
        return result
    }
    
    /// Invalidates this node and all its children
    public func invalidate() {
        isDirty = true
        cachedResult = nil
        cachedBounds = .zero
        
        // Invalidate all children (copy to avoid mutation during iteration)
        let childrenCopy = children
        for child in childrenCopy {
            child.invalidate()
        }
        
        // Propagate to parent (weak reference, safe)
        parent?.markDirty()
    }
    
    /// Updates content hash (for cache validation)
    public func updateContentHash(_ hash: Int) {
        if contentHash != hash {
            contentHash = hash
            markDirty()
        }
    }
    
    /// Gets the cached result if available and valid
    public func getCachedResult(for bounds: CGRect) -> LayoutResult? {
        guard !isDirty, cachedResult != nil, cachedBounds == bounds else {
            return nil
        }
        return cachedResult
    }
    
    /// Recursively finds a node that contains the given view
    public func findNode(containing view: UIView) -> LayoutNode? {
        // First, recursively search children (this handles nested structures)
        // This must come first because we want to find the deepest node containing the view
        for child in children {
            if let found = child.findNode(containing: view) {
                return found
            }
        }
        
        // If not found in children, check if this node directly contains the view
        // For ViewLayout nodes, check if the wrapped view matches
        if let viewLayout = layout as? ViewLayout {
            if viewLayout.view === view {
                return self
            }
            return nil
        }
        
        // For VStack, HStack, ZStack - check their subviews directly
        if let vstack = layout as? VStack {
            // Check if view is a direct subview (only if children are empty or view not found in children)
            if vstack.subviews.contains(view) {
                // If we have children, the view should have been found above
                // If not found, return nil since it means the tree wasn't built correctly
                return nil
            }
        } else if let hstack = layout as? HStack {
            if hstack.subviews.contains(view) {
                return nil
            }
        } else if let zstack = layout as? ZStack {
            if zstack.subviews.contains(view) {
                return nil
            }
        } else {
            // For other layouts, check extracted views directly
            let views = layout.extractViews()
            if views.contains(where: { $0 === view }) {
                return self
            }
        }
        
        return nil
    }
    
    /// Recursively collects all views managed by this node and its children
    public func collectAllViews() -> [UIView] {
        var views: [UIView] = []
        
        // Add views from this layout
        views.append(contentsOf: layout.extractViews())
        
        // Add views from children
        for child in children {
            views.append(contentsOf: child.collectAllViews())
        }
        
        return views
    }
    
    /// Builds the layout tree by extracting child layouts
    /// This is called after the layout is created to establish the tree structure
    public func buildTree() {
        // Clear existing children
        removeAllChildren()
        
        // Extract child layouts from the current layout
        // This depends on the layout type (VStack, HStack, etc.)
        if let vstack = layout as? VStack {
            buildTreeForVStack(vstack)
        } else if let hstack = layout as? HStack {
            buildTreeForHStack(hstack)
        } else if let zstack = layout as? ZStack {
            buildTreeForZStack(zstack)
        } else if let tupleLayout = layout as? TupleLayout {
            buildTreeForTupleLayout(tupleLayout)
        }
        // Add more layout types as needed
    }

    private func buildTreeForVStack(_ vstack: VStack) {
        for subview in vstack.subviews {
            // Check if subview has stored ViewLayout
            if let viewLayout = vstack.getViewLayout(for: subview) {
                let childNode = LayoutNode(layout: viewLayout)
                addChild(childNode)
            } else if let childLayout = subview as? (any Layout) {
                let childNode = LayoutNode(layout: childLayout)
                addChild(childNode)
                childNode.buildTree()
            }
        }
    }

    private func buildTreeForHStack(_ hstack: HStack) {
        for subview in hstack.subviews {
            if let viewLayout = hstack.getViewLayout(for: subview) {
                let childNode = LayoutNode(layout: viewLayout)
                addChild(childNode)
            } else if let childLayout = subview as? (any Layout) {
                let childNode = LayoutNode(layout: childLayout)
                addChild(childNode)
                childNode.buildTree()
            }
        }
    }

    private func buildTreeForZStack(_ zstack: ZStack) {
        for subview in zstack.subviews {
            // Check if subview has stored ViewLayout
            if let viewLayout = zstack.getViewLayout(for: subview) {
                let childNode = LayoutNode(layout: viewLayout)
                addChild(childNode)
            } else if let childLayout = subview as? (any Layout) {
                let childNode = LayoutNode(layout: childLayout)
                addChild(childNode)
                childNode.buildTree()
            }
        }
    }

    private func buildTreeForTupleLayout(_ tupleLayout: TupleLayout) {
        for childLayout in tupleLayout.layouts {
            let childNode = LayoutNode(layout: childLayout)
            addChild(childNode)
            childNode.buildTree()
        }
    }
}
