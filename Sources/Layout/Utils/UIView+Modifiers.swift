import UIKit
import ObjectiveC

/// Stores layout modifiers on UIView using associated objects
/// This prevents creating new ViewLayout instances for each modifier chain
private struct AssociatedKeys {
    @MainActor static var layoutModifiers = "layoutmodifiers"
}

@MainActor
extension UIView {
    /// Gets or sets layout modifiers for this view
    /// Modifiers are stored as properties, not as new nodes
    @MainActor
    var layoutModifiers: [LayoutModifier] {
        get {
            if let modifiers = objc_getAssociatedObject(self, &AssociatedKeys.layoutModifiers) as? [LayoutModifier] {
                return modifiers
            }
            return []
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.layoutModifiers, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// Adds a layout modifier to this view
    func addLayoutModifier(_ modifier: LayoutModifier) {
        var modifiers = layoutModifiers
        modifiers.append(modifier)
        layoutModifiers = modifiers
    }
    
    /// Clears all layout modifiers
    func clearLayoutModifiers() {
        layoutModifiers = []
    }
}
