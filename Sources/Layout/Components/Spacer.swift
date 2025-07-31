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
    
    /// A unique property to identify spacer components
    public var isSpacer: Bool { return true }
    
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
        var frames: [UIView: CGRect] = [:]
        frames[self] = .zero // Spacer reports its size as zero
        return LayoutResult(frames: frames, totalSize: .zero) // Total size is also zero
    }
    
    public func extractViews() -> [UIView] {
        return [self]
    }
}
