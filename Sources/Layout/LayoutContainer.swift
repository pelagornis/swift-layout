import UIKit

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
    /// Private storage for the layout body closure
    private var _body: (() -> Layout)?
    
    /// Set of views currently managed by this container
    private var managedViews: Set<UIView> = []
    
    /// The current layout body
    public var body: Layout? {
        get { _body?() }
        set { _body = { newValue! } }
    }
    
    /// Sets the layout body and triggers automatic view hierarchy management.
    ///
    /// This method extracts all views from the new layout, compares them with
    /// currently managed views, and automatically adds/removes views as needed.
    ///
    /// - Parameter content: Layout builder closure defining the layout
    ///
    /// ## Important
    /// 
    /// Views are automatically added and removed from the view hierarchy.
    /// You don't need to manually call `addSubview` or `removeFromSuperview`.
    public func setBody(@LayoutBuilder _ content: @escaping () -> Layout) {
        _body = content
        updateViewHierarchy()
        setNeedsLayout()
    }
    
    /// Updates the view hierarchy based on the current layout body.
    ///
    /// This method:
    /// 1. Extracts all views from the current layout
    /// 2. Removes views that are no longer needed
    /// 3. Adds new views that aren't already in the hierarchy
    /// 4. Updates the managed views set
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
    
    /// Performs layout calculation and applies frames to managed views.
    ///
    /// This method is called automatically by UIKit when layout is needed.
    /// It calculates the layout using the current body and applies the
    /// resulting frames to all managed views.
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let layout = body else { return }
        
        let result = layout.calculateLayout(in: bounds)
        result.applying(to: self)
    }
}