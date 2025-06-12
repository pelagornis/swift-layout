#if canImport(UIKit)
import UIKit
#endif

/// SwiftUI-style result builder for declarative layout syntax
@resultBuilder
public struct LayoutBuilder {
    public static func buildBlock() -> EmptyLayout {
        return EmptyLayout()
    }
    
    public static func buildBlock<Content: Layout>(_ content: Content) -> Content {
        return content
    }
    
    public static func buildBlock<C0: Layout, C1: Layout>(_ c0: C0, _ c1: C1) -> TupleLayout {
        return TupleLayout([c0, c1])
    }
    
    public static func buildBlock<C0: Layout, C1: Layout, C2: Layout>(_ c0: C0, _ c1: C1, _ c2: C2) -> TupleLayout {
        return TupleLayout([c0, c1, c2])
    }
    
    public static func buildBlock<C0: Layout, C1: Layout, C2: Layout, C3: Layout>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3) -> TupleLayout {
        return TupleLayout([c0, c1, c2, c3])
    }
    
    public static func buildBlock<C0: Layout, C1: Layout, C2: Layout, C3: Layout, C4: Layout>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4) -> TupleLayout {
        return TupleLayout([c0, c1, c2, c3, c4])
    }
    
    public static func buildOptional<Content: Layout>(_ component: Content?) -> OptionalLayout<Content> {
        return OptionalLayout(component)
    }
    
    public static func buildEither<TrueContent: Layout, FalseContent: Layout>(first component: TrueContent) -> ConditionalLayout<TrueContent, FalseContent> {
        return ConditionalLayout.first(component)
    }
    
    public static func buildEither<TrueContent: Layout, FalseContent: Layout>(second component: FalseContent) -> ConditionalLayout<TrueContent, FalseContent> {
        return ConditionalLayout.second(component)
    }
    
    public static func buildArray<Content: Layout>(_ components: [Content]) -> ArrayLayout<Content> {
        return ArrayLayout(components)
    }
    
    public static func buildExpression<Content: Layout>(_ expression: Content) -> Content {
        return expression
    }
}
