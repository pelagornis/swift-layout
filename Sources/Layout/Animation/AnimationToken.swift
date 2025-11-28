import Foundation

/// Token for canceling animations
@MainActor
public struct AnimationToken {
    let id: UUID
    weak var engine: LayoutAnimationEngine?
    
    /// Cancels the animation
    public func cancel() {
        engine?.cancelAnimation(self)
    }
}

