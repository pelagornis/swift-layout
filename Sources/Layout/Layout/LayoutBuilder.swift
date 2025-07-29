import Foundation

/// A result builder that constructs complex layouts from multiple child layout components.
///
/// ``LayoutBuilder`` provides a declarative syntax for creating layouts by combining
/// multiple layout components. It automatically determines the appropriate arrangement
/// based on the types of layouts being combined.
@resultBuilder
public struct LayoutBuilder {
    
    /// Creates a layout from a single component.
    public static func buildBlock<C: Layout>(_ component: C) -> C {
        print("🔧 LayoutBuilder - buildBlock(1) - component: \(type(of: component))")
        return component
    }
    
    /// Creates a layout from two components.
    public static func buildBlock<C0: Layout, C1: Layout>(_ c0: C0, _ c1: C1) -> TupleLayout {
        print("🔧 LayoutBuilder - buildBlock(2) - c0: \(type(of: c0)), c1: \(type(of: c1))")
        // 단순히 TupleLayout을 생성하고, VStack/HStack이 자체적으로 arrangement를 처리하도록 함
        return TupleLayout([c0, c1], arrangement: .vertical)
    }
    
    /// Creates a layout from three components.
    public static func buildBlock<C0: Layout, C1: Layout, C2: Layout>(_ c0: C0, _ c1: C1, _ c2: C2) -> TupleLayout {
        print("🔧 LayoutBuilder - buildBlock(3) - c0: \(type(of: c0)), c1: \(type(of: c1)), c2: \(type(of: c2))")
        return TupleLayout([c0, c1, c2], arrangement: .vertical)
    }
    
    /// Creates a layout from four components.
    public static func buildBlock<C0: Layout, C1: Layout, C2: Layout, C3: Layout>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3) -> TupleLayout {
        print("🔧 LayoutBuilder - buildBlock(4) - c0: \(type(of: c0)), c1: \(type(of: c1)), c2: \(type(of: c2)), c3: \(type(of: c3))")
        return TupleLayout([c0, c1, c2, c3], arrangement: .vertical)
    }
    
    /// Creates a layout from five components.
    public static func buildBlock<C0: Layout, C1: Layout, C2: Layout, C3: Layout, C4: Layout>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4) -> TupleLayout {
        print("🔧 LayoutBuilder - buildBlock(5) - c0: \(type(of: c0)), c1: \(type(of: c1)), c2: \(type(of: c2)), c3: \(type(of: c3)), c4: \(type(of: c4))")
        return TupleLayout([c0, c1, c2, c3, c4], arrangement: .vertical)
    }
    
    /// Creates a layout from six components.
    public static func buildBlock<C0: Layout, C1: Layout, C2: Layout, C3: Layout, C4: Layout, C5: Layout>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5) -> TupleLayout {
        print("🔧 LayoutBuilder - buildBlock(6) - c0: \(type(of: c0)), c1: \(type(of: c1)), c2: \(type(of: c2)), c3: \(type(of: c3)), c4: \(type(of: c4)), c5: \(type(of: c5))")
        return TupleLayout([c0, c1, c2, c3, c4, c5], arrangement: .vertical)
    }
    
    /// Creates a layout from seven components.
    public static func buildBlock<C0: Layout, C1: Layout, C2: Layout, C3: Layout, C4: Layout, C5: Layout, C6: Layout>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6) -> TupleLayout {
        print("🔧 LayoutBuilder - buildBlock(7) - c0: \(type(of: c0)), c1: \(type(of: c1)), c2: \(type(of: c2)), c3: \(type(of: c3)), c4: \(type(of: c4)), c5: \(type(of: c5)), c6: \(type(of: c6))")
        return TupleLayout([c0, c1, c2, c3, c4, c5, c6], arrangement: .vertical)
    }
    
    /// Creates a layout from eight components.
    public static func buildBlock<C0: Layout, C1: Layout, C2: Layout, C3: Layout, C4: Layout, C5: Layout, C6: Layout, C7: Layout>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7) -> TupleLayout {
        print("🔧 LayoutBuilder - buildBlock(8) - c0: \(type(of: c0)), c1: \(type(of: c1)), c2: \(type(of: c2)), c3: \(type(of: c3)), c4: \(type(of: c4)), c5: \(type(of: c5)), c6: \(type(of: c6)), c7: \(type(of: c7))")
        return TupleLayout([c0, c1, c2, c3, c4, c5, c6, c7], arrangement: .vertical)
    }
    
    /// Creates a layout from nine components.
    public static func buildBlock<C0: Layout, C1: Layout, C2: Layout, C3: Layout, C4: Layout, C5: Layout, C6: Layout, C7: Layout, C8: Layout>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8) -> TupleLayout {
        print("🔧 LayoutBuilder - buildBlock(9) - c0: \(type(of: c0)), c1: \(type(of: c1)), c2: \(type(of: c2)), c3: \(type(of: c3)), c4: \(type(of: c4)), c5: \(type(of: c5)), c6: \(type(of: c6)), c7: \(type(of: c7)), c8: \(type(of: c8))")
        return TupleLayout([c0, c1, c2, c3, c4, c5, c6, c7, c8], arrangement: .vertical)
    }
    
    /// Creates a layout from ten components.
    public static func buildBlock<C0: Layout, C1: Layout, C2: Layout, C3: Layout, C4: Layout, C5: Layout, C6: Layout, C7: Layout, C8: Layout, C9: Layout>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9) -> TupleLayout {
        print("🔧 LayoutBuilder - buildBlock(10) - c0: \(type(of: c0)), c1: \(type(of: c1)), c2: \(type(of: c2)), c3: \(type(of: c3)), c4: \(type(of: c4)), c5: \(type(of: c5)), c6: \(type(of: c6)), c7: \(type(of: c7)), c8: \(type(of: c8)), c9: \(type(of: c9))")
        return TupleLayout([c0, c1, c2, c3, c4, c5, c6, c7, c8, c9], arrangement: .vertical)
    }
    
    /// Handles optional layouts by unwrapping them.
    public static func buildOptional<C: Layout>(_ component: C?) -> C? {
        print("🔧 LayoutBuilder - buildOptional - component: \(component != nil ? "some" : "nil")")
        return component
    }
    
    /// Handles conditional layouts by providing the appropriate layout.
    public static func buildEither<C: Layout>(first: C) -> C {
        print("🔧 LayoutBuilder - buildEither(first) - component: \(type(of: first))")
        return first
    }
    
    /// Handles conditional layouts by providing the appropriate layout.
    public static func buildEither<C: Layout>(second: C) -> C {
        print("🔧 LayoutBuilder - buildEither(second) - component: \(type(of: second))")
        return second
    }
    
    /// Handles array-based layouts.
    public static func buildArray<C: Layout>(_ components: [C]) -> ArrayLayout<C> {
        print("🔧 LayoutBuilder - buildArray - components count: \(components.count)")
        return ArrayLayout(components)
    }
}
