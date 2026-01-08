import UIKit

/// Distributes space in stacks based on child priorities
@MainActor
public final class StackPriorityDistributor {
    /// Distributes vertical space among subviews
    public static func distributeVertical(
        subviews: [UIView],
        availableHeight: CGFloat,
        spacing: CGFloat
    ) -> [CGFloat] {
        let items = subviews.map { view -> (CGFloat, CGFloat, LayoutPriority) in
            let intrinsic = view.intrinsicContentSize
            let minHeight = intrinsic.height != UIView.noIntrinsicMetric ? intrinsic.height : 20
            let maxHeight = view is Spacer ? CGFloat.greatestFiniteMagnitude : minHeight * 3
            return (minHeight, maxHeight, view.layoutPriority)
        }
        
        return PrioritySizeCalculator.calculateSizes(
            for: items,
            availableSpace: availableHeight,
            spacing: spacing
        )
    }
    
    /// Distributes horizontal space among subviews
    public static func distributeHorizontal(
        subviews: [UIView],
        availableWidth: CGFloat,
        spacing: CGFloat
    ) -> [CGFloat] {
        let items = subviews.map { view -> (CGFloat, CGFloat, LayoutPriority) in
            let intrinsic = view.intrinsicContentSize
            let minWidth = intrinsic.width != UIView.noIntrinsicMetric ? intrinsic.width : 20
            let maxWidth = view is Spacer ? CGFloat.greatestFiniteMagnitude : minWidth * 3
            return (minWidth, maxWidth, view.layoutPriority)
        }
        
        return PrioritySizeCalculator.calculateSizes(
            for: items,
            availableSpace: availableWidth,
            spacing: spacing
        )
    }
}

// MARK: - UIView Extension for Priority

extension UIView {
    private static var layoutPriorityKey: UInt8 = 0
    private static var contentPriorityKey: UInt8 = 0
    
    /// The layout priority for this view
    public var layoutPriority: LayoutPriority {
        get {
            return objc_getAssociatedObject(self, &Self.layoutPriorityKey) as? LayoutPriority ?? .defaultLow
        }
        set {
            objc_setAssociatedObject(self, &Self.layoutPriorityKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// The content priority for this view
    public var contentPriority: ContentPriority {
        get {
            return objc_getAssociatedObject(self, &Self.contentPriorityKey) as? ContentPriority ?? .default
        }
        set {
            objc_setAssociatedObject(self, &Self.contentPriorityKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            setContentHuggingPriority(UILayoutPriority(Float(newValue.hugging.rawValue)), for: .horizontal)
            setContentHuggingPriority(UILayoutPriority(Float(newValue.hugging.rawValue)), for: .vertical)
            setContentCompressionResistancePriority(UILayoutPriority(Float(newValue.compressionResistance.rawValue)), for: .horizontal)
            setContentCompressionResistancePriority(UILayoutPriority(Float(newValue.compressionResistance.rawValue)), for: .vertical)
        }
    }
}
