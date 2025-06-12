#if canImport(UIKit)
import UIKit
#endif
/// A container view that automatically manages view hierarchy based on layout definitions.
///
/// ``LayoutContainer`` is the core component that bridges declarative layout definitions
/// with UIKit's view hierarchy management. It automatically adds and removes views
/// based on the current layout definition.
///
/// ## Features
///
/// - Automatic view hierarchy management
/// - Conditional layout support
/// - Dynamic content handling
/// - High-performance frame-based layout
///
/// ## Example Usage
///
/// ```swift
/// class MyViewController: UIViewController {
///     let layoutContainer = LayoutContainer()
///     
///     override func viewDidLoad() {
///         super.viewDidLoad()
///         view.addSubview(layoutContainer)
///         layoutContainer.frame = view.bounds
///         
///         layoutContainer.setBody {
///             Vertical(spacing: 16) {
///                 titleLabel.layout()
///                 actionButton.layout()
///             }
///         }
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
    
    public func setBody(@LayoutBuilder _ content: @escaping () -> any Layout) {
        _body = content
        updateViewHierarchy()
        setNeedsLayout()
    }
    
    private func updateViewHierarchy() {
        guard let layout = body else { return }
        
        // Extract all views from the layout
        let newViews = Set(layout.extractViews())
        
        // Remove views that are no longer needed
        let viewsToRemove = managedViews.subtracting(newViews)
        viewsToRemove.forEach { view in
            view.removeFromSuperview()
        }
        
        // Add new views that aren't already added
        let viewsToAdd = newViews.subtracting(managedViews)
        viewsToAdd.forEach { view in
            addSubview(view)
        }
        
        // Update managed views
        managedViews = newViews
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let layout = body else { return }
        
        let result = layout.calculateLayout(in: bounds)
        result.applying(to: self)
    }
}
