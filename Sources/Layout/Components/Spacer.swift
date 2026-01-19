import UIKit

/// A flexible space layout for pushing other layouts apart.
///
/// ``Spacer`` is equivalent to SwiftUI's Spacer and expands to fill
/// available space in stack layouts, or uses a minimum length if specified.
///
/// ## Overview
///
/// `Spacer` is a flexible layout component that expands to fill available space
/// in stack layouts. It's commonly used to push other views apart or create
/// flexible spacing between layout elements.
///
/// ## Key Features
///
/// - **Flexible Sizing**: Expands to fill available space in stack layouts
/// - **Minimum Length**: Optional minimum length constraint
/// - **Stack Integration**: Works seamlessly with `VStack`, `HStack`, and `ZStack`
/// - **ScrollView Aware**: Automatically adjusts behavior in ScrollView contexts
/// - **Non-Interactive**: Disabled user interaction by default
///
/// ## Example Usage
///
/// ```swift
/// HStack {
///     leftButton.layout()
///     Spacer() // Pushes buttons apart
///     rightButton.layout()
/// }
///
/// VStack {
///     titleLabel.layout()
///     Spacer(minLength: 20) // Minimum 20pt spacing
///     footerLabel.layout()
/// }
/// ```
///
/// ## Topics
///
/// ### Initialization
/// - ``init(minLength:)``
///
/// ### Properties
/// - ``minLength``
/// - ``isSpacer``
///
/// ### Layout Behavior
/// - ``calculateLayout(in:)``
/// - ``extractViews()``
/// - ``intrinsicContentSize``
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
        
        // Spacer takes all available space while ensuring minimum length
        let spacerHeight = max(minLength ?? bounds.height, 0)
        let spacerWidth = bounds.width
        
        frames[self] = CGRect(x: 0, y: 0, width: spacerWidth, height: spacerHeight)
        return LayoutResult(frames: frames, totalSize: CGSize(width: spacerWidth, height: spacerHeight))
    }
    
    public func extractViews() -> [UIView] {
        return [self]
    }
    
    public override var intrinsicContentSize: CGSize {
        // Spacer's intrinsic content size is minimum length or 0
        let minSize = minLength ?? 0
        return CGSize(width: minSize, height: minSize)
    }
}
