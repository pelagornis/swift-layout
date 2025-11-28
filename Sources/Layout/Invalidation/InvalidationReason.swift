import Foundation

/// Represents the reason for layout invalidation
public enum InvalidationReason: Equatable, Sendable {
    /// Content of a view changed (text, image, etc.)
    case contentChanged
    /// Size constraints changed
    case sizeChanged
    /// View hierarchy changed
    case hierarchyChanged
    /// Environment value changed
    case environmentChanged
    /// Explicit invalidation request
    case explicit
    /// Animation frame update
    case animation
    /// Geometry changed
    case geometryChanged
}

/// Protocol for objects that can be invalidated
@MainActor
public protocol Invalidatable: AnyObject {
    /// Called when the layout needs to be recalculated
    func invalidateLayout(reason: InvalidationReason)
    
    /// Returns whether the layout is currently valid
    var isLayoutValid: Bool { get }
}

