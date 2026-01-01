import UIKit

/// A SwiftUI-style container view that automatically manages view hierarchy and centers content.
///
/// ``LayoutContainer`` provides a SwiftUI-like experience with automatic content centering
/// and declarative layout definitions. It automatically adds and removes views based on
/// the current layout definition, just like SwiftUI's body.
///
/// ## Overview
///
/// `LayoutContainer` is the main entry point for using the ManualLayout system
/// in UIKit applications. It provides a SwiftUI-like experience with automatic
/// view hierarchy management and content centering.
///
/// ## Key Features
///
/// - **Automatic Centering**: Content is automatically centered like SwiftUI
/// - **Automatic View Management**: Views are added/removed automatically
/// - **Conditional Layout Support**: Dynamic content handling
/// - **High-performance Frame-based Layout**: No Auto Layout constraints
/// - **SwiftUI-style API**: Familiar declarative syntax
/// - **ScrollView Integration**: Special handling for scrollable content
///
/// ## Example Usage
///
/// ```swift
/// class MyViewController: UIViewController, Layout {
///     let layoutContainer = LayoutContainer()
///     let titleLabel = UILabel()
///     let actionButton = UIButton()
///     
///     override func viewDidLoad() {
///         super.viewDidLoad()
///         
///         // Setup views
///         titleLabel.text = "Welcome!"
///         actionButton.setTitle("Get Started", for: .normal)
///         
///         // Add container and set body - content is automatically centered!
///         view.addSubview(layoutContainer)
///         layoutContainer.frame = view.bounds
///         layoutContainer.setBody { self.body }
///     }
///     
///     @LayoutBuilder var body: Layout {
///         // Content is automatically centered like SwiftUI
///         titleLabel.layout()
///         actionButton.layout()
///     }
/// }
/// ```
///
/// ## Topics
///
/// ### Initialization
/// - ``init()``
///
/// ### Content Management
/// - ``setBody(_:)``
/// - ``body``
///
/// ### Layout Updates
/// - ``updateLayoutForOrientationChange()``
@MainActor
public class LayoutContainer: UIView {
    private var _body: (() -> any Layout)?
    private var managedViews: Set<UIView> = []
    private var cachedLayout: (any Layout)?
    private var lastBounds: CGRect = .zero
    private var needsHierarchyUpdate: Bool = false
    private var animatingViews: Set<UIView> = []
    private var animatingViewIdentifiers: Set<ObjectIdentifier> = []
    
    /// Root node of the layout tree
    private var rootNode: LayoutNode?
    
    /// Whether to use incremental layout updates (Layout Tree optimization)
    public var useIncrementalLayout: Bool = true
    
    /// Identity-to-view mapping for efficient diffing
    private var identityToViewMap: [AnyHashable: UIView] = [:]
    
    public var body: (any Layout)? {
        get { _body?() }
        set { _body = { newValue! } }
    }
    
    /// Sets the body with SwiftUI-style automatic centering
    public func setBody(@LayoutBuilder _ content: @escaping () -> any Layout) {
        _body = content
        needsHierarchyUpdate = true
        
        // Invalidate layout tree when body changes
        if useIncrementalLayout {
            rootNode?.invalidate()
            rootNode = nil // Will be rebuilt on next layout pass
        }
        
        // Use invalidation rules to determine if layout is needed
        let rules = LayoutInvalidationRules.default
        if rules.shouldInvalidate(for: .hierarchyChanged) {
            setNeedsLayout()
        }
    }
    
