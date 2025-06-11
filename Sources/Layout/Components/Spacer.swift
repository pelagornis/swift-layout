import UIKit

/// A flexible space layout for pushing other layouts apart.
///
/// ``Spacer`` is equivalent to SwiftUI's Spacer and expands to fill
/// available space in stack layouts, or uses a minimum length if specified.
///
/// ## Example Usage
///
/// ```swift
/// Horizontal {
///     leftButton.layout()
///     Spacer() // Pushes buttons apart
///     rightButton.layout()
/// }
/// ```
public struct Spacer: Layout {
    public typealias Body = Never
    
    public let minLength: CGFloat?
    
    public init(minLength: CGFloat? = nil) {
        self.minLength = minLength
    }
    
    public var body: Never {
        neverLayout("Spacer")
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        // Spacer는 사용 가능한 공간을 채우되, 최소 길이를 보장
        let width = minLength ?? 0
        let height = minLength ?? 0
        
        return LayoutResult(totalSize: CGSize(width: width, height: height))
    }
    
    public func extractViews() -> [UIView] {
        return []
    }
}
