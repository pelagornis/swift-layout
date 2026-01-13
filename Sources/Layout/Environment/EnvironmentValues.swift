#if canImport(UIKit)
import UIKit

#endif
/// Container for environment values that flow down the view hierarchy
@MainActor
public final class EnvironmentValues {
    /// Storage for environment values
    private var storage: [ObjectIdentifier: Any] = [:]
    
    /// Parent environment values (for inheritance)
    private weak var parent: EnvironmentValues?
    
    /// Creates a new environment values container
    public init(parent: EnvironmentValues? = nil) {
        self.parent = parent
    }
    
    /// Gets or sets an environment value
    public subscript<K: EnvironmentKey>(key: K.Type) -> K.Value {
        get {
            if let value = storage[ObjectIdentifier(key)] as? K.Value {
                return value
            }
            return parent?[key] ?? K.defaultValue
        }
        set {
            storage[ObjectIdentifier(key)] = newValue
        }
    }
    
    /// Creates a child environment with inherited values
    public func makeChild() -> EnvironmentValues {
        return EnvironmentValues(parent: self)
    }
    
    /// Merges another environment's values into this one
    public func merge(_ other: EnvironmentValues) {
        for (key, value) in other.storage {
            storage[key] = value
        }
    }
}

// MARK: - Environment Values Extensions

extension EnvironmentValues {
    /// The current color scheme
    public var colorScheme: ColorScheme {
        get { self[ColorSchemeKey.self] }
        set { self[ColorSchemeKey.self] = newValue }
    }
    
    /// The current layout direction
    public var layoutDirection: LayoutDirection {
        get { self[LayoutDirectionKey.self] }
        set { self[LayoutDirectionKey.self] = newValue }
    }
    
    /// The current font
    public var font: UIFont {
        get { self[FontKey.self] }
        set { self[FontKey.self] = newValue }
    }
    
    /// The current foreground color
    public var foregroundColor: UIColor {
        get { self[ForegroundColorKey.self] }
        set { self[ForegroundColorKey.self] = newValue }
    }
    
    /// Whether views are enabled
    public var isEnabled: Bool {
        get { self[IsEnabledKey.self] }
        set { self[IsEnabledKey.self] = newValue }
    }
    
    /// Minimum scale factor for text
    public var minimumScaleFactor: CGFloat {
        get { self[MinimumScaleFactorKey.self] }
        set { self[MinimumScaleFactorKey.self] = newValue }
    }
    
    /// Line limit for text
    public var lineLimit: Int? {
        get { self[LineLimitKey.self] }
        set { self[LineLimitKey.self] = newValue }
    }
    
    /// Content size category
    public var contentSizeCategory: UIContentSizeCategory {
        get { self[ContentSizeCategoryKey.self] }
        set { self[ContentSizeCategoryKey.self] = newValue }
    }
    
    /// Safe area insets
    public var safeAreaInsets: UIEdgeInsets {
        get { self[SafeAreaInsetsKey.self] }
        set { self[SafeAreaInsetsKey.self] = newValue }
    }
    
    /// Whether animations are enabled
    public var animationEnabled: Bool {
        get { self[AnimationEnabledKey.self] }
        set { self[AnimationEnabledKey.self] = newValue }
    }
}
