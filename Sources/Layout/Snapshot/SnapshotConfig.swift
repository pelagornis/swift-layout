#if canImport(UIKit)
import UIKit

#endif
/// Configuration for snapshot testing
public struct SnapshotConfig {
    /// Size for the snapshot
    public let size: CGSize
    
    /// Scale factor for rendering
    public let scale: CGFloat
    
    /// Whether to render shadows
    public let renderShadows: Bool
    
    /// Background color
    public let backgroundColor: UIColor
    
    /// Whether to include safe area insets
    public let includeSafeArea: Bool
    
    /// Traits for the snapshot
    public let traits: UITraitCollection
    
    public init(
        size: CGSize = CGSize(width: 375, height: 667),
        scale: CGFloat = 2.0,
        renderShadows: Bool = true,
        backgroundColor: UIColor = .white,
        includeSafeArea: Bool = false,
        traits: UITraitCollection = .current
    ) {
        self.size = size
        self.scale = scale
        self.renderShadows = renderShadows
        self.backgroundColor = backgroundColor
        self.includeSafeArea = includeSafeArea
        self.traits = traits
    }
        
    /// Creates a dark mode variant
    public func darkMode() -> SnapshotConfig {
        let darkTraits = UITraitCollection(userInterfaceStyle: .dark)
        let combinedTraits = UITraitCollection(traitsFrom: [traits, darkTraits])
        return SnapshotConfig(
            size: size,
            scale: scale,
            renderShadows: renderShadows,
            backgroundColor: .black,
            includeSafeArea: includeSafeArea,
            traits: combinedTraits
        )
    }
    
    /// Creates a landscape variant
    public func landscape() -> SnapshotConfig {
        return SnapshotConfig(
            size: CGSize(width: size.height, height: size.width),
            scale: scale,
            renderShadows: renderShadows,
            backgroundColor: backgroundColor,
            includeSafeArea: includeSafeArea,
            traits: traits
        )
    }
}