    /// Updates layout for orientation changes
    public func updateLayoutForOrientationChange() {
        needsHierarchyUpdate = true
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    /// Marks a view as animating to prevent layout system from overriding its frame
    public func startAnimating(_ view: UIView) {
        animatingViews.insert(view)
        animatingViewIdentifiers.insert(ObjectIdentifier(view))
    }
    
    /// Marks a view as no longer animating
    public func stopAnimating(_ view: UIView) {
        animatingViews.remove(view)
        animatingViewIdentifiers.remove(ObjectIdentifier(view))
    }
    
    /// Returns true if any views are currently animating
    public var isAnimating: Bool {
        return !animatingViews.isEmpty
    }
    
    /// Updates the layout body with animation
    ///
    /// Usage:
    /// ```swift
    /// layoutContainer.setBodyAnimated(animation: .spring()) {
    ///     self.body
    /// }
    /// ```
    public func setBodyAnimated(animation: LayoutAnimation = .default, @LayoutBuilder _ content: @escaping () -> any Layout) {
        // Update body
        _body = content
        
        // Get the new layout
        guard let newBody = body else { return }
        
        // Like SwiftUI, automatically wrap in VStack if not using Stack
        let layout: any Layout
        if isStackLayout(newBody) {
            layout = newBody
        } else {
            layout = createAutoVStack(from: newBody)
        }
        
        // Check if views have changed by comparing view instances
        let newViews = layout.extractViews()
        let currentViews = subviews
        
        // Check if views are the same (same count and same instances)
        let viewsChanged = newViews.count != currentViews.count || 
                          !newViews.elementsEqual(currentViews, by: { $0 === $1 })
        
        // If views have changed, update hierarchy first (no animation for hierarchy changes)
        if viewsChanged || needsHierarchyUpdate {
            needsHierarchyUpdate = false
            updateViewHierarchy()
            // After hierarchy update, apply layout immediately without animation
            applyLayout()
            return
        }
        
        // Update cached layout
        cachedLayout = layout
        
        // Animate only the frame changes (views already exist and are the same)
        applyLayoutAnimated(animation: animation)
    }
    
    private func updateViewHierarchy() {
        guard let body = body else {
            // Clear everything if no body
            subviews.forEach { $0.removeFromSuperview() }
            identityToViewMap.removeAll()
            cachedLayout = nil
            rootNode = nil
            return
        }
        
        // Like SwiftUI, automatically wrap in VStack if not using Stack
        let layout: any Layout
        if isStackLayout(body) {
            // If already Stack, use existing approach
            layout = body
        } else {
            // If not Stack, wrap in VStack
            layout = createAutoVStack(from: body)
        }
        
        // Before setting new layout, remove old top-level views that are no longer in the new layout
        // This prevents duplicate views when VStack is recreated
        if let oldLayout = cachedLayout {
            let oldTopLevelViews = oldLayout.extractViews()
            let newTopLevelViews = layout.extractViews()
            let oldTopLevelSet = Set(oldTopLevelViews.map { ObjectIdentifier($0) })
            let newTopLevelSet = Set(newTopLevelViews.map { ObjectIdentifier($0) })
            
            // Remove old top-level views that are not in new layout
            for oldView in oldTopLevelViews {
                if !newTopLevelSet.contains(ObjectIdentifier(oldView)) && oldView.superview == self {
                    oldView.removeFromSuperview()
                }
            }
        }
        
        // Extract top-level views from new layout first
        let newTopLevelViews = layout.extractViews()
        
        // Add new top-level views that aren't already in hierarchy
        for view in newTopLevelViews {
            if view.superview == nil {
                addSubview(view)
            }
        }
        
        // Remove old top-level views that are no longer in the new layout
        // This prevents duplicate views when VStack is recreated
        if let oldLayout = cachedLayout {
            let oldTopLevelViews = oldLayout.extractViews()
            let oldTopLevelSet = Set(oldTopLevelViews.map { ObjectIdentifier($0) })
            let newTopLevelSet = Set(newTopLevelViews.map { ObjectIdentifier($0) })
            
            // Remove old top-level views that are not in new layout
            for oldView in oldTopLevelViews {
                if !newTopLevelSet.contains(ObjectIdentifier(oldView)) && oldView.superview == self {
                    oldView.removeFromSuperview()
                }
            }
        }
        
        cachedLayout = layout
        
        // Build layout tree if incremental layout is enabled
        if useIncrementalLayout {
            rootNode = LayoutNode(layout: layout)
            rootNode?.buildTree()
        }
        
        // Extract all views from the new layout (including nested views in VStack, HStack, etc.)
        let allNewViews = extractAllViews(from: layout)
        
        // Build identity map for all views (not just top-level)
        var newIdentityMap: [AnyHashable: UIView] = [:]
        for view in allNewViews {
            if let identity = view.layoutIdentity {
                newIdentityMap[identity] = view
            }
        }
        
        // Get current views in hierarchy (including nested views)
        let allCurrentViews = getAllViewsInHierarchy()
        
        // Build old identity map from current hierarchy
        var oldIdentityMap: [AnyHashable: UIView] = [:]
        for view in allCurrentViews {
            if let identity = view.layoutIdentity {
                oldIdentityMap[identity] = view
            }
        }
        
        // Perform identity-based diffing for all views
        performIdentityDiff(oldMap: oldIdentityMap, newMap: newIdentityMap, newViews: allNewViews)
        
        // Update identity map
        identityToViewMap = newIdentityMap
    }
    
    /// Performs identity-based diffing to efficiently update view hierarchy
    private func performIdentityDiff(oldMap: [AnyHashable: UIView], newMap: [AnyHashable: UIView], newViews: [UIView]) {
        // Find views to remove (in old but not in new)
        let oldIdentities = Set(oldMap.keys)
        let newIdentities = Set(newMap.keys)
        let identitiesToRemove = oldIdentities.subtracting(newIdentities)
        
        // Remove views that no longer exist (remove from any superview, not just LayoutContainer)
        for identity in identitiesToRemove {
            if let view = oldMap[identity], view.superview != nil {
                view.removeFromSuperview()
            }
        }
        
        // Find views to add (in new but not in old)
        let identitiesToAdd = newIdentities.subtracting(oldIdentities)
        
        // Note: New views are already added by VStack/HStack init
        // We don't need to add them here, but we need to ensure they're not removed
        // The views will be in the hierarchy already from the layout extraction
        
        // For views with matching identities, reuse existing views
        let matchingIdentities = oldIdentities.intersection(newIdentities)
        for identity in matchingIdentities {
            if let oldView = oldMap[identity], let newView = newMap[identity] {
                // If views are different instances but same identity, replace
                if oldView !== newView {
                    // Remove old view from its superview
                    if oldView.superview != nil {
                        oldView.removeFromSuperview()
                    }
                    // New view will be added by its parent container (VStack/HStack)
                }
                // If same instance, keep it (no action needed)
            }
        }
        
        // Handle views without identity
        // First, find all current views without identity that should be removed
        let allCurrentViews = getAllViewsInHierarchy()
        let currentViewsWithoutIdentity = allCurrentViews.filter { $0.layoutIdentity == nil }
        let newViewsWithoutIdentity = newViews.filter { $0.layoutIdentity == nil }
        
        // Remove old views without identity that are not in new views
        for oldView in currentViewsWithoutIdentity {
            if !newViewsWithoutIdentity.contains(where: { $0 === oldView }) {
                // This view is no longer needed, remove it
                if oldView.superview != nil {
                    oldView.removeFromSuperview()
                }
            }
        }
        
        // New views without identity will be added by their parent containers (VStack/HStack init)
    }
    
    /// Apply layout to views (only updates frames, doesn't modify hierarchy)
    private func applyLayout() {
        guard let layout = cachedLayout else { return }
        
        // Use incremental layout if enabled and tree is available
        let result: LayoutResult
        if useIncrementalLayout, let node = rootNode {
            // Use LayoutNode for incremental calculation
            result = node.calculateLayout(in: bounds)
        } else {
            // Fallback to full calculation
            result = layout.calculateLayout(in: bounds)
        }
        
        let topLevelViews = layout.extractViews()
        
        // Check if the body is a ScrollView or contains ScrollView
        let isScrollView = layout is ScrollView || topLevelViews.contains { $0 is ScrollView }
        
        // Apply frames to all views in result.frames (not just topLevelViews)
        // This ensures nested views are also handled
        for (view, frame) in result.frames {
            // Skip views that are currently animating (check both Set and ObjectIdentifier for reliability)
            if animatingViews.contains(view) || animatingViewIdentifiers.contains(ObjectIdentifier(view)) {
                continue
            }
            
            // Only apply frames to views that are actually in the view hierarchy
            // Check if view is a direct subview or nested within subviews
            let isInHierarchy = view.superview == self || 
                                subviews.contains(view) ||
                                subviews.contains(where: { $0.subviews.contains(view) || $0 === view })
            
            guard isInHierarchy else {
                // View is not in hierarchy, skip it
                continue
            }
            
            if isScrollView {
                // For ScrollView, use the frame directly without centering
                view.frame = frame
            } else {
                // Calculate center offset for other layouts
                let centerX = max(0, (bounds.width - result.totalSize.width) / 2)
                let centerY = max(0, (bounds.height - result.totalSize.height) / 2)
                
                // Apply center offset to all views
                let adjustedFrame = CGRect(
                    x: frame.origin.x + centerX,
                    y: frame.origin.y + centerY,
                    width: frame.width,
                    height: frame.height
                )
                view.frame = adjustedFrame
            }
        }
    }
    
    /// Apply layout to views with animation (only updates frames, doesn't modify hierarchy)
    func applyLayoutAnimated(animation: LayoutAnimation) {
        guard let layout = cachedLayout else { return }
        
        let result = layout.calculateLayout(in: bounds)
        let topLevelViews = layout.extractViews()
        
        // Check if the body is a ScrollView or contains ScrollView
        let isScrollView = layout is ScrollView || topLevelViews.contains { $0 is ScrollView }
        
        // Find ScrollView if it exists
        let scrollView = topLevelViews.first { $0 is ScrollView } as? ScrollView
        
        // Filter out views that are inside ScrollView (we don't animate those)
        let viewsToAnimate: [UIView]
        if let scrollView = scrollView {
            // Only animate views that are direct children of LayoutContainer, not inside ScrollView
            viewsToAnimate = topLevelViews.filter { view in
                // If it's the ScrollView itself, animate it
                if view === scrollView {
                    return true
                }
                // If it's inside ScrollView, don't animate
                if scrollView.subviews.contains(where: { $0 === view || $0.subviews.contains(view) }) {
                    return false
                }
                return true
            }
        } else {
            viewsToAnimate = topLevelViews
        }
        
        switch animation.timingFunction {
        case .spring(let damping, let velocity):
            UIView.animate(
                withDuration: animation.duration,
                delay: animation.delay,
                usingSpringWithDamping: damping,
                initialSpringVelocity: velocity,
                options: [.beginFromCurrentState, .allowUserInteraction],
                animations: {
                    for view in viewsToAnimate {
                        if let frame = result.frames[view] {
                            if isScrollView && view === scrollView {
                                // For ScrollView itself, just update its frame
                                view.frame = frame
                            } else if !isScrollView {
                                // Calculate center offset for other layouts
                                let centerX = max(0, (self.bounds.width - result.totalSize.width) / 2)
                                let centerY = max(0, (self.bounds.height - result.totalSize.height) / 2)
                                
                                let adjustedFrame = CGRect(
                                    x: frame.origin.x + centerX,
                                    y: frame.origin.y + centerY,
                                    width: frame.width,
                                    height: frame.height
                                )
                                view.frame = adjustedFrame
                            }
                        }
                    }
                }
            )
        default:
            UIView.animate(
                withDuration: animation.duration,
                delay: animation.delay,
                options: [animation.timingFunction.animationOptions, .beginFromCurrentState, .allowUserInteraction],
                animations: {
                    for view in viewsToAnimate {
                        if let frame = result.frames[view] {
                            if isScrollView && view === scrollView {
                                // For ScrollView itself, just update its frame
                                view.frame = frame
                            } else if !isScrollView {
                                // Calculate center offset for other layouts
                                let centerX = max(0, (self.bounds.width - result.totalSize.width) / 2)
                                let centerY = max(0, (self.bounds.height - result.totalSize.height) / 2)
                                
                                let adjustedFrame = CGRect(
                                    x: frame.origin.x + centerX,
                                    y: frame.origin.y + centerY,
                                    width: frame.width,
                                    height: frame.height
                                )
                                view.frame = adjustedFrame
                            }
                        }
                    }
                }
            )
        }
        
        // For ScrollView content, apply layout without animation (to avoid scroll jumping)
        if let scrollView = scrollView {
            // Apply layout to ScrollView content immediately without animation
            let scrollContentViews = topLevelViews.filter { view in
                scrollView.subviews.contains(where: { $0 === view || $0.subviews.contains(view) })
            }
            
            for view in scrollContentViews {
                if let frame = result.frames[view] {
                    view.frame = frame
                }
            }
        }
    }
    
    /// Recursively extracts all views from a layout hierarchy (including nested VStack, HStack, etc.)
    private func extractAllViews(from layout: any Layout) -> [UIView] {
        var allViews: [UIView] = []
        let topLevelViews = layout.extractViews()
        
        for view in topLevelViews {
            allViews.append(view)
            
            // Recursively extract views from nested stacks
            if let vstack = view as? VStack {
                allViews.append(contentsOf: extractAllViewsFromView(vstack))
            } else if let hstack = view as? HStack {
                allViews.append(contentsOf: extractAllViewsFromView(hstack))
            } else if let zstack = view as? ZStack {
                allViews.append(contentsOf: extractAllViewsFromView(zstack))
            }
        }
        
        return allViews
    }
    
    /// Recursively extracts all views from a UIView hierarchy
    private func extractAllViewsFromView(_ view: UIView) -> [UIView] {
        var allViews: [UIView] = [view]
        
        for subview in view.subviews {
            allViews.append(contentsOf: extractAllViewsFromView(subview))
        }
        
        return allViews
    }
    
    /// Gets all views currently in the hierarchy (including nested views)
    private func getAllViewsInHierarchy() -> [UIView] {
        var allViews: [UIView] = []
        
        for subview in subviews {
            allViews.append(contentsOf: extractAllViewsFromView(subview))
        }
        
        return allViews
    }
    
    /// Check if the layout is a Stack type (VStack, HStack, ZStack)
    private func isStackLayout(_ layout: any Layout) -> Bool {
        let views = layout.extractViews()
        return views.contains { $0 is VStack || $0 is HStack || $0 is ZStack }
    }
    
    /// Create an automatic VStack from non-stack layout
    private func createAutoVStack(from layout: any Layout) -> VStack {
        if let tupleLayout = layout as? TupleLayout {
            let vstack = VStack(spacing: 20) {
                for childLayout in tupleLayout.layouts {
                    let views = childLayout.extractViews()
                    for view in views {
                        view.layout()
                    }
                }
            }
            return vstack
        } else {
            // For single layout, wrap in VStack
            let vstack = VStack(alignment: .center, spacing: 20) {
                // Extract and add views from single layout
                let views = layout.extractViews()
                for view in views {
                    view.layout()
                }
            }
            return vstack
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard bounds.width > 0 && bounds.height > 0 else { return }
        
        // Only update hierarchy when needed (setBody was called)
        if needsHierarchyUpdate {
            needsHierarchyUpdate = false
            updateViewHierarchy()
        }
        
        // Rebuild layout tree if needed (e.g., after toggling incremental layout)
        // This happens without touching the view hierarchy
        if useIncrementalLayout && rootNode == nil, let layout = cachedLayout {
            rootNode = LayoutNode(layout: layout)
            rootNode?.buildTree()
        }
        
        // Skip layout updates if any views are currently animating
        // This prevents layout from overriding animations
        if !animatingViews.isEmpty {
            return
        }
        
        // Only update frames if bounds changed or layout is dirty
        let boundsChanged = lastBounds != bounds
        let layoutDirty: Bool
        if useIncrementalLayout {
            // If incremental layout is enabled, check if rootNode is dirty
            // If rootNode is nil, we need to rebuild it, so consider it dirty
            layoutDirty = rootNode?.isDirty ?? true
        } else {
            // If incremental layout is disabled, always recalculate
            layoutDirty = true
        }
        
        if boundsChanged || layoutDirty {
            lastBounds = bounds
            applyLayout()
        }
    }
    
    /// Marks a specific view's layout as dirty, triggering incremental recalculation
    public func markViewDirty(_ view: UIView) {
        guard useIncrementalLayout, let node = rootNode else {
            // Fallback: invalidate entire layout
            setNeedsLayout()
            return
        }
        
        // Find the node containing this view
        if let targetNode = node.findNode(containing: view) {
            targetNode.markDirty()
            setNeedsLayout()
        } else {
            // If not found, invalidate root
            node.invalidate()
            setNeedsLayout()
        }
    }
    
    /// Invalidates the entire layout tree
    public func invalidateLayoutTree() {
        rootNode?.invalidate()
        setNeedsLayout()
    }
    
    /// Rebuilds the layout tree (useful when toggling incremental layout)
    /// This only rebuilds the tree structure, not the view hierarchy
    /// Note: This will be automatically called in the next layoutSubviews() pass
    public func rebuildLayoutTree() {
        // Simply invalidate the root node - it will be rebuilt in layoutSubviews()
        // This is safer than trying to rebuild it immediately
        rootNode?.invalidate()
        rootNode = nil
        // Don't set needsHierarchyUpdate - we don't want to remove/add views
        // The tree will be rebuilt in layoutSubviews() when needed
    }
}

