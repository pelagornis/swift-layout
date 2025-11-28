import Foundation

/// Configuration for view transitions
public struct TransitionConfig: Sendable {
    public let insertion: LayoutTransition
    public let removal: LayoutTransition
    public let animation: LayoutAnimation
    
    public static let opacity = TransitionConfig(
        insertion: .opacity,
        removal: .opacity,
        animation: .default
    )
    
    public static let scale = TransitionConfig(
        insertion: .scale,
        removal: .scale,
        animation: .spring
    )
    
    public static func slide(edge: LayoutTransition.Edge) -> TransitionConfig {
        return TransitionConfig(
            insertion: .slide(edge: edge),
            removal: .slide(edge: edge),
            animation: .default
        )
    }
    
    public init(
        insertion: LayoutTransition,
        removal: LayoutTransition,
        animation: LayoutAnimation
    ) {
        self.insertion = insertion
        self.removal = removal
        self.animation = animation
    }
}

