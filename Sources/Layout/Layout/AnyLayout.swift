#if canImport(UIKit)
import UIKit

#endif
/// A type-erased wrapper for any Layout.
///
/// ``AnyLayout`` allows you to store and work with different layout types
/// in a uniform way, similar to SwiftUI's `AnyView`.
///
/// ## Overview
///
/// `AnyLayout` wraps any layout type and erases its specific type information,
/// allowing you to store different layout types in the same container or variable.
///
/// ## Example Usage
///
/// ```swift
/// var layout: AnyLayout
///
/// if condition {
///     layout = AnyLayout(VStack { ... })
/// } else {
///     layout = AnyLayout(HStack { ... })
/// }
///
/// container.setBody { layout }
/// ```
@MainActor
public struct AnyLayout: Layout {
    public typealias Body = Never
    
    public var body: Never {
        neverLayout("AnyLayout")
    }
    
    private let _calculateLayout: (CGRect) -> LayoutResult
    private let _extractViews: () -> [UIView]
    private let _intrinsicContentSize: CGSize
    
    /// Creates a type-erased layout from any layout.
    ///
    /// - Parameter layout: The layout to wrap
    public init<L: Layout>(_ layout: L) {
        _calculateLayout = { bounds in
            layout.calculateLayout(in: bounds)
        }
        _extractViews = {
            layout.extractViews()
        }
        _intrinsicContentSize = layout.intrinsicContentSize
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        return _calculateLayout(bounds)
    }
    
    public func extractViews() -> [UIView] {
        return _extractViews()
    }
    
    public var intrinsicContentSize: CGSize {
        return _intrinsicContentSize
    }
}
