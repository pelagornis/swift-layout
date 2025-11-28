import UIKit

/// Color scheme (light/dark mode)
public struct ColorSchemeKey: EnvironmentKey {
    public static let defaultValue: ColorScheme = .light
}

/// Layout direction (LTR/RTL)
public struct LayoutDirectionKey: EnvironmentKey {
    public static let defaultValue: LayoutDirection = .leftToRight
}

/// Font for text content
public struct FontKey: EnvironmentKey {
    public static let defaultValue: UIFont = .systemFont(ofSize: 17)
}

/// Foreground color for content
public struct ForegroundColorKey: EnvironmentKey {
    public static let defaultValue: UIColor = .label
}

/// Whether views are enabled
public struct IsEnabledKey: EnvironmentKey {
    public static let defaultValue: Bool = true
}

/// Minimum scale factor for text
public struct MinimumScaleFactorKey: EnvironmentKey {
    public static let defaultValue: CGFloat = 1.0
}

/// Line limit for text
public struct LineLimitKey: EnvironmentKey {
    public static let defaultValue: Int? = nil
}

/// Content size category for accessibility
public struct ContentSizeCategoryKey: EnvironmentKey {
    public static let defaultValue: UIContentSizeCategory = .medium
}

/// Safe area insets
public struct SafeAreaInsetsKey: EnvironmentKey {
    public static let defaultValue: UIEdgeInsets = .zero
}

/// Animation enabled state
public struct AnimationEnabledKey: EnvironmentKey {
    public static let defaultValue: Bool = true
}

