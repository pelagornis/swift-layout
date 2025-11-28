import UIKit

/// A layout that has a specific priority
@MainActor
public struct PriorityLayout: Layout {
    public typealias Body = Never
    
    public var body: Never {
        fatalError("PriorityLayout is a primitive layout")
    }
    
    private let base: any Layout
    public let priority: LayoutPriority
    
    public init(base: any Layout, priority: LayoutPriority) {
        self.base = base
        self.priority = priority
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        return base.calculateLayout(in: bounds)
    }
    
    public func extractViews() -> [UIView] {
        return base.extractViews()
    }
    
    public var intrinsicContentSize: CGSize {
        return base.intrinsicContentSize
    }
}

// MARK: - Layout Extensions for Priority

extension Layout {
    /// Sets the layout priority
    public func layoutPriority(_ priority: LayoutPriority) -> PriorityLayout {
        return PriorityLayout(base: self, priority: priority)
    }
    
    /// Sets the layout priority using a double value
    public func layoutPriority(_ value: Double) -> PriorityLayout {
        return PriorityLayout(base: self, priority: LayoutPriority(value))
    }
}

