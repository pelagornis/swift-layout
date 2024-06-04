import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum LayoutMacro {}

extension LayoutMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        if let inheritanceClause = declaration.inheritanceClause,
            inheritanceClause.inheritedTypes.contains(
                where: {
                    ["Layout"].withQualified.contains($0.type.trimmedDescription)
                }
            )
        {
            return []
        }

        let ext: DeclSyntax =
            """
            \(declaration.attributes.availability)extension \(type.trimmed): Layout {}
            """
        return [ext.cast(ExtensionDeclSyntax.self)]
    }
}

extension Array where Element == String {
    var withQualified: Self {
        self.flatMap { [$0, "Builder.\($0)"] }
    }
}