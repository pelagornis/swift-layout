import Foundation
/// Unique identifier for a layout element
///
/// `LayoutID` is a type alias for `AnyHashable`, allowing any hashable type
/// to be used as a layout identity. This enables efficient diffing and view reuse.
///
/// ## Overview
///
/// Layout identities are used to:
/// - Track views across layout updates
/// - Reuse existing views when identity matches
/// - Efficiently update only changed views
/// - Enable stable animations
///
/// ## Example
///
/// ```swift
/// let element = LayoutElement(
///     id: AnyHashable("my-view"),
///     node: viewNode,
///     children: []
/// )
/// ```
public typealias LayoutID = AnyHashable
