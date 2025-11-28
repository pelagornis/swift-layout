import Foundation

/// Configuration for layout animations
public struct LayoutAnimation: Sendable {
    public let duration: TimeInterval
    public let delay: TimeInterval
    public let timingFunction: AnimationTimingFunction
    public let repeatCount: Int
    public let autoreverses: Bool
    
    public static let `default` = LayoutAnimation(
        duration: 0.3,
        delay: 0,
        timingFunction: .easeInOut,
        repeatCount: 1,
        autoreverses: false
    )
    
    public static let spring = LayoutAnimation(
        duration: 0.5,
        delay: 0,
        timingFunction: .spring(damping: 0.7, initialVelocity: 0),
        repeatCount: 1,
        autoreverses: false
    )
    
    public static let quick = LayoutAnimation(
        duration: 0.15,
        delay: 0,
        timingFunction: .easeOut,
        repeatCount: 1,
        autoreverses: false
    )
    
    public init(
        duration: TimeInterval = 0.3,
        delay: TimeInterval = 0,
        timingFunction: AnimationTimingFunction = .easeInOut,
        repeatCount: Int = 1,
        autoreverses: Bool = false
    ) {
        self.duration = duration
        self.delay = delay
        self.timingFunction = timingFunction
        self.repeatCount = repeatCount
        self.autoreverses = autoreverses
    }
    
    /// Creates a custom animation
    public static func custom(
        duration: TimeInterval,
        timingFunction: AnimationTimingFunction = .easeInOut
    ) -> LayoutAnimation {
        return LayoutAnimation(
            duration: duration,
            timingFunction: timingFunction
        )
    }
}

