import UIKit

/// A layout that modifies environment values for its content
@MainActor
public struct EnvironmentModifierLayout<Value>: Layout {
    public typealias Body = Never
    
    public var body: Never {
        fatalError("EnvironmentModifierLayout is a primitive layout")
    }
    
    private let base: any Layout
    private let keyPath: WritableKeyPath<EnvironmentValues, Value>
    private let value: Value
    
    public init(
        base: any Layout,
        keyPath: WritableKeyPath<EnvironmentValues, Value>,
        value: Value
    ) {
        self.base = base
        self.keyPath = keyPath
        self.value = value
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        return base.calculateLayout(in: bounds)
    }
    
    public func extractViews() -> [UIView] {
        let views = base.extractViews()
        
        for view in views {
            var env = EnvironmentProvider.shared.environment(for: view)
            env[keyPath: keyPath] = value
            EnvironmentProvider.shared.setEnvironment(env, for: view)
        }
        
        return views
    }
    
    public var intrinsicContentSize: CGSize {
        return base.intrinsicContentSize
    }
}

// MARK: - Layout Extension for Environment

extension Layout {
    /// Sets an environment value for this layout and its children
    public func environment<Value>(
        _ keyPath: WritableKeyPath<EnvironmentValues, Value>,
        _ value: Value
    ) -> EnvironmentModifierLayout<Value> {
        return EnvironmentModifierLayout(base: self, keyPath: keyPath, value: value)
    }
    
    /// Sets the font environment value
    public func font(_ font: UIFont) -> EnvironmentModifierLayout<UIFont> {
        return environment(\.font, font)
    }
    
    /// Sets the foreground color environment value
    public func foregroundColor(_ color: UIColor) -> EnvironmentModifierLayout<UIColor> {
        return environment(\.foregroundColor, color)
    }
    
    /// Disables the view and its children
    public func disabled(_ isDisabled: Bool = true) -> EnvironmentModifierLayout<Bool> {
        return environment(\.isEnabled, !isDisabled)
    }
    
    /// Sets the line limit for text
    public func lineLimit(_ limit: Int?) -> EnvironmentModifierLayout<Int?> {
        return environment(\.lineLimit, limit)
    }
    
    /// Sets the minimum scale factor for text
    public func minimumScaleFactor(_ factor: CGFloat) -> EnvironmentModifierLayout<CGFloat> {
        return environment(\.minimumScaleFactor, factor)
    }
}

// MARK: - UIView Extension for Environment

extension UIView {
    private static var environmentKey: UInt8 = 0
    
    /// The environment values for this view
    public var environment: EnvironmentValues {
        get {
            return EnvironmentProvider.shared.environment(for: self)
        }
        set {
            EnvironmentProvider.shared.setEnvironment(newValue, for: self)
        }
    }
    
    /// Gets an environment value
    public func environmentValue<K: EnvironmentKey>(_ key: K.Type) -> K.Value {
        return environment[key]
    }
    
    /// Sets an environment value
    public func setEnvironmentValue<K: EnvironmentKey>(_ value: K.Value, for key: K.Type) {
        environment[key] = value
    }
}

