import UIKit
import QuartzCore

/// State for a running animation
private struct AnimationState {
    let animation: LayoutAnimation
    let startTime: CFTimeInterval
    let updateBlock: (CGFloat) -> Void
}

/// Manages animations for layout changes
@MainActor
public final class LayoutAnimationEngine {
    /// Shared instance
    public static let shared = LayoutAnimationEngine()
    
    /// Currently running animations
    private var runningAnimations: [UUID: AnimationState] = [:]
    
    /// Animation completion handlers
    private var completionHandlers: [UUID: () -> Void] = [:]
    
    /// Display link for frame-based animations
    private var displayLink: CADisplayLink?
    
    /// Whether animations are enabled globally
    public var animationsEnabled: Bool = true
    
    private init() {
        setupDisplayLink()
    }
    
    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkFired))
        displayLink?.add(to: .main, forMode: .common)
        displayLink?.isPaused = true
    }
    
    @objc private func displayLinkFired(_ link: CADisplayLink) {
        updateAnimations(timestamp: link.timestamp)
    }
    
    private func updateAnimations(timestamp: CFTimeInterval) {
        var completedAnimations: [UUID] = []
        
        for (id, state) in runningAnimations {
            let elapsed = timestamp - state.startTime
            let progress = min(elapsed / state.animation.duration, 1.0)
            let easedProgress = state.animation.timingFunction.value(at: CGFloat(progress))
            
            state.updateBlock(easedProgress)
            
            if progress >= 1.0 {
                completedAnimations.append(id)
            }
        }
        
        for id in completedAnimations {
            runningAnimations.removeValue(forKey: id)
            completionHandlers[id]?()
            completionHandlers.removeValue(forKey: id)
        }
        
        if runningAnimations.isEmpty {
            displayLink?.isPaused = true
        }
    }
    
    /// Animates a layout change
    public func animate(
        with animation: LayoutAnimation,
        animations: @escaping () -> Void,
        completion: (() -> Void)? = nil
    ) {
        guard animationsEnabled else {
            animations()
            completion?()
            return
        }
        
        UIView.animate(
            withDuration: animation.duration,
            delay: animation.delay,
            options: animation.timingFunction.animationOptions,
            animations: animations,
            completion: { _ in completion?() }
        )
    }
    
    /// Animates with spring physics
    public func animateSpring(
        damping: CGFloat = 0.7,
        initialVelocity: CGFloat = 0,
        duration: TimeInterval = 0.5,
        animations: @escaping () -> Void,
        completion: (() -> Void)? = nil
    ) {
        guard animationsEnabled else {
            animations()
            completion?()
            return
        }
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: damping,
            initialSpringVelocity: initialVelocity,
            options: [],
            animations: animations,
            completion: { _ in completion?() }
        )
    }
    
    /// Starts a custom frame-based animation
    @discardableResult
    public func startCustomAnimation(
        with animation: LayoutAnimation,
        update: @escaping (CGFloat) -> Void,
        completion: (() -> Void)? = nil
    ) -> AnimationToken {
        let id = UUID()
        let state = AnimationState(
            animation: animation,
            startTime: CACurrentMediaTime(),
            updateBlock: update
        )
        
        runningAnimations[id] = state
        if let completion = completion {
            completionHandlers[id] = completion
        }
        
        displayLink?.isPaused = false
        
        return AnimationToken(id: id, engine: self)
    }
    
    /// Cancels an animation
    public func cancelAnimation(_ token: AnimationToken) {
        runningAnimations.removeValue(forKey: token.id)
        completionHandlers.removeValue(forKey: token.id)
    }
    
    /// Cancels all running animations
    public func cancelAllAnimations() {
        runningAnimations.removeAll()
        completionHandlers.removeAll()
        displayLink?.isPaused = true
    }
}

