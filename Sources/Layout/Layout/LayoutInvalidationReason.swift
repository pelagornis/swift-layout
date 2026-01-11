import UIKit

/// Reason for layout invalidation in the new layout system
///
/// `LayoutInvalidationReason` provides context about why a layout node needs to be
/// recalculated. This allows the layout system to perform more efficient updates
/// by only recalculating what's necessary.
///
/// ## Overview
///
/// Instead of a simple boolean `isDirty` flag, `LayoutInvalidationReason` tells the
/// layout system:
/// - **What** changed (size, children, environment, content)
/// - **How** to handle the invalidation (partial vs full recalculation)
///
/// ## Example
///
/// ```swift
/// func invalidate(_ reason: LayoutInvalidationReason) {
///     switch reason {
///     case .size:
///         // Only remeasure, reuse placement if possible
///         invalidateMeasurement()
///     case .children:
///         // Recalculate children, but reuse parent measurement
///         invalidateChildren()
///     case .environment:
///         // Recalculate with new environment values
///         invalidateWithEnvironment()
///     case .content:
///         // Content changed (text, image), remeasure
///         invalidateMeasurement()
///     case .full:
///         // Complete recalculation
///         invalidateEverything()
///     }
/// }
/// ```
@MainActor
public enum LayoutInvalidationReason: Equatable {
    /// Size constraints changed
    case size
    
    /// Children changed (added/removed/reordered)
    case children
    
    /// Environment values changed
    case environment
    
    /// Content changed (text, image, etc.)
    case content
    
    /// Full invalidation (everything)
    case full
    
    /// Whether this reason requires measurement recalculation
    public var requiresMeasurement: Bool {
        switch self {
        case .size, .content, .full:
            return true
        case .children, .environment:
            return false
        }
    }
    
    /// Whether this reason requires placement recalculation
    public var requiresPlacement: Bool {
        switch self {
        case .size, .children, .full:
            return true
        case .environment, .content:
            return false
        }
    }
    
    /// Whether this reason requires full recalculation
    public var requiresFullRecalculation: Bool {
        self == .full
    }
}
