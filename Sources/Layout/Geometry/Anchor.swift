import UIKit

/// Represents a specific point or region in a view's geometry
public struct Anchor<Value> {
    fileprivate let value: Value
    fileprivate let source: GeometryProxy
    
    /// Creates an anchor
    init(value: Value, source: GeometryProxy) {
        self.value = value
        self.source = source
    }
}

@MainActor
extension Anchor where Value == CGRect {
    /// Gets the bounds anchor
    public static func bounds(_ proxy: GeometryProxy) -> Anchor<CGRect> {
        return Anchor(value: proxy.bounds, source: proxy)
    }
}

@MainActor
extension Anchor where Value == CGPoint {
    /// Gets the center anchor
    public static func center(_ proxy: GeometryProxy) -> Anchor<CGPoint> {
        let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
        return Anchor(value: center, source: proxy)
    }
    
    /// Gets a point at the specified unit point
    public static func point(_ unitPoint: UnitPoint, in proxy: GeometryProxy) -> Anchor<CGPoint> {
        let point = CGPoint(
            x: proxy.size.width * unitPoint.x,
            y: proxy.size.height * unitPoint.y
        )
        return Anchor(value: point, source: proxy)
    }
}
