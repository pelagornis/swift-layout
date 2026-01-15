import UIKit
import CoreGraphics

/// Value-type data structure for a layout node stored in contiguous memory
/// This is used by LayoutNodeBuffer for efficient cache-friendly access
@MainActor
public struct LayoutNodeData {
    /// Unique identifier for this node (for diffing and view lookup)
    var id: Int
    
    /// The wrapped layout (stored as reference, but node data is value-type)
    let layout: any Layout
    
    /// Index of parent node (nil for root)
    var parentIndex: Int?
    
    /// Indices of child nodes
    var childIndices: [Int]
    
    /// Whether this node needs recalculation
    var isDirty: Bool
    
    /// Cached layout result (valid only when !isDirty)
    var cachedResult: LayoutResult?
    
    /// Cached bounds used for the cached result
    var cachedBounds: CGRect
    
    /// Content hash for cache validation
    var contentHash: Int
    
    /// Whether this node is currently being calculated (prevents infinite loops)
    var isCalculating: Bool
    
    /// Whether this slot is free (for reuse)
    var isFree: Bool
    
    public init(
        id: Int,
        layout: any Layout,
        parentIndex: Int? = nil,
        childIndices: [Int] = [],
        isDirty: Bool = true,
        cachedResult: LayoutResult? = nil,
        cachedBounds: CGRect = .zero,
        contentHash: Int = 0,
        isCalculating: Bool = false,
        isFree: Bool = false
    ) {
        self.id = id
        self.layout = layout
        self.parentIndex = parentIndex
        self.childIndices = childIndices
        self.isDirty = isDirty
        self.cachedResult = cachedResult
        self.cachedBounds = cachedBounds
        self.contentHash = contentHash
        self.isCalculating = isCalculating
        self.isFree = isFree
    }
}

/// High-performance layout tree buffer using contiguous memory array
/// 
/// LayoutNodeBuffer provides the same functionality as LayoutNode but uses
/// a contiguous memory array (value-type buffer) instead of object references.
/// This improves CPU cache efficiency and reduces memory overhead.
///
/// ## Performance Benefits
///
/// - **CPU Cache Efficiency**: Contiguous memory improves cache locality
/// - **Memory Allocation**: Single allocation instead of many small heap allocations
/// - **ARC Overhead**: No reference counting needed for node data
/// - **SIMD Optimization**: Vector operations possible on contiguous arrays
///
/// ## Usage
///
/// ```swift
/// let buffer = LayoutNodeBuffer()
/// let rootIndex = buffer.addNode(layout: rootLayout)
/// buffer.buildTree(rootIndex: rootIndex)
/// let result = buffer.calculateLayout(at: rootIndex, in: bounds)
/// ```
@MainActor
public class LayoutNodeBuffer {
    /// Contiguous array of layout node data
    private var nodes: [LayoutNodeData] = []
    
    /// Stack of free indices for reuse
    private var freeIndices: [Int] = []
    
    /// Next available node ID
    private var nextNodeID: Int = 0
    
    /// Root node index
    private var rootIndex: Int?
    
    /// Creates a new layout node buffer
    public init() {
        // Pre-allocate some capacity for better performance
        nodes.reserveCapacity(64)
    }
    
    // MARK: - Node Management
    
    /// Adds a new node to the buffer
    /// - Parameter layout: The layout to wrap
    /// - Parameter parentIndex: Optional parent node index
    /// - Returns: Index of the newly added node
    @discardableResult
    public func addNode(layout: any Layout, parentIndex: Int? = nil) -> Int {
        let index: Int
        
        // Reuse free slot if available
        if let freeIndex = freeIndices.popLast() {
            index = freeIndex
            nodes[index] = LayoutNodeData(
                id: nextNodeID,
                layout: layout,
                parentIndex: parentIndex,
                isDirty: true
            )
        } else {
            // Add new node
            index = nodes.count
            nodes.append(LayoutNodeData(
                id: nextNodeID,
                layout: layout,
                parentIndex: parentIndex,
                isDirty: true
            ))
        }
        
        nextNodeID += 1
        
        // Update parent's child list
        if let parentIndex = parentIndex {
            nodes[parentIndex].childIndices.append(index)
        }
        
        return index
    }
    
    /// Removes a node and all its children
    /// - Parameter index: Index of node to remove
    public func removeNode(at index: Int) {
        guard index < nodes.count, !nodes[index].isFree else { return }
        
        // Recursively remove children
        let childIndices = nodes[index].childIndices
        for childIndex in childIndices {
            removeNode(at: childIndex)
        }
        
        // Remove from parent's child list
        if let parentIndex = nodes[index].parentIndex {
            nodes[parentIndex].childIndices.removeAll { $0 == index }
        }
        
        // Mark as free for reuse
        nodes[index].isFree = true
        freeIndices.append(index)
        
        // Clear node data
        nodes[index] = LayoutNodeData(
            id: -1,
            layout: EmptyLayout(),
            isFree: true
        )
    }
    
