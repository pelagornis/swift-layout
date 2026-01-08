import UIKit
import ObjectiveC

/// Stores layout modifiers on UIView using associated objects
/// This prevents creating new ViewLayout instances for each modifier chain
private struct AssociatedKeys {
    @MainActor static var layoutModifiers = "layoutmodifiers"
    @MainActor static var layoutIdentity = "layoutidentity"
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
    
    /// Gets or sets layout identity for this view
    /// 
    /// Identity is used for efficient diffing and view reuse in SwiftUI-style.
    /// Uses UIKit's built-in `accessibilityIdentifier` property for storage.
    /// 
    /// Important:
    /// - Identity should be stable across layout updates for the same logical view
    /// - Setting identity to nil clears it (view will be tracked by instance instead)
    /// - Identity is part of the layout definition, not the view's permanent state
    var layoutIdentity: AnyHashable? {
        get {
            // Use UIKit's built-in accessibilityIdentifier property
            if let identifier = accessibilityIdentifier {
                return AnyHashable(identifier)
            }
            return nil
        }
        set {
            if let newValue = newValue {
                accessibilityIdentifier = String(describing: newValue)
            } else {
                accessibilityIdentifier = nil
            }
        }
    }
    
    /// Clears the layout identity for this view
    /// After clearing, the view will be tracked by instance instead of identity
    func clearLayoutIdentity() {
        layoutIdentity = nil
    }
}
