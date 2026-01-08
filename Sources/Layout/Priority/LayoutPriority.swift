import Foundation

/// Represents the priority of a layout in size calculations
public struct LayoutPriority: Comparable, Hashable, Sendable {
    public let rawValue: Double
    
    public init(_ rawValue: Double) {
        self.rawValue = rawValue
    }
    
    // Standard priorities
    public static let required = LayoutPriority(1000)
    public static let defaultHigh = LayoutPriority(750)
    public static let defaultLow = LayoutPriority(250)
    public static let fittingSize = LayoutPriority(50)
    
    // SwiftUI-like priorities
    public static let high = LayoutPriority(751)
    public static let medium = LayoutPriority(500)
    public static let low = LayoutPriority(249)
    
    public static func < (lhs: LayoutPriority, rhs: LayoutPriority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    public static func custom(_ value: Double) -> LayoutPriority {
        return LayoutPriority(value)
    }
}
