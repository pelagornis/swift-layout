import UIKit

/// A layout that does nothing.
///
/// ``EmptyLayout`` represents an empty layout that contains no views
/// and takes up no space. It's useful for conditional layouts or as a placeholder.
///
/// ## Example Usage
///
/// ```swift
/// VStack {
///     if shouldShowContent {
///         contentView.layout()
///     } else {
///         EmptyLayout()
///     }
/// }
/// ```
@MainActor
public struct EmptyLayout: Layout {
    public typealias Body = Never
    
    public var body: Never {
        neverLayout("EmptyLayout")
    }
    
    /// Initializes an empty layout.
    @inlinable
    public init() {}
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        return LayoutResult(frames: [:], totalSize: .zero)
    }
    
    public func extractViews() -> [UIView] {
        return []
    }
    
    public var intrinsicContentSize: CGSize {
        return .zero
    }
}
