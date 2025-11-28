import UIKit

/// Protocol for values that can be interpolated
public protocol VectorArithmetic {
    func interpolated(towards other: Self, amount: Double) -> Self
}

extension CGFloat: VectorArithmetic {
    public func interpolated(towards other: CGFloat, amount: Double) -> CGFloat {
        return self + (other - self) * CGFloat(amount)
    }
}

extension Double: VectorArithmetic {
    public func interpolated(towards other: Double, amount: Double) -> Double {
        return self + (other - self) * amount
    }
}

extension CGPoint: VectorArithmetic {
    public func interpolated(towards other: CGPoint, amount: Double) -> CGPoint {
        return CGPoint(
            x: x + (other.x - x) * CGFloat(amount),
            y: y + (other.y - y) * CGFloat(amount)
        )
    }
}

extension CGSize: VectorArithmetic {
    public func interpolated(towards other: CGSize, amount: Double) -> CGSize {
        return CGSize(
            width: width + (other.width - width) * CGFloat(amount),
            height: height + (other.height - height) * CGFloat(amount)
        )
    }
}

extension CGRect: VectorArithmetic {
    public func interpolated(towards other: CGRect, amount: Double) -> CGRect {
        return CGRect(
            x: origin.x + (other.origin.x - origin.x) * CGFloat(amount),
            y: origin.y + (other.origin.y - origin.y) * CGFloat(amount),
            width: width + (other.width - width) * CGFloat(amount),
            height: height + (other.height - height) * CGFloat(amount)
        )
    }
}

