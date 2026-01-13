#if canImport(UIKit)
import UIKit

#endif
/// Timing function for animations
public enum AnimationTimingFunction: Sendable {
    case linear
    case easeIn
    case easeOut
    case easeInOut
    case spring(damping: CGFloat, initialVelocity: CGFloat)
    case custom(controlPoint1: CGPoint, controlPoint2: CGPoint)
    
    /// Converts to UIKit animation options
    public var animationOptions: UIView.AnimationOptions {
        switch self {
        case .linear:
            return .curveLinear
        case .easeIn:
            return .curveEaseIn
        case .easeOut:
            return .curveEaseOut
        case .easeInOut:
            return .curveEaseInOut
        case .spring, .custom:
            return []
        }
    }
    
    /// Gets the timing function value at a given progress (0-1)
    public func value(at progress: CGFloat) -> CGFloat {
        switch self {
        case .linear:
            return progress
        case .easeIn:
            return progress * progress
        case .easeOut:
            return 1 - (1 - progress) * (1 - progress)
        case .easeInOut:
            return progress < 0.5
                ? 2 * progress * progress
                : 1 - pow(-2 * progress + 2, 2) / 2
        case .spring(let damping, _):
            let omega = 2 * CGFloat.pi / (1 - damping * 0.5)
            return 1 - exp(-damping * omega * progress) * cos(omega * progress)
        case .custom(let p1, let p2):
            return cubicBezier(t: progress, p1: p1, p2: p2)
        }
    }
    
    private func cubicBezier(t: CGFloat, p1: CGPoint, p2: CGPoint) -> CGFloat {
        let cx = 3 * p1.x
        let bx = 3 * (p2.x - p1.x) - cx
        _ = 1 - cx - bx
        
        let cy = 3 * p1.y
        let by = 3 * (p2.y - p1.y) - cy
        let ay = 1 - cy - by
        
        return ((ay * t + by) * t + cy) * t
    }
}

