#if canImport(UIKit)
import UIKit
#endif
/// Protocol for modifiers that can transform view frames during layout calculation.
///
/// Layout modifiers are applied in sequence to transform a view's frame
/// based on the available bounds and other layout parameters.
public protocol LayoutModifier {
    /// Applies the modifier transformation to a frame within the given bounds.
    ///
    /// - Parameters:
    ///   - frame: The original frame to modify
    ///   - bounds: The available bounds for the layout
    /// - Returns: The modified frame
    func apply(to frame: CGRect, in bounds: CGRect) -> CGRect
}
