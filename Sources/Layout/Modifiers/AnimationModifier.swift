import CoreGraphics
/// A modifier that applies animation to layout changes.
///
/// ``AnimationModifier`` stores animation configuration to be applied
/// when the view's frame changes.
///
/// ## Example Usage
///
/// ```swift
/// myView.layout()
///     .size(width: 200, height: 100)
///     .animation(.spring)
/// ```
public struct AnimationModifier: LayoutModifier {
    public let animation: LayoutAnimation
    
    public init(animation: LayoutAnimation) {
        self.animation = animation
    }
    
    public func apply(to frame: CGRect, in bounds: CGRect) -> CGRect {
        return frame
    }
}

/// A modifier that applies transition effects when views appear/disappear.
///
/// ``TransitionModifier`` stores transition configuration for insertion
/// and removal animations.
///
/// ## Example Usage
///
/// ```swift
/// myView.layout()
///     .transition(.opacity)
///     .transition(.slide(edge: .bottom))
/// ```
public struct TransitionModifier: LayoutModifier {
    public let transition: LayoutTransition
    public let animation: LayoutAnimation
    
    public init(transition: LayoutTransition, animation: LayoutAnimation = .default) {
        self.transition = transition
        self.animation = animation
    }
    
    public func apply(to frame: CGRect, in bounds: CGRect) -> CGRect {
        return frame
    }
}

