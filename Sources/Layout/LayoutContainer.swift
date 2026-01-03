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
        
        // Don't invalidate node tree here - let updateViewHierarchy check if structure changed
        // This allows incremental updates when layout structure hasn't changed
        
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
        
        // Extract top-level views from new layout
        let newTopLevelViews = layout.extractViews()
        
        // Store old layout for diffing
        let oldLayout = cachedLayout
        
        // Check if layout structure has changed by comparing top-level view identities
        // This determines if we need to rebuild the node tree or can reuse it
        let layoutStructureChanged: Bool
        if let oldLayout = oldLayout {
            let oldTopLevelViews = oldLayout.extractViews()
            let oldIdentities = Set(oldTopLevelViews.compactMap { $0.layoutIdentity })
            let newIdentities = Set(newTopLevelViews.compactMap { $0.layoutIdentity })
            // Structure changed if identities don't match or count changed
            layoutStructureChanged = oldIdentities != newIdentities || oldTopLevelViews.count != newTopLevelViews.count
        } else {
            layoutStructureChanged = true
        }
        
        // Always update cachedLayout to use the new layout instance
        // This ensures applyLayout uses the correct layout instance that matches the current view hierarchy
        // Even if structure hasn't changed, we need to use the new layout instance
        // because performLayoutDiff may have updated the view hierarchy
        cachedLayout = layout
        
        // Build or reuse layout tree if incremental layout is enabled
        if useIncrementalLayout {
            if rootNode == nil {
                // No existing node: create new one (first time setup)
                rootNode = LayoutNode(layout: layout)
                rootNode?.buildTree()
                rootNode?.markDirty()
            } else if layoutStructureChanged {
                // Layout structure changed (items added/removed): rebuild node tree to match new structure
                // performLayoutDiff already handled view hierarchy updates (add/remove/reuse views)
                // But we need to rebuild the node tree to match the new layout structure
                // This rebuilds the tree, but applyLayout uses cachedLayout.calculateLayout() anyway
                // So the node tree is mainly for dirty tracking
                rootNode = LayoutNode(layout: layout)
                rootNode?.buildTree()
                // Only mark root as dirty - child nodes will be calculated fresh
                rootNode?.markDirty()
            } else {
                // Layout structure unchanged: reuse existing node tree
                // IMPORTANT: Don't rebuild node tree - this allows incremental updates
                // The existing node tree structure matches the new layout structure
                // Individual nodes will be marked dirty via markViewDirty for specific changes
                // Don't mark root as dirty here - only specific nodes should be dirty
            }
        }
        
        // Perform identity-based diffing for top-level views AFTER updating layout
        // This handles view reuse, removal, and addition based on identity
        // Do this after updating cachedLayout so both old and new layouts are available
        performLayoutDiff(oldLayout: oldLayout, newLayout: layout)
    }
    
    /// Performs identity-based diffing for Layout hierarchy
    /// This method matches views by identity and manages view reuse at the Layout level
    /// It handles view removal, reuse, and addition based on identity matching
    private func performLayoutDiff(oldLayout: (any Layout)?, newLayout: any Layout) {
        let oldTopLevelViews = oldLayout?.extractViews() ?? []
        let newTopLevelViews = newLayout.extractViews()
        
        // Debug logging for extracted views
        print("🔍 [LayoutContainer] performLayoutDiff:")
        print("  - oldTopLevelViews count: \(oldTopLevelViews.count)")
        for (index, view) in oldTopLevelViews.enumerated() {
            print("    [\(index)] \(type(of: view)) (identity: \(view.layoutIdentity?.description ?? "nil"), superview: \(view.superview != nil ? "exists" : "nil"))")
        }
        print("  - newTopLevelViews count: \(newTopLevelViews.count)")
        for (index, view) in newTopLevelViews.enumerated() {
            print("    [\(index)] \(type(of: view)) (identity: \(view.layoutIdentity?.description ?? "nil"), superview: \(view.superview != nil ? "exists" : "nil"))")
        }
        
        // Build identity maps for top-level views
        var oldIdentityMap: [AnyHashable: UIView] = [:]
        for view in oldTopLevelViews {
            if let identity = view.layoutIdentity {
                oldIdentityMap[identity] = view
            }
        }
        
        var newIdentityMap: [AnyHashable: UIView] = [:]
        for view in newTopLevelViews {
            if let identity = view.layoutIdentity {
                newIdentityMap[identity] = view
            }
        }
        
        // Update identity map for tracking
        identityToViewMap = newIdentityMap
        
        // Build instance sets for views without identity
        let oldInstanceSet = Set(oldTopLevelViews.map { ObjectIdentifier($0) })
        let newInstanceSet = Set(newTopLevelViews.map { ObjectIdentifier($0) })
        
        // Step 0: Special handling for ScrollView without identity (BEFORE Step 1)
        // Match old and new ScrollView instances by type (for ScrollView without identity)
        // This ensures ScrollView instances are reused when the layout structure hasn't changed
        var oldScrollView: ScrollView?
        var newScrollView: ScrollView?
        
        // IMPORTANT: Find old ScrollView from actual hierarchy (subviews), not from oldLayout.extractViews()
        // oldLayout.extractViews() returns views from the old layout instance, which may not match
        // the actual views currently in the hierarchy. We need to find the ScrollView that's
        // actually in the view hierarchy (subviews) to ensure we can reuse it.
        for subview in subviews {
            if let scrollView = subview as? ScrollView,
               scrollView.layoutIdentity == nil {
                oldScrollView = scrollView
                break
            }
        }
        
        for newView in newTopLevelViews {
            if let scrollView = newView as? ScrollView,
               scrollView.layoutIdentity == nil {
                newScrollView = scrollView
                break
            }
        }
        
        // Debug logging for ScrollView reuse detection
        print("🔍 [LayoutContainer] performLayoutDiff - ScrollView detection:")
        print("  - oldScrollView: \(oldScrollView != nil ? "found (instance: \(ObjectIdentifier(oldScrollView!)))" : "nil")")
        print("  - newScrollView: \(newScrollView != nil ? "found (instance: \(ObjectIdentifier(newScrollView!)))" : "nil")")
        if let oldSV = oldScrollView, let newSV = newScrollView {
            print("  - Same instance: \(oldSV === newSV)")
        }
        
        // Track if we should skip adding new ScrollView (because we're reusing old one)
        var skipAddingNewScrollView = false
        if let oldSV = oldScrollView, let newSV = newScrollView, oldSV !== newSV {
            // Both old and new ScrollView exist (different instances)
            // Reuse the old ScrollView instance to preserve scroll offset and cache
            // Prevent the old ScrollView from being removed in Step 1
            // Prevent the new ScrollView from being added in Step 3
            
            skipAddingNewScrollView = true
            print("🔄 [LayoutContainer] Reusing ScrollView instance to preserve state (old instance will be kept, new instance will be skipped)")
            
            // Update old ScrollView's child layout with new ScrollView's child layout
            // This ensures the content is updated while preserving scroll offset and cache
            if let newChildLayout = newSV.getChildLayout() {
                print("  - Updating old ScrollView's child layout with new layout")
                oldSV.updateChildLayout(newChildLayout)
            } else {
                print("  - ⚠️ New ScrollView has no childLayout - skipping update")
            }
        }
        
        // Step 1: Remove views that are no longer in the new layout
        // IMPORTANT: Don't remove old ScrollView if we're reusing it
        for oldView in oldTopLevelViews {
            // Skip removing old ScrollView if we're reusing it
            if skipAddingNewScrollView,
               let oldSV = oldView as? ScrollView,
               oldSV.layoutIdentity == nil,
               oldView === oldScrollView {
                continue
            }
            
            let shouldRemove: Bool
            if let identity = oldView.layoutIdentity {
                // View has identity: remove if identity not in new layout
                shouldRemove = !newIdentityMap.keys.contains(identity)
            } else {
                // View has no identity: remove if instance not in new layout
                shouldRemove = !newInstanceSet.contains(ObjectIdentifier(oldView))
            }
            
            if shouldRemove && oldView.superview == self {
                oldView.removeFromSuperview()
            }
        }
        
        // Step 2: Handle views with matching identities (view reuse)
        let matchingIdentities = Set(oldIdentityMap.keys).intersection(Set(newIdentityMap.keys))
        for identity in matchingIdentities {
            if let oldView = oldIdentityMap[identity], let newView = newIdentityMap[identity] {
                if oldView !== newView {
                    // Different instances with same identity: replace the view
                    if oldView.superview == self {
                        oldView.removeFromSuperview()
                    }
                    // Add new view if not already in hierarchy
                    if newView.superview == nil {
                        addSubview(newView)
                    }
                }
                // Same instance: already in hierarchy, no action needed
            }
        }
        
        // Step 3: Add new views (with identity but not matched, or without identity)
        for newView in newTopLevelViews {
            if newView.superview == nil {
                // Skip adding new ScrollView if we're reusing the old one
                if skipAddingNewScrollView,
                   let newSV = newView as? ScrollView,
                   newSV.layoutIdentity == nil {
                    // Skip adding this new ScrollView - we're reusing the old one
                    continue
                }
                
                // Check if this view should be added
                let shouldAdd: Bool
                if let identity = newView.layoutIdentity {
                    // View has identity: add if identity not in old layout (new view)
                    shouldAdd = !oldIdentityMap.keys.contains(identity)
                } else {
                    // View has no identity: add if instance not in old layout (new view)
                    shouldAdd = !oldInstanceSet.contains(ObjectIdentifier(newView))
                }
                
                if shouldAdd {
                    addSubview(newView)
                }
            }
        }
    }
    
    /// Apply layout to views (only updates frames, doesn't modify hierarchy)
    private func applyLayout() {
        guard let layout = cachedLayout else { return }
        
        // Always use cachedLayout for calculation to ensure consistency
        // LayoutNode is used for dirty tracking, but we calculate using cachedLayout
        // to avoid mismatches when layout instances change but structure doesn't
        let result: LayoutResult
        if useIncrementalLayout, let node = rootNode {
            // Use cachedLayout for calculation (not node.layout)
            // This ensures we're calculating with the current layout instance
            // Node tree is used for dirty tracking and incremental optimization
            result = layout.calculateLayout(in: bounds)
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
            
            // IMPORTANT: Skip all views that are inside ScrollView (except ScrollView itself)
            // ScrollView manages its own internal views through layoutSubviews and updateContentLayout
            // Applying frames here would conflict with ScrollView's internal layout
            // ScrollView structure: ScrollView (UIScrollView) -> contentView -> actual content views
            // We should only apply frames to ScrollView itself, not any of its content views
            if !(view is ScrollView) {
                // Check if view is inside any ScrollView by traversing up the hierarchy
                var currentParent: UIView? = view.superview
                var foundScrollView = false
                while let parent = currentParent {
                    if parent is ScrollView {
                        // View is inside ScrollView's hierarchy, skip it completely
                        // ScrollView will handle its own internal layout through layoutSubviews
                        foundScrollView = true
                        break
                    }
                    currentParent = parent.superview
                }
                
                if foundScrollView {
                    continue
                }
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
            
            if isScrollView && view is ScrollView {
                // For ScrollView itself, use the frame directly without centering
                // ScrollView's internal views are managed by ScrollView itself
                view.frame = frame
                // Trigger ScrollView's layoutSubviews to update its internal content
                view.setNeedsLayout()
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
    
    /// Check if the layout is a Stack type (VStack, HStack, ZStack) or ScrollView
    /// ScrollView is treated as a Stack-like container that shouldn't be wrapped in VStack
    private func isStackLayout(_ layout: any Layout) -> Bool {
        // Direct type check for ScrollView
        if layout is ScrollView {
            return true
        }
        let views = layout.extractViews()
        return views.contains { $0 is VStack || $0 is HStack || $0 is ZStack || $0 is ScrollView }
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
            // After updating hierarchy, apply layout to ensure views are positioned correctly
            applyLayout()
            // Update lastBounds to prevent unnecessary layout updates
            lastBounds = bounds
            return
        }
        
        // Rebuild layout tree if needed (e.g., after toggling incremental layout)
        // This happens without touching the view hierarchy
        if useIncrementalLayout && rootNode == nil, let layout = cachedLayout {
            rootNode = LayoutNode(layout: layout)
            rootNode?.buildTree()
            // Mark as dirty since layout state has changed
            rootNode?.markDirty()
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
    /// This marks only the target node as dirty without propagating to parent,
    /// allowing for partial updates where only the changed view is recalculated
    public func markViewDirty(_ view: UIView) {
        guard useIncrementalLayout, let node = rootNode else {
            // Fallback: invalidate entire layout
            setNeedsLayout()
            return
        }
        
        // Find the node containing this view
        if let targetNode = node.findNode(containing: view) {
            // Mark dirty and propagate to parent
            // Note: Parent propagation is necessary because if a child changes,
            // the parent layout (e.g., VStack) also needs to recalculate its layout
            // to account for the child's new size/position
            targetNode.markDirty(propagateToParent: true)
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