    /// Gets node data at the specified index
    /// - Parameter index: Node index
    /// - Returns: Node data (or nil if index is invalid or free)
    public func getNode(at index: Int) -> LayoutNodeData? {
        guard index < nodes.count, !nodes[index].isFree else { return nil }
        return nodes[index]
    }
    
    /// Sets node data at the specified index
    /// - Parameters:
    ///   - data: New node data
    ///   - index: Node index
    public func setNode(_ data: LayoutNodeData, at index: Int) {
        guard index < nodes.count else { return }
        nodes[index] = data
    }
    
    /// Sets the root node index
    /// - Parameter index: Root node index
    public func setRootIndex(_ index: Int?) {
        rootIndex = index
    }
    
    /// Gets the root node index
    /// - Returns: Root node index (or nil if no root)
    public func getRootIndex() -> Int? {
        return rootIndex
    }
    
    // MARK: - Tree Operations
    
    /// Builds the layout tree by extracting child layouts
    /// - Parameter rootIndex: Index of root node
    public func buildTree(rootIndex: Int) {
        self.rootIndex = rootIndex
        buildTreeRecursive(at: rootIndex)
    }
    
    private func buildTreeRecursive(at index: Int) {
        guard let node = getNode(at: index) else { return }
        
        // Clear existing children
        nodes[index].childIndices.removeAll()
        
        // Extract child layouts based on layout type
        let layout = node.layout
        
        if let vstack = layout as? VStack {
            buildTreeForVStack(vstack, parentIndex: index)
        } else if let hstack = layout as? HStack {
            buildTreeForHStack(hstack, parentIndex: index)
        } else if let zstack = layout as? ZStack {
            buildTreeForZStack(zstack, parentIndex: index)
        } else if let tupleLayout = layout as? TupleLayout {
            buildTreeForTupleLayout(tupleLayout, parentIndex: index)
        }
    }
    
    private func buildTreeForVStack(_ vstack: VStack, parentIndex: Int) {
        for subview in vstack.subviews {
            if let viewLayout = vstack.getViewLayout(for: subview) {
                let childIndex = addNode(layout: viewLayout, parentIndex: parentIndex)
                // Leaf node, no children
            } else if let childLayout = subview as? (any Layout) {
                let childIndex = addNode(layout: childLayout, parentIndex: parentIndex)
                buildTreeRecursive(at: childIndex)
            }
        }
    }
    
    private func buildTreeForHStack(_ hstack: HStack, parentIndex: Int) {
        for subview in hstack.subviews {
            if let viewLayout = hstack.getViewLayout(for: subview) {
                let childIndex = addNode(layout: viewLayout, parentIndex: parentIndex)
            } else if let childLayout = subview as? (any Layout) {
                let childIndex = addNode(layout: childLayout, parentIndex: parentIndex)
                buildTreeRecursive(at: childIndex)
            }
        }
    }
    
    private func buildTreeForZStack(_ zstack: ZStack, parentIndex: Int) {
        for subview in zstack.subviews {
            if let viewLayout = zstack.getViewLayout(for: subview) {
                let childIndex = addNode(layout: viewLayout, parentIndex: parentIndex)
            } else if let childLayout = subview as? (any Layout) {
                let childIndex = addNode(layout: childLayout, parentIndex: parentIndex)
                buildTreeRecursive(at: childIndex)
            }
        }
    }
    
    private func buildTreeForTupleLayout(_ tupleLayout: TupleLayout, parentIndex: Int) {
        for childLayout in tupleLayout.layouts {
            let childIndex = addNode(layout: childLayout, parentIndex: parentIndex)
            buildTreeRecursive(at: childIndex)
        }
    }
    
    // MARK: - Dirty State Management
    
    /// Marks a node as dirty and optionally propagates to parent
    /// - Parameters:
    ///   - index: Node index
    ///   - propagateToParent: If true, marks parent as dirty (default: true)
    public func markDirty(at index: Int, propagateToParent: Bool = true) {
        guard var node = getNode(at: index) else { return }
        
        let wasDirty = node.isDirty
        node.isDirty = true
        node.cachedResult = nil
        node.cachedBounds = .zero
        setNode(node, at: index)
        
        // Propagate to parent
        if propagateToParent && !wasDirty, let parentIndex = node.parentIndex {
            markDirty(at: parentIndex, propagateToParent: true)
        }
    }
    
    /// Marks a node as clean
    /// - Parameter index: Node index
    public func markClean(at index: Int) {
        guard var node = getNode(at: index) else { return }
        node.isDirty = false
        setNode(node, at: index)
    }
    
    /// Forces a node to clean state (used when parent calculates children)
    /// - Parameter index: Node index
    public func forceClean(at index: Int) {
        markClean(at: index)
    }
    
