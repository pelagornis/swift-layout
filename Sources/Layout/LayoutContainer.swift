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
        
        let result = body.calculateLayout(in: bounds)
        let topLevelViews = body.extractViews()
        
        // Check if the body is a ScrollView or contains ScrollView
        let isScrollView = body is ScrollView || topLevelViews.contains { $0 is ScrollView }
        
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()    
        if bounds.width > 0 && bounds.height > 0 {
            updateViewHierarchy()
        }
    }
}

