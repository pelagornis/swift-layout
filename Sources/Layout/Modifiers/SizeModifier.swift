import UIKit

/// Represents a percentage value (PinLayout-style)
///
/// Use `Percent` to specify sizes and positions as percentages of parent bounds.
/// Created using the postfix `%` operator: `10%`, `50%`, etc.
public struct Percent: Sendable {
    /// The percentage value (e.g., 10 for 10%)
    public let value: CGFloat
    
    /// Creates a percent value
    public init(value: CGFloat) {
        self.value = value
    }
    
    /// Calculates the actual value based on parent size
    /// - Parameter parentSize: The parent size to calculate percentage from
    /// - Returns: The calculated value
    public func of(_ parentSize: CGFloat) -> CGFloat {
        return parentSize * value / 100.0
    }
    
    public var description: String {
        if value.truncatingRemainder(dividingBy: 1) == 0.0 {
            return "\(Int(value))%"
        } else {
            return "\(value)%"
        }
    }
}

/// Postfix operator to create Percent from numeric values (PinLayout-style)
postfix operator %

/// Creates a Percent from CGFloat
public postfix func % (v: CGFloat) -> Percent {
    return Percent(value: v)
}

/// Creates a Percent from Float
public postfix func % (v: Float) -> Percent {
    return Percent(value: CGFloat(v))
}

/// Creates a Percent from Double
public postfix func % (v: Double) -> Percent {
    return Percent(value: CGFloat(v))
}

/// Creates a Percent from Int
public postfix func % (v: Int) -> Percent {
    return Percent(value: CGFloat(v))
}

/// Prefix operator for negative percentages
prefix operator -
public prefix func - (p: Percent) -> Percent {
    return Percent(value: -p.value)
}

/// Represents a size value that can be either fixed or percentage-based
public enum SizeValue: Sendable{
    /// Fixed size in points
    case fixed(CGFloat)
    /// Percentage of parent bounds (using Percent type)
    case percent(Percent)
    
    /// Calculates the actual size based on parent bounds
    func calculate(relativeTo parentSize: CGFloat) -> CGFloat {
        switch self {
        case .fixed(let value):
            return value
        case .percent(let percent):
            return percent.of(parentSize)
        }
    }
}

public struct SizeModifier: LayoutModifier {
    /// Optional width override (can be fixed or percentage)
    public let width: SizeValue?
    
    /// Optional height override (can be fixed or percentage)
    public let height: SizeValue?
    
    /// Creates a size modifier with fixed values (backward compatibility)
    ///
    /// - Parameters:
    ///   - width: Optional width to set, `nil` to keep current width
    ///   - height: Optional height to set, `nil` to keep current height
    public init(width: CGFloat? = nil, height: CGFloat? = nil) {
        self.width = width.map { .fixed($0) }
        self.height = height.map { .fixed($0) }
    }
    
    /// Creates a size modifier with SizeValue (supports percentage)
    ///
    /// - Parameters:
    ///   - width: Optional width value (fixed or percentage)
    ///   - height: Optional height value (fixed or percentage)
    public init(width: SizeValue? = nil, height: SizeValue? = nil) {
        self.width = width
        self.height = height
    }
    
    /// Creates a size modifier with Percent (PinLayout-style)
    ///
    /// - Parameters:
    ///   - width: Optional width as Percent (e.g., `80%`)
    ///   - height: Optional height as Percent (e.g., `50%`)
    public init(width: Percent? = nil, height: Percent? = nil) {
        self.width = width.map { .percent($0) }
        self.height = height.map { .percent($0) }
    }
    
    /// Creates a size modifier with mixed types (Percent width, CGFloat height)
    ///
    /// - Parameters:
    ///   - width: Optional width as Percent (e.g., `80%`)
    ///   - height: Optional height as fixed value
    public init(width: Percent?, height: CGFloat?) {
        self.width = width.map { .percent($0) }
        self.height = height.map { .fixed($0) }
    }
    
    /// Creates a size modifier with mixed types (CGFloat width, Percent height)
    ///
    /// - Parameters:
    ///   - width: Optional width as fixed value
    ///   - height: Optional height as Percent (e.g., `50%`)
    public init(width: CGFloat?, height: Percent?) {
        self.width = width.map { .fixed($0) }
        self.height = height.map { .percent($0) }
    }
    
    public func apply(to frame: CGRect, in bounds: CGRect) -> CGRect {
        var newFrame = frame
        if let width = width {
            // Use bounds.width if available, otherwise use frame.width as fallback
            let parentWidth = bounds.width > 0 ? bounds.width : frame.width
            newFrame.size.width = width.calculate(relativeTo: parentWidth)
        }
        if let height = height {
            // Use bounds.height if available, otherwise use frame.height as fallback
            let parentHeight = bounds.height > 0 ? bounds.height : frame.height
            newFrame.size.height = height.calculate(relativeTo: parentHeight)
        }
        return newFrame
    }
}
