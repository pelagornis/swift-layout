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
        return component
    }
    
    /// Creates a layout from two components.
    public static func buildBlock<C0: Layout, C1: Layout>(_ c0: C0, _ c1: C1) -> TupleLayout {
        return TupleLayout([c0, c1])
    }
    
    /// Creates a layout from three components.
    public static func buildBlock<C0: Layout, C1: Layout, C2: Layout>(_ c0: C0, _ c1: C1, _ c2: C2) -> TupleLayout {
        return TupleLayout([c0, c1, c2])
    }
    
    /// Creates a layout from four components.
    public static func buildBlock<C0: Layout, C1: Layout, C2: Layout, C3: Layout>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3) -> TupleLayout {
        return TupleLayout([c0, c1, c2, c3])
    }
    
    /// Creates a layout from five components.
    public static func buildBlock<C0: Layout, C1: Layout, C2: Layout, C3: Layout, C4: Layout>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4) -> TupleLayout {
        return TupleLayout([c0, c1, c2, c3, c4])
    }
    
    /// Creates a layout from six components.
    public static func buildBlock<C0: Layout, C1: Layout, C2: Layout, C3: Layout, C4: Layout, C5: Layout>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5) -> TupleLayout {
        return TupleLayout([c0, c1, c2, c3, c4, c5])
    }
    
    /// Creates a layout from seven components.
    public static func buildBlock<C0: Layout, C1: Layout, C2: Layout, C3: Layout, C4: Layout, C5: Layout, C6: Layout>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6) -> TupleLayout {
        return TupleLayout([c0, c1, c2, c3, c4, c5, c6])
    }
    
    /// Creates a layout from eight components.
    public static func buildBlock<C0: Layout, C1: Layout, C2: Layout, C3: Layout, C4: Layout, C5: Layout, C6: Layout, C7: Layout>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7) -> TupleLayout {
        return TupleLayout([c0, c1, c2, c3, c4, c5, c6, c7])
    }
    
    /// Creates a layout from nine components.
    public static func buildBlock<C0: Layout, C1: Layout, C2: Layout, C3: Layout, C4: Layout, C5: Layout, C6: Layout, C7: Layout, C8: Layout>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8) -> TupleLayout {
        return TupleLayout([c0, c1, c2, c3, c4, c5, c6, c7, c8])
    }
    
    /// Creates a layout from ten components.
    public static func buildBlock<C0: Layout, C1: Layout, C2: Layout, C3: Layout, C4: Layout, C5: Layout, C6: Layout, C7: Layout, C8: Layout, C9: Layout>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9) -> TupleLayout {
        return TupleLayout([c0, c1, c2, c3, c4, c5, c6, c7, c8, c9])
    }
    
    /// Handles optional layouts by unwrapping them.
    public static func buildOptional<C: Layout>(_ component: C?) -> C? {
        return component
    }
    
    /// Handles conditional layouts by providing the appropriate layout.
    public static func buildEither<C: Layout>(first: C) -> C {
        return first
    }
    
    /// Handles conditional layouts by providing the appropriate layout.
    public static func buildEither<C: Layout>(second: C) -> C {
        return second
    }
    
    /// Handles array-based layouts.
    public static func buildArray<C: Layout>(_ components: [C]) -> ArrayLayout<C> {
        return ArrayLayout(components)
    }
}
