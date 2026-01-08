import Foundation

/// Coordinate spaces for geometry calculations
public enum CoordinateSpace: Hashable, Sendable {
    case local
    case global
    case named(String)
}
