import CoreGraphics

/// Modifier for positioning views relative to edges with percentage support
///
/// Use ``EdgeModifier`` to position a view relative to container edges,
/// supporting both fixed values and percentages (PinLayout-style).
///
/// ## Overview
///
/// `EdgeModifier` allows you to position a view relative to container edges
/// using either fixed values or percentages. This provides flexible positioning
/// similar to PinLayout's edge-based positioning.
///
/// ## Example Usage
///
/// ```swift
/// view.layout()
///     .top(25%)  // 25% from top
///     .centerX()  // Horizontal center
///
/// view.layout()
///     .bottom(20)  // 20pt from bottom
///     .leading(10%)  // 10% from leading edge
/// ```
public struct EdgeModifier: LayoutModifier {
    /// Edge to position relative to
    public enum Edge: Sendable {
        case top
        case bottom
        case leading
        case trailing
    }
    
    /// The edge to position relative to
    public let edge: Edge
    
    /// Position value (fixed or percentage)
    public let value: SizeValue
    
    /// Creates an edge modifier with SizeValue.
    ///
    /// - Parameters:
    ///   - edge: The edge to position relative to
    ///   - value: Position value (fixed or percentage)
    public init(edge: Edge, value: SizeValue) {
        self.edge = edge
        self.value = value
    }
    
    /// Creates an edge modifier with Percent (PinLayout-style).
    ///
    /// - Parameters:
    ///   - edge: The edge to position relative to
    ///   - percent: Position as Percent (e.g., `25%`)
    public init(edge: Edge, percent: Percent) {
        self.edge = edge
        self.value = .percent(percent)
    }
    
    public func apply(to frame: CGRect, in bounds: CGRect) -> CGRect {
        var newFrame = frame
        let calculatedValue = value.calculate(relativeTo: edge == .top || edge == .bottom ? bounds.height : bounds.width)
        
        switch edge {
        case .top:
            newFrame.origin.y = calculatedValue
        case .bottom:
            newFrame.origin.y = bounds.height - frame.height - calculatedValue
        case .leading:
            newFrame.origin.x = calculatedValue
        case .trailing:
            newFrame.origin.x = bounds.width - frame.width - calculatedValue
        }
        
        return newFrame
    }
}
