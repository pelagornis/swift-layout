import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

/// Layout Macro's Compiler plugin
@main
struct LayoutMacroPlugin: CompilerPlugin {
    var providingMacros: [Macro.Type] = [
        LayoutMacro.self
    ]
}