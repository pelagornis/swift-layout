import Foundation

@resultBuilder
public struct LayoutBuilder {
    public static func buildBlock(_ components: ViewLayout...) -> [ViewLayout] {
        components
    }
    public static func buildArray(_ components: [[ViewLayout]]) -> [ViewLayout] {
        components.flatMap({ $0 })
    }
    public static func buildEither(first component: [ViewLayout]) -> [ViewLayout] {
        component
    }
    public static func buildEither(second component: [ViewLayout]) -> [ViewLayout] {
        component
    }
    public static func buildOptional(_ component: [ViewLayout]?) -> [ViewLayout] {
        component ?? []
    }
}
