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
    // MARK: - Properties
    
    private var _body: (() -> any Layout)?
    private var cachedLayout: (any Layout)?
    private var lastBounds: CGRect = .zero
    private var needsHierarchyUpdate: Bool = false
    
    private var animatingViews: Set<UIView> = []
    private var animatingViewIdentifiers: Set<ObjectIdentifier> = []
    private var identityToViewMap: [AnyHashable: UIView] = [:]
    private var layoutNodeBuffer: LayoutNodeBuffer?
    private var rootNodeIndex: Int?
    
    /// Maps new ScrollView instances to reused old ScrollView instances
    /// Used when ScrollView instances without identity are reused
    private var containerViewMapping: [ObjectIdentifier: UIView] = [:]
    
    public var useIncrementalLayout: Bool = true
    
    /// Whether to use the new LayoutEngine architecture
    /// When enabled, uses LayoutEngine and LayoutRenderer instead of direct layout calculation
    public var useNewEngine: Bool = false
    
    /// New layout engine (only used when useNewEngine is true)
    private var layoutEngine: LayoutEngine?
    
    /// Layout renderer (only used when useNewEngine is true)
    private var layoutRenderer: LayoutRenderer?
    
    // MARK: - Public API
    
    public var body: (any Layout)? {
        get { _body?() }
        set { _body = { newValue! } }
    }
    
    /// Sets the body layout without immediately updating the view hierarchy.
    /// Call `updateBody()` separately to apply the changes.
    public func setBody(@LayoutBuilder _ content: @escaping () -> any Layout) {
        _body = content
    }
    
    /// Updates the view hierarchy based on the current body layout.
    /// This method performs the actual view diffing and hierarchy updates.
    public func updateBody() {
        guard body != nil else {
            return
        }
        
        needsHierarchyUpdate = true
        
        if LayoutInvalidationRules.default.shouldInvalidate(for: .hierarchyChanged) {
            setNeedsLayout()
        }
        
        // Force immediate layout update to ensure body is evaluated with latest state
        layoutIfNeeded()
    }
    
    /// Sets the body and immediately updates the view hierarchy.
    /// This is a convenience method that combines `setBody` and `updateBody`.
    public func updateBody(@LayoutBuilder _ content: @escaping () -> any Layout) {
        _body = content
        updateBody()
    }

    public func updateLayoutForOrientationChange() {
        needsHierarchyUpdate = true
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    public func startAnimating(_ view: UIView) {
        animatingViews.insert(view)
        animatingViewIdentifiers.insert(ObjectIdentifier(view))
    }
    
    public func stopAnimating(_ view: UIView) {
        animatingViews.remove(view)
        animatingViewIdentifiers.remove(ObjectIdentifier(view))
    }
    
    public var isAnimating: Bool {
        return !animatingViews.isEmpty
    }
    
    public func setBodyAnimated(animation: LayoutAnimation = .default, @LayoutBuilder _ content: @escaping () -> any Layout) {
        setBody(content)
        guard let newBody = body else { return }
        
        let layout = prepareLayout(newBody)
        let viewsChanged = hasViewsChanged(newViews: layout.extractViews(), currentViews: subviews)
        
        if viewsChanged || needsHierarchyUpdate {
            needsHierarchyUpdate = false
            updateViewHierarchy()
            applyLayout()
            return
        }
        
        cachedLayout = layout
        applyLayoutAnimated(animation: animation)
    }
    
    // MARK: - View Hierarchy Management
    
    private func prepareLayout(_ layout: any Layout) -> any Layout {
        return isStackLayout(layout) ? layout : createAutoVStack(from: layout)
    }
    
    private func hasViewsChanged(newViews: [UIView], currentViews: [UIView]) -> Bool {
        return newViews.count != currentViews.count || 
               !newViews.elementsEqual(currentViews, by: { $0 === $1 })
    }
    
    private func updateViewHierarchy() {
        guard let body = body else {
            clearHierarchy()
            return
        }
        
        let layout = prepareLayout(body)
        let newTopLevelViews = layout.extractViews()
        let oldLayout = cachedLayout
        let (oldTopLevelViewsForDiff, structureChanged) = checkLayoutStructureChange(
            oldLayout: oldLayout,
            newTopLevelViews: newTopLevelViews
        )
        
        cachedLayout = layout
        updateLayoutTree(layout: layout, structureChanged: structureChanged)
        performLayoutDiff(
            oldTopLevelViews: oldTopLevelViewsForDiff,
            newTopLevelViews: newTopLevelViews,
            oldLayout: oldLayout,
            newLayout: layout
        )
    }
    
    private func clearHierarchy() {
        subviews.forEach { $0.removeFromSuperview() }
        identityToViewMap.removeAll()
        containerViewMapping.removeAll()
        cachedLayout = nil
        layoutNodeBuffer = nil
        rootNodeIndex = nil
    }
    
    private func updateLayoutTree(layout: any Layout, structureChanged: Bool) {
        guard useIncrementalLayout else { return }
        
        if layoutNodeBuffer == nil {
            layoutNodeBuffer = LayoutNodeBuffer()
            rootNodeIndex = layoutNodeBuffer?.addNode(layout: layout)
            if let rootIndex = rootNodeIndex {
                layoutNodeBuffer?.buildTree(rootIndex: rootIndex)
                layoutNodeBuffer?.markDirty(at: rootIndex)
            }
        } else if structureChanged {
            layoutNodeBuffer?.clear()
            rootNodeIndex = layoutNodeBuffer?.addNode(layout: layout)
            if let rootIndex = rootNodeIndex {
                layoutNodeBuffer?.buildTree(rootIndex: rootIndex)
                layoutNodeBuffer?.markDirty(at: rootIndex)
            }
        }
    }
    
    // MARK: - View Diffing
    
    private func performLayoutDiff(
        oldTopLevelViews: [UIView],
        newTopLevelViews: [UIView],
        oldLayout: (any Layout)?,
        newLayout: any Layout
    ) {
        guard !oldTopLevelViews.isEmpty || !newTopLevelViews.isEmpty else {
            identityToViewMap.removeAll()
            return
        }
        
        let (oldIdentityMap, oldInstanceSet) = buildIdentityMaps(from: oldTopLevelViews)
        let (newIdentityMap, newInstanceSet) = buildIdentityMaps(from: newTopLevelViews)
        identityToViewMap = newIdentityMap
        
        // Handle ScrollView instances without identity that should be reused
        // Find ScrollViews without identity that should be reused
        var scrollViewsToUpdate: [(oldScrollView: ScrollView, newLayout: any Layout)] = []
        var skipAddingContainers: Set<UIView> = []
        
        // Only process ScrollView matching if we have ScrollViews
        let hasOldScrollViews = oldTopLevelViews.contains { $0 is ScrollView }
        let hasNewScrollViews = newTopLevelViews.contains { $0 is ScrollView }
        
        if hasOldScrollViews || hasNewScrollViews {
            // Find old ScrollViews from actual hierarchy (not from oldLayout.extractViews())
            // This ensures we find ScrollViews that are actually in the view hierarchy
            var oldScrollViews: [(scrollView: ScrollView, view: UIView)] = []
            for subview in subviews {
                if let scrollView = subview as? ScrollView,
                   subview.layoutIdentity == nil {
                    oldScrollViews.append((scrollView: scrollView, view: subview))
                }
            }
            
            // Find new ScrollViews
            var newScrollViews: [(scrollView: ScrollView, view: UIView)] = []
            for newView in newTopLevelViews {
                if let scrollView = newView as? ScrollView,
                   newView.layoutIdentity == nil {
                    newScrollViews.append((scrollView: scrollView, view: newView))
                }
            }
            
            // Match old and new ScrollViews by type (for ScrollViews without identity)
            // Reuse old ScrollView instances to preserve state (scroll offset, cache, etc.)
            for (oldScrollView, oldView) in oldScrollViews {
                if let (newScrollView, newView) = newScrollViews.first(where: { 
                    $0.view !== oldView 
                }) {
                    if let newChildLayout = newScrollView.getChildLayout() {
                        scrollViewsToUpdate.append((oldScrollView: oldScrollView, newLayout: newChildLayout))
                        skipAddingContainers.insert(newView)
                        // IMPORTANT: Also mark oldView to prevent removal
                        skipAddingContainers.insert(oldView)
                        // Map newView to oldView so applyFrames can find the correct instance
                        containerViewMapping[ObjectIdentifier(newView)] = oldView
                    }
                }
            }
        }
        
        let diff = calculateViewDiff(
            oldViews: oldTopLevelViews,
            newViews: newTopLevelViews,
            oldIdentityMap: oldIdentityMap,
            newIdentityMap: newIdentityMap,
            oldInstanceSet: oldInstanceSet,
            newInstanceSet: newInstanceSet,
            skipAddingContainers: skipAddingContainers
        )
        
        applyViewChanges(diff: diff)
        
        // Update ScrollViews after view hierarchy changes
        for (oldScrollView, newChildLayout) in scrollViewsToUpdate {
            oldScrollView.updateChildLayout(newChildLayout)
        }
    }
    
    private func buildIdentityMaps(from views: [UIView]) -> ([AnyHashable: UIView], Set<ObjectIdentifier>) {
        var identityMap: [AnyHashable: UIView] = [:]
        var instanceSet = Set<ObjectIdentifier>()
        
        for view in views {
            if let identity = view.layoutIdentity {
                identityMap[identity] = view
            } else {
                instanceSet.insert(ObjectIdentifier(view))
            }
        }
        
        return (identityMap, instanceSet)
    }
    
    private struct ViewDiff {
        let finalOrder: [UIView]
        let viewsToRemove: Set<UIView>
        let viewsToAdd: Set<UIView>
    }
    
    private func calculateViewDiff(
        oldViews: [UIView],
        newViews: [UIView],
        oldIdentityMap: [AnyHashable: UIView],
        newIdentityMap: [AnyHashable: UIView],
        oldInstanceSet: Set<ObjectIdentifier>,
        newInstanceSet: Set<ObjectIdentifier>,
        skipAddingContainers: Set<UIView> = []
    ) -> ViewDiff {
        var finalOrder: [UIView] = []
        var viewsToRemove: Set<UIView> = []
        var viewsToAdd: Set<UIView> = []
        
        for newView in newViews {
            finalOrder.append(newView)
            
            // Skip adding containers that are being reused (but still add to finalOrder)
            if skipAddingContainers.contains(newView) {
                continue
            }
            
            if newView.superview == nil {
                viewsToAdd.insert(newView)
            }
            
            if let identity = newView.layoutIdentity,
               let oldView = oldIdentityMap[identity],
               oldView !== newView {
                viewsToRemove.insert(oldView)
            }
        }
        
        for oldView in oldViews {
            guard !viewsToRemove.contains(oldView) else { 
                continue 
            }
            
            // Don't remove old containers that are being reused
            let oldViewId = ObjectIdentifier(oldView)
            if skipAddingContainers.contains(oldView) {
                continue
            }
            
            let shouldRemove: Bool
            if let identity = oldView.layoutIdentity {
                shouldRemove = !newIdentityMap.keys.contains(identity)
            } else {
                shouldRemove = !newInstanceSet.contains(oldViewId)
            }
            
            if shouldRemove && oldView.superview == self {
                viewsToRemove.insert(oldView)
            }
        }
        
        return ViewDiff(finalOrder: finalOrder, viewsToRemove: viewsToRemove, viewsToAdd: viewsToAdd)
    }
    
    private func applyViewChanges(diff: ViewDiff) {
        diff.viewsToRemove.forEach { view in
            if view.superview == self {
                view.removeFromSuperview()
            }
        }
        
        diff.viewsToAdd.forEach { view in
            if view.superview == nil {
                addSubview(view)
            }
        }
        
        reorderViews(to: diff.finalOrder)
    }
    
    private func reorderViews(to finalOrder: [UIView]) {
        let viewsInHierarchy = finalOrder.filter { $0.superview == self }
        guard !viewsInHierarchy.isEmpty else { return }
        
        let currentOrder = subviews.filter { viewsInHierarchy.contains($0) }
        guard !currentOrder.elementsEqual(viewsInHierarchy, by: { $0 === $1 }) else { return }
        
        viewsInHierarchy.forEach { view in
            if subviews.contains(view) {
            view.removeFromSuperview()
            }
        }
        
        viewsInHierarchy.enumerated().forEach { index, view in
            insertSubview(view, at: index)
        }
    }
    
    private func checkLayoutStructureChange(oldLayout: (any Layout)?, newTopLevelViews: [UIView]) -> ([UIView], Bool) {
        guard let oldLayout = oldLayout else {
            return ([], true)
        }
        
        let oldTopLevelViews = oldLayout.extractViews()
        let oldIdentities = Set(oldTopLevelViews.compactMap { $0.layoutIdentity })
        let newIdentities = Set(newTopLevelViews.compactMap { $0.layoutIdentity })
        
        let structureChanged = oldIdentities != newIdentities || oldTopLevelViews.count != newTopLevelViews.count
        return (oldTopLevelViews, structureChanged)
    }
    
    // MARK: - Layout Application
    
    private func applyLayout() {
        guard let layout = cachedLayout else { 
            return 
        }
        
        // Use new engine if enabled
        if useNewEngine {
            applyLayoutWithNewEngine()
            return
        }
        
        // Use LayoutNodeBuffer for incremental layout if enabled
        let result: LayoutResult
        if useIncrementalLayout, let buffer = layoutNodeBuffer, let rootIndex = rootNodeIndex {
            result = buffer.calculateLayout(at: rootIndex, in: bounds)
        } else {
            // Legacy layout application
            result = layout.calculateLayout(in: bounds)
        }
        
        let centerOffset = calculateCenterOffset(for: result.totalSize)
        
        applyFrames(
            from: result,
            centerOffset: centerOffset
        )
    }
    
    /// Applies layout using the new LayoutEngine architecture
    private func applyLayoutWithNewEngine() {
        guard let layout = cachedLayout else { return }
        
        // Initialize engine and renderer if needed
        if layoutEngine == nil {
            layoutRenderer = LayoutRenderer()
        }
        
        // Convert Layout to LayoutElement
        let rootElement = LayoutAdapter.toElement(
            layout,
            environment: EnvironmentProvider.shared.rootEnvironment
        )
        
        // Create or update engine
        if let engine = layoutEngine {
            engine.updateRoot(rootElement)
        } else {
            layoutEngine = LayoutEngine(root: rootElement)
        }
        
        // Set transaction if animating
        if let transaction = LayoutAnimationTransaction.current {
            layoutEngine?.setTransaction(transaction)
        }
        
        // Perform layout
        let placement = layoutEngine?.performLayout(in: bounds) ?? PlacementResult.empty
        
        // Build element registry for view lookup
        var elementRegistry: [LayoutID: LayoutElement] = [:]
        func buildRegistry(from element: LayoutElement) {
            elementRegistry[element.id] = element
            for child in element.children {
                buildRegistry(from: child)
            }
        }
        buildRegistry(from: rootElement)
        
        // Apply placement using renderer
        layoutRenderer?.apply(
            placement: placement,
            elements: elementRegistry,
            transaction: LayoutAnimationTransaction.current
        )
        
        // Apply center offset
        let centerOffset = calculateCenterOffset(for: placement.totalSize)
        for (id, frame) in placement.frames {
            guard let element = elementRegistry[id],
                  let view = element.view else {
                continue
            }
            view.frame = frame.offsetBy(dx: centerOffset.x, dy: centerOffset.y)
        }
    }
    
    private func calculateCenterOffset(for contentSize: CGSize) -> CGPoint {
        return CGPoint(
            x: max(0, (bounds.width - contentSize.width) / 2),
            y: max(0, (bounds.height - contentSize.height) / 2)
        )
    }
    
    private func applyFrames(
        from result: LayoutResult,
        centerOffset: CGPoint
    ) {
        for (view, frame) in result.frames {
            // Check if this view is a new container instance that should be mapped to an old instance
            let viewId = ObjectIdentifier(view)
            let actualView: UIView
            if let mappedView = containerViewMapping[viewId] {
                actualView = mappedView
            } else {
                actualView = view
            }
            
            if shouldApplyFrame(to: actualView) {
                let finalFrame = frame.offsetBy(dx: centerOffset.x, dy: centerOffset.y)
                actualView.frame = finalFrame
                
                // If this is a ScrollView, trigger its internal layout update
                // This ensures contentView and child views are laid out correctly
                if actualView is ScrollView {
                    actualView.setNeedsLayout()
                }
            }
        }
        
        // Clear mapping after use
        containerViewMapping.removeAll()
    }
    
    private func shouldApplyFrame(to view: UIView) -> Bool {
        let viewId = ObjectIdentifier(view)
        if animatingViews.contains(view) || animatingViewIdentifiers.contains(viewId) {
            return false
        }
        
        // Always apply frame to ScrollView itself
        // Only skip views that are INSIDE ScrollView's internal hierarchy
        if view is ScrollView {
            return view.superview != nil
        }
        
        // Skip views that are inside ScrollView's internal hierarchy
        // ScrollView manages its own internal views (e.g., contentView)
        // We only skip views that are direct children of ScrollView's internal structure
        // Check if view's superview is a ScrollView (not the ScrollView itself)
        if let superview = view.superview,
           superview is ScrollView,
           view !== superview {
            // This view is inside ScrollView's internal hierarchy, skip it
            // ScrollView will manage this view's frame internally
            return false
        }
        
        return view.superview != nil
    }
    
    // MARK: - Animation
    
    private func applyLayoutAnimated(animation: LayoutAnimation) {
        guard let layout = cachedLayout else { return }
        
        let result = layout.calculateLayout(in: bounds)
        let topLevelViews = layout.extractViews()
        let centerOffset = calculateCenterOffset(for: result.totalSize)
        
        animateFrames(
            for: topLevelViews,
            from: result,
            centerOffset: centerOffset,
            animation: animation
        )
    }
    
    private func animateFrames(
        for views: [UIView],
        from result: LayoutResult,
        centerOffset: CGPoint,
        animation: LayoutAnimation
    ) {
        let animations = {
            for view in views {
                guard let frame = result.frames[view] else { continue }
                guard self.shouldApplyFrame(to: view) else { continue }
                    view.frame = frame.offsetBy(dx: centerOffset.x, dy: centerOffset.y)
            }
        }
        
        let baseOptions: UIView.AnimationOptions = [.beginFromCurrentState, .allowUserInteraction]
        
        switch animation.timingFunction {
        case .spring(let damping, let velocity):
            UIView.animate(
                withDuration: animation.duration,
                delay: animation.delay,
                usingSpringWithDamping: damping,
                initialSpringVelocity: velocity,
                options: baseOptions,
                animations: animations
            )
        default:
            let options = animation.timingFunction.animationOptions.union(baseOptions)
            UIView.animate(
                withDuration: animation.duration,
                delay: animation.delay,
                options: options,
                animations: animations
            )
        }
    }
    
    // MARK: - Layout Helpers
    
    private func isStackLayout(_ layout: any Layout) -> Bool {
        if layout is ScrollView {
            return true
        }
        let views = layout.extractViews()
        return views.contains { $0 is VStack || $0 is HStack || $0 is ZStack || $0 is ScrollView }
    }
    
    private func createAutoVStack(from layout: any Layout) -> VStack {
        if let tupleLayout = layout as? TupleLayout {
            return VStack(spacing: 20) {
                for childLayout in tupleLayout.layouts {
                    let views = childLayout.extractViews()
                    for view in views {
                        view.layout()
                    }
                }
            }
        } else {
            return VStack(alignment: .center, spacing: 20) {
                let views = layout.extractViews()
                for view in views {
                    view.layout()
                }
            }
        }
    }
    
    // MARK: - Layout Updates
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard bounds.width > 0 && bounds.height > 0 else { return }
        
        if needsHierarchyUpdate {
            needsHierarchyUpdate = false
            updateViewHierarchy()
            applyLayout()
            lastBounds = bounds
            return
        }
        
        if useIncrementalLayout && layoutNodeBuffer == nil, let layout = cachedLayout {
            layoutNodeBuffer = LayoutNodeBuffer()
            rootNodeIndex = layoutNodeBuffer?.addNode(layout: layout)
            if let rootIndex = rootNodeIndex {
                layoutNodeBuffer?.buildTree(rootIndex: rootIndex)
                layoutNodeBuffer?.markDirty(at: rootIndex)
            }
        }
        
        if !animatingViews.isEmpty {
            return
        }
        
        let boundsChanged = lastBounds != bounds
        let layoutDirty: Bool
        if useIncrementalLayout, let buffer = layoutNodeBuffer, let rootIndex = rootNodeIndex {
            if let node = buffer.getNode(at: rootIndex) {
                layoutDirty = node.isDirty
            } else {
                layoutDirty = true
            }
        } else {
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
        guard useIncrementalLayout, let buffer = layoutNodeBuffer, let rootIndex = rootNodeIndex else {
            setNeedsLayout()
            return
        }
        
        // Find the node containing this view
        if let targetIndex = buffer.findNode(containing: view, startingAt: rootIndex) {
            buffer.markDirty(at: targetIndex, propagateToParent: true)
            setNeedsLayout()
        } else {
            buffer.invalidate(at: rootIndex)
            setNeedsLayout()
        }
    }
    
    public func invalidateLayoutTree() {
        guard let buffer = layoutNodeBuffer, let rootIndex = rootNodeIndex else { return }
        buffer.invalidate(at: rootIndex)
        setNeedsLayout()
    }
    
    public func rebuildLayoutTree() {
        layoutNodeBuffer = nil
        rootNodeIndex = nil
        setNeedsLayout()
    }
}
