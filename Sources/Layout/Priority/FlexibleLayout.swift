#if canImport(UIKit)
import UIKit

#endif
/// A layout that can grow or shrink flexibly
@MainActor
public struct FlexibleLayout: Layout {
    public typealias Body = Never
    
    public var body: Never {
        fatalError("FlexibleLayout is a primitive layout")
    }
    
    private let base: any Layout
    public let minSize: CGSize?
    public let maxSize: CGSize?
    public let idealSize: CGSize?
    public let flex: CGFloat
    
    public init(
        base: any Layout,
        minSize: CGSize? = nil,
        maxSize: CGSize? = nil,
        idealSize: CGSize? = nil,
        flex: CGFloat = 1
    ) {
        self.base = base
        self.minSize = minSize
        self.maxSize = maxSize
        self.idealSize = idealSize
        self.flex = flex
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        var effectiveBounds = bounds
        
        if let minSize = minSize {
            effectiveBounds.size.width = max(bounds.width, minSize.width)
            effectiveBounds.size.height = max(bounds.height, minSize.height)
        }
        
        if let maxSize = maxSize {
            effectiveBounds.size.width = min(effectiveBounds.width, maxSize.width)
            effectiveBounds.size.height = min(effectiveBounds.height, maxSize.height)
        }
        
        return base.calculateLayout(in: effectiveBounds)
    }
    
    public func extractViews() -> [UIView] {
        return base.extractViews()
    }
    
    public var intrinsicContentSize: CGSize {
        if let idealSize = idealSize {
            return idealSize
        }
        return base.intrinsicContentSize
    }
}

// MARK: - Layout Extension

extension Layout {
    /// Makes the layout flexible
    public func flexible(
        minSize: CGSize? = nil,
        maxSize: CGSize? = nil,
        idealSize: CGSize? = nil,
        flex: CGFloat = 1
    ) -> FlexibleLayout {
        return FlexibleLayout(
            base: self,
            minSize: minSize,
            maxSize: maxSize,
            idealSize: idealSize,
            flex: flex
        )
    }
}

