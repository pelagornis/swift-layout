import Foundation

/// Property wrapper that automatically animates value changes
@MainActor
@propertyWrapper
public final class Animated<Value: VectorArithmetic> {
    private var _value: Value
    private var targetValue: Value
    private var animationToken: AnimationToken?
    private let animation: LayoutAnimation
    private var onChange: ((Value) -> Void)?
    
    public var wrappedValue: Value {
        get { _value }
        set {
            targetValue = newValue
            animateToTarget()
        }
    }
    
    public var projectedValue: Animated<Value> { self }
    
    public init(wrappedValue: Value, animation: LayoutAnimation = .default) {
        self._value = wrappedValue
        self.targetValue = wrappedValue
        self.animation = animation
    }
    
    /// Sets a callback for value changes
    public func onChange(_ handler: @escaping (Value) -> Void) {
        self.onChange = handler
    }
    
    /// Immediately sets the value without animation
    public func setValue(_ value: Value, animated: Bool = true) {
        if animated {
            wrappedValue = value
        } else {
            animationToken?.cancel()
            _value = value
            targetValue = value
            onChange?(value)
        }
    }
    
    private func animateToTarget() {
        animationToken?.cancel()
        
        let startValue = _value
        let endValue = targetValue
        
        animationToken = LayoutAnimationEngine.shared.startCustomAnimation(
            with: animation,
            update: { [weak self] progress in
                guard let self = self else { return }
                self._value = startValue.interpolated(towards: endValue, amount: Double(progress))
                self.onChange?(self._value)
            }
        )
    }
}
