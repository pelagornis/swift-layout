import UIKit

/// A layout that does nothing.
public struct EmptyLayout : Layout {
    /// Initalizes a layout that does nothing
    @inlinable
    public init() {
        self.init(internal: ())
    }

    @usableFromInline
    init(internal: Void) {}
    
    public var body: Never {
        neverLayout("EmptyLayout")
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        return LayoutResult(frames: [:], totalSize: .zero)
    }
    
    public func extractViews() -> [UIView] {
        return []
    }
}
