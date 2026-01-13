#if canImport(UIKit)
import UIKit

#endif
// MARK: - withAnimation Function

/// Executes the given closure with animation
///
/// Usage:
/// ```swift
/// withAnimation {
///     self.isExpanded = true
///     self.layoutContainer.setBody { self.body }
/// }
///
/// withAnimation(.spring()) {
///     self.offset = 100
/// }
/// ```
@MainActor
public func withAnimation(_ animation: LayoutAnimation = .default, _ body: @escaping () -> Void) {
    switch animation.timingFunction {
    case .spring(let damping, let velocity):
        UIView.animate(
            withDuration: animation.duration,
            delay: animation.delay,
            usingSpringWithDamping: damping,
            initialSpringVelocity: velocity,
            options: [.beginFromCurrentState, .allowUserInteraction],
            animations: body
        )
    default:
        UIView.animate(
            withDuration: animation.duration,
            delay: animation.delay,
            options: [animation.timingFunction.animationOptions, .beginFromCurrentState, .allowUserInteraction],
            animations: body
        )
    }
}

/// Executes the given closure with animation and completion handler
@MainActor
public func withAnimation(
    _ animation: LayoutAnimation = .default,
    _ body: @escaping () -> Void,
    completion: @escaping (Bool) -> Void
) {
    switch animation.timingFunction {
    case .spring(let damping, let velocity):
        UIView.animate(
            withDuration: animation.duration,
            delay: animation.delay,
            usingSpringWithDamping: damping,
            initialSpringVelocity: velocity,
            options: [.beginFromCurrentState, .allowUserInteraction],
            animations: body,
            completion: completion
        )
    default:
        UIView.animate(
            withDuration: animation.duration,
            delay: animation.delay,
            options: [animation.timingFunction.animationOptions, .beginFromCurrentState, .allowUserInteraction],
            animations: body,
            completion: completion
        )
    }
}

