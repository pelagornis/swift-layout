#if canImport(UIKit)
import UIKit

#endif
/// A layout with a fixed size in one or both dimensions
@MainActor
public struct FixedSizeLayout: Layout {
    public typealias Body = Never
    
    public var body: Never {
        fatalError("FixedSizeLayout is a primitive layout")
    }
    
    private let base: any Layout
    public let horizontal: Bool
    public let vertical: Bool
    
    public init(base: any Layout, horizontal: Bool = true, vertical: Bool = true) {
        self.base = base
        self.horizontal = horizontal
        self.vertical = vertical
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        let intrinsic = base.intrinsicContentSize
        
        var effectiveBounds = bounds
        
        if horizontal && intrinsic.width != UIView.noIntrinsicMetric {
            effectiveBounds.size.width = intrinsic.width
        }
        
        if vertical && intrinsic.height != UIView.noIntrinsicMetric {
            effectiveBounds.size.height = intrinsic.height
        }
        
        return base.calculateLayout(in: effectiveBounds)
    }
    
    public func extractViews() -> [UIView] {
        return base.extractViews()
    }
    
    public var intrinsicContentSize: CGSize {
        return base.intrinsicContentSize
    }
}

// MARK: - Layout Extension

extension Layout {
    /// Fixes the size of the layout to its ideal size
    public func fixedSize(horizontal: Bool = true, vertical: Bool = true) -> FixedSizeLayout {
        return FixedSizeLayout(base: self, horizontal: horizontal, vertical: vertical)
    }
}

