import UIKit

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
}