    /// Invalidates a node and all its children
    /// - Parameter index: Node index
    public func invalidate(at index: Int) {
        guard var node = getNode(at: index) else { return }
        
        node.isDirty = true
        node.cachedResult = nil
        node.cachedBounds = .zero
        setNode(node, at: index)
        
        // Invalidate all children
        for childIndex in node.childIndices {
            invalidate(at: childIndex)
        }
        
        // Propagate to parent
        if let parentIndex = node.parentIndex {
            markDirty(at: parentIndex, propagateToParent: true)
        }
    }
    
    // MARK: - Layout Calculation
    
    /// Calculates layout with dirty checking and caching
    /// - Parameters:
    ///   - index: Node index
    ///   - bounds: Available bounds for layout calculation
    /// - Returns: LayoutResult with calculated frames
    public func calculateLayout(at index: Int, in bounds: CGRect) -> LayoutResult {
        guard var node = getNode(at: index) else {
            return LayoutResult(frames: [:], totalSize: CGSize.zero)
        }
        
        // If not dirty and bounds haven't changed, return cached result
        if !node.isDirty, let cached = node.cachedResult, node.cachedBounds == bounds {
            return cached
        }
        
        // Prevent infinite loops
        guard !node.isCalculating else {
            return node.cachedResult ?? LayoutResult(frames: [:], totalSize: CGSize.zero)
        }
        
        node.isCalculating = true
        setNode(node, at: index)
        defer {
            var updatedNode = getNode(at: index)!
            updatedNode.isCalculating = false
            setNode(updatedNode, at: index)
        }
        
        // Check if all children are clean
        if !node.childIndices.isEmpty {
            let allChildrenClean = node.childIndices.allSatisfy { childIndex in
                guard let child = getNode(at: childIndex) else { return false }
                return !child.isDirty
            }
            
            if allChildrenClean, let cached = node.cachedResult, node.cachedBounds == bounds {
                return cached
            }
        }
        
        // Calculate layout using the wrapped layout
        let result = node.layout.calculateLayout(in: bounds)
        
        // Cache the result
        node.cachedResult = result
        node.cachedBounds = bounds
        node.isDirty = false
        setNode(node, at: index)
        
        // Mark all children as clean after parent calculation
        for childIndex in node.childIndices {
            if var child = getNode(at: childIndex), child.isDirty {
                child.isDirty = false
                setNode(child, at: childIndex)
            }
        }
        
        return result
    }
    
    // MARK: - View Lookup
    
    /// Recursively finds a node that contains the given view
    /// - Parameters:
    ///   - view: View to find
    ///   - index: Starting node index
    /// - Returns: Index of node containing the view (or nil if not found)
    public func findNode(containing view: UIView, startingAt index: Int) -> Int? {
        guard let node = getNode(at: index) else { return nil }
        
        // First, recursively search children
        for childIndex in node.childIndices {
            if let found = findNode(containing: view, startingAt: childIndex) {
                return found
            }
        }
        
        // Check if this node directly contains the view
        if let viewLayout = node.layout as? ViewLayout {
            if viewLayout.view === view {
                return index
            }
            return nil
        }
        
        // For VStack, HStack, ZStack - check their subviews directly
        if let vstack = node.layout as? VStack {
            if vstack.subviews.contains(where: { $0 === view }) {
                return nil // Should have been found in children
            }
        } else if let hstack = node.layout as? HStack {
            if hstack.subviews.contains(where: { $0 === view }) {
                return nil
            }
        } else if let zstack = node.layout as? ZStack {
            if zstack.subviews.contains(where: { $0 === view }) {
                return nil
            }
        } else {
            // For other layouts, check extracted views directly
            let views = node.layout.extractViews()
            if views.contains(where: { $0 === view }) {
                return index
            }
        }
        
        return nil
    }
    
    /// Recursively collects all views managed by a node and its children
    /// - Parameter index: Starting node index
    /// - Returns: Array of all views in this subtree
    public func collectAllViews(startingAt index: Int) -> [UIView] {
        guard let node = getNode(at: index) else { return [] }
        
        var views: [UIView] = []
        
        // Add views from this layout
        views.append(contentsOf: node.layout.extractViews())
        
        // Add views from children
        for childIndex in node.childIndices {
            views.append(contentsOf: collectAllViews(startingAt: childIndex))
        }
        
        return views
    }
    
    // MARK: - Statistics
    
    /// Gets the number of active (non-free) nodes
    /// - Returns: Count of active nodes
    public func activeNodeCount() -> Int {
        return nodes.filter { !$0.isFree }.count
    }
    
    /// Gets the total capacity (including free slots)
    /// - Returns: Total array capacity
    public func totalCapacity() -> Int {
        return nodes.count
    }
    
    /// Clears all nodes and resets the buffer
    public func clear() {
        nodes.removeAll()
        freeIndices.removeAll()
        nextNodeID = 0
        rootIndex = nil
    }
}
