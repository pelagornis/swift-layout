import UIKit

/// A flexible space layout for pushing other layouts apart.
///
/// ``Spacer`` is equivalent to SwiftUI's Spacer and expands to fill
/// available space in stack layouts, or uses a minimum length if specified.
///
/// ## Example Usage
///
/// ```swift
/// HStack {
///     leftButton.layout()
///     Spacer() // Pushes buttons apart
///     rightButton.layout()
/// }
/// ```
public class Spacer: UIView, Layout {
    public typealias Body = Never
    
    public let minLength: CGFloat?
    
    public init(minLength: CGFloat? = nil) {
        self.minLength = minLength
        super.init(frame: .zero)
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        self.minLength = nil
        super.init(coder: coder)
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = false
    }
    
    public var body: Never {
        neverLayout("Spacer")
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        // Spacer는 사용 가능한 공간을 채우되, 최소 길이를 보장
        let width = minLength ?? max(bounds.width, 20)
        let height = minLength ?? max(bounds.height, 5)
        
        // 최소 크기 보장
        let finalWidth = max(width, 20)
        let finalHeight = max(height, 5)
        
        return LayoutResult(
            frames: [self: CGRect(origin: .zero, size: CGSize(width: finalWidth, height: finalHeight))], 
            totalSize: CGSize(width: finalWidth, height: finalHeight)
        )
    }
    
    public func extractViews() -> [UIView] {
        return [self]
    }
}
