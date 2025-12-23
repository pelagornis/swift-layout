import UIKit

/// Extension to integrate Layout system with UIKit lifecycle
/// This provides minimal integration without requiring a base class
public extension UIViewController {
    /// Sets up layout container using pure Manual Layout (no Auto Layout)
    /// Call this in viewDidLoad to enable automatic layout updates
    /// - Parameter container: The LayoutContainer to manage
    func setupLayoutContainer(_ container: LayoutContainer) {
        view.addSubview(container)
        // Use autoresizing mask for pure Manual Layout (no Auto Layout constraints)
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.frame = view.bounds
    }
    
    /// Updates layout container frame when view bounds change
    /// Call this in viewDidLayoutSubviews for pure Manual Layout
    /// - Parameter container: The LayoutContainer to update
    func updateLayoutContainer(_ container: LayoutContainer) {
        container.frame = view.bounds
    }
}

