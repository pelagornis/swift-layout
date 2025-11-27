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
    
    public var body: (any Layout)? {
        get { _body?() }
        set { _body = { newValue! } }
    }
    
    /// Sets the body with SwiftUI-style automatic centering
    public func setBody(@LayoutBuilder _ content: @escaping () -> any Layout) {
        _body = content
        updateViewHierarchy()
    }
    
    /// Updates layout for orientation changes
    public func updateLayoutForOrientationChange() {
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func updateViewHierarchy() {
        // Remove all existing subviews
        subviews.forEach { $0.removeFromSuperview() }
        
        guard let body = body else {
            return
        }
        
        // Like SwiftUI, automatically wrap in VStack if not using Stack
        if isStackLayout(body) {
            // If already Stack, use existing approach
            applyLayout(body)
        } else {
            // If not Stack, wrap in VStack
            let autoVStack = createAutoVStack(from: body)
            applyLayout(autoVStack)
        }
    }
    
    /// Apply layout to views
    private func applyLayout(_ layout: any Layout) {
        let result = layout.calculateLayout(in: bounds)
        let topLevelViews = layout.extractViews()
        
        // Check if the body is a ScrollView or contains ScrollView
        let isScrollView = layout is ScrollView || topLevelViews.contains { $0 is ScrollView }
        
        for view in topLevelViews {
            addSubview(view)
            
            if let frame = result.frames[view] {
                if isScrollView {
                    // For ScrollView, use the frame directly without centering
                    view.frame = frame
                    
                    // Force layout update for ScrollView
                    view.setNeedsLayout()
                    view.layoutIfNeeded()
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
                if let button = view as? UIButton {
                    button.frame = view.frame
                    
                    button.setNeedsLayout()
                    button.layoutIfNeeded()
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
        if bounds.width > 0 && bounds.height > 0 {
            updateViewHierarchy()
        }
    }
}

