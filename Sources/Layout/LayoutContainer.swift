import UIKit

/// A SwiftUI-style container view that automatically manages view hierarchy and centers content.
///
/// ``LayoutContainer`` provides a SwiftUI-like experience with automatic content centering
/// and declarative layout definitions. It automatically adds and removes views based on
/// the current layout definition, just like SwiftUI's body.
///
/// ## Features
///
/// - **Automatic Centering** - Content is automatically centered like SwiftUI
/// - **Automatic View Management** - Views are added/removed automatically
/// - **Conditional Layout Support** - Dynamic content handling
/// - **High-performance Frame-based Layout** - No Auto Layout constraints
/// - **SwiftUI-style API** - Familiar declarative syntax
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
        debugLog("updateViewHierarchy", component: "LayoutContainer", category: .hierarchy)
        
        // Remove all existing subviews
        subviews.forEach { $0.removeFromSuperview() }
        
        guard let body = body else {
            debugLog("no body set", component: "LayoutContainer", category: .hierarchy)
            return
        }
        
        let result = body.calculateLayout(in: bounds)
        let topLevelViews = body.extractViews()
        
        
        // Calculate center offset based on totalSize
        let centerX = (bounds.width - result.totalSize.width) / 2
        let centerY = (bounds.height - result.totalSize.height) / 2
        
        
        for view in topLevelViews {
            addSubview(view)
            
            if let frame = result.frames[view] {
                // Use result.totalSize for the top-level view's frame to ensure proper centering
                let adjustedFrame = CGRect(
                    x: frame.origin.x + centerX,
                    y: frame.origin.y + centerY,
                    width: result.totalSize.width,
                    height: result.totalSize.height
                )
                view.frame = adjustedFrame
                
            }
        }
        
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        
        // Call updateViewHierarchy
        updateViewHierarchy()
    }
}

