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
    private var rootNode: LayoutNode?
    
    public var useIncrementalLayout: Bool = true
    
    // MARK: - Public API
    
    public var body: (any Layout)? {
        get { _body?() }
        set { _body = { newValue! } }
    }
    
    public func setBody(@LayoutBuilder _ content: @escaping () -> any Layout) {
        _body = content
        needsHierarchyUpdate = true
        
        if LayoutInvalidationRules.default.shouldInvalidate(for: .hierarchyChanged) {
            setNeedsLayout()
        }
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
        _body = content
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
        let (oldTopLevelViews, structureChanged) = checkLayoutStructureChange(
            oldLayout: oldLayout,
            newTopLevelViews: newTopLevelViews
        )
        
        cachedLayout = layout
        updateLayoutTree(layout: layout, structureChanged: structureChanged)
        performLayoutDiff(
            oldTopLevelViews: oldTopLevelViews,
            newTopLevelViews: newTopLevelViews,
            oldLayout: oldLayout,
            newLayout: layout
        )
    }
    
    private func clearHierarchy() {
        subviews.forEach { $0.removeFromSuperview() }
        identityToViewMap.removeAll()
        cachedLayout = nil
        rootNode = nil
    }
    
    private func updateLayoutTree(layout: any Layout, structureChanged: Bool) {
        guard useIncrementalLayout else { return }
        
        if rootNode == nil {
            rootNode = LayoutNode(layout: layout)
            rootNode?.buildTree()
            rootNode?.markDirty()
        } else if structureChanged {
            rootNode = LayoutNode(layout: layout)
            rootNode?.buildTree()
            rootNode?.markDirty()
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
        
        let diff = calculateViewDiff(
            oldViews: oldTopLevelViews,
            newViews: newTopLevelViews,
            oldIdentityMap: oldIdentityMap,
            newIdentityMap: newIdentityMap,
            oldInstanceSet: oldInstanceSet,
            newInstanceSet: newInstanceSet
        )
        
        applyViewChanges(diff: diff)
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
        newInstanceSet: Set<ObjectIdentifier>
    ) -> ViewDiff {
        var finalOrder: [UIView] = []
        var viewsToRemove: Set<UIView> = []
        var viewsToAdd: Set<UIView> = []
        
        for newView in newViews {
            finalOrder.append(newView)
            
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
            guard !viewsToRemove.contains(oldView) else { continue }
            
            let shouldRemove: Bool
            if let identity = oldView.layoutIdentity {
                shouldRemove = !newIdentityMap.keys.contains(identity)
            } else {
                shouldRemove = !newInstanceSet.contains(ObjectIdentifier(oldView))
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
        guard let layout = cachedLayout else { return }
        
        let result = layout.calculateLayout(in: bounds)
        let centerOffset = calculateCenterOffset(for: result.totalSize)
        
        applyFrames(
            from: result,
            centerOffset: centerOffset
        )
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
            guard shouldApplyFrame(to: view) else { continue }
            view.frame = frame.offsetBy(dx: centerOffset.x, dy: centerOffset.y)
        }
    }
    
    private func shouldApplyFrame(to view: UIView) -> Bool {
        let viewId = ObjectIdentifier(view)
        if animatingViews.contains(view) || animatingViewIdentifiers.contains(viewId) {
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
        
        if useIncrementalLayout && rootNode == nil, let layout = cachedLayout {
            rootNode = LayoutNode(layout: layout)
            rootNode?.buildTree()
            rootNode?.markDirty()
        }
        
        if !animatingViews.isEmpty {
            return
        }
        
        let boundsChanged = lastBounds != bounds
        let layoutDirty = useIncrementalLayout ? (rootNode?.isDirty ?? true) : true
        
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
            setNeedsLayout()
            return
        }
        
        // Find the node containing this view
        if let targetNode = node.findNode(containing: view) {
            targetNode.markDirty(propagateToParent: true)
            setNeedsLayout()
        } else {
            node.invalidate()
            setNeedsLayout()
        }
    }
    
    public func invalidateLayoutTree() {
        guard let node = rootNode else { return }
        node.invalidate()
        setNeedsLayout()
    }
    
    public func rebuildLayoutTree() {
        rootNode = nil
        setNeedsLayout()
    }
}
