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
    
    public var body: (any Layout)? {
        get { _body?() }
        set { _body = { newValue! } }
    }
    
    /// Sets the body with SwiftUI-style automatic centering
    public func setBody(@LayoutBuilder _ content: @escaping () -> any Layout) {
        _body = content
        needsHierarchyUpdate = true
        setNeedsLayout()
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
        // Remove all existing subviews
        subviews.forEach { $0.removeFromSuperview() }
        cachedLayout = nil
        
        guard let body = body else {
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
        
        cachedLayout = layout
        
        // Add views to hierarchy (without setting frames yet)
        let topLevelViews = layout.extractViews()
        for view in topLevelViews {
            addSubview(view)
        }
    }
    
    /// Apply layout to views (only updates frames, doesn't modify hierarchy)
    private func applyLayout() {
        guard let layout = cachedLayout else { return }
        
        let result = layout.calculateLayout(in: bounds)
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
        
        // Skip layout updates if any views are currently animating
        // This prevents layout from overriding animations
        if !animatingViews.isEmpty {
            return
        }
        
        // Only update frames if bounds changed
        if lastBounds != bounds {
            lastBounds = bounds
            applyLayout()
        }
    }
}

