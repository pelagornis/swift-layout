#if canImport(BuilderMacros)
import LayoutMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

let testMacros: [String: Macro.Type] = [
    "Layout": LayoutMacro.self
]

#endif