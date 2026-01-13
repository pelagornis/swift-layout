import CoreGraphics

/// Types of transitions for layout changes
public enum LayoutTransition: Sendable {
    case none
    case opacity
    case scale
    case slide(edge: Edge)
    case move(offset: CGPoint)
    case combined([LayoutTransition])
    
    public enum Edge: Sendable {
        case top, bottom, leading, trailing
    }
    
    // MARK: - Convenience Static Properties
    
    /// Fade transition (alias for opacity)
    public static let fade = LayoutTransition.opacity
    
    /// Scale from center transition
    public static let scaleFromCenter = LayoutTransition.scale
    
    /// Slide from top
    public static let slideFromTop = LayoutTransition.slide(edge: .top)
    
    /// Slide from bottom
    public static let slideFromBottom = LayoutTransition.slide(edge: .bottom)
    
    /// Slide from leading
    public static let slideFromLeading = LayoutTransition.slide(edge: .leading)
    
    /// Slide from trailing
    public static let slideFromTrailing = LayoutTransition.slide(edge: .trailing)
    
    /// Combines fade and scale
    public static let fadeAndScale = LayoutTransition.combined([.opacity, .scale])
}

