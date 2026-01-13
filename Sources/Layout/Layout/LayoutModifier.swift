import CoreGraphics
/// Protocol for modifiers that can transform view frames during layout calculation.
///
/// Layout modifiers are applied in sequence to transform a view's frame
/// based on the available bounds and other layout parameters.
///
/// ## Overview
///
/// `LayoutModifier` is the foundation for all layout transformations in the
/// ManualLayout system. Modifiers are applied in sequence to transform a view's
/// frame during layout calculation, providing a flexible and composable way
/// to customize view positioning and sizing.
///
/// ## Key Features
///
/// - **Frame Transformation**: Modifies view frames during layout calculation
/// - **Sequential Application**: Modifiers are applied in order
/// - **Bounds Awareness**: Access to available layout bounds
/// - **Composable**: Multiple modifiers can be combined
/// - **Type Safe**: Compile-time type checking for modifier combinations
///
/// ## Example Implementation
///
/// ```swift
/// struct CustomModifier: LayoutModifier {
///     let offset: CGPoint
///     
///     func apply(to frame: CGRect, in bounds: CGRect) -> CGRect {
///         return frame.offsetBy(dx: offset.x, dy: offset.y)
///     }
/// }
/// ```
///
/// ## Topics
///
/// ### Built-in Modifiers
/// - ``SizeModifier``
/// - ``PositionModifier``
/// - ``CenterModifier``
/// - ``OffsetModifier``
/// - ``PaddingModifier``
/// - ``BackgroundModifier``
/// - ``CornerRadiusModifier``
/// - ``AspectRatioModifier``
public protocol LayoutModifier: Sendable {
    /// Applies the modifier transformation to a frame within the given bounds.
    ///
    /// This method is called during layout calculation to transform a view's frame.
    /// The modifier should return a new frame that reflects the desired transformation.
    ///
    /// - Parameters:
    ///   - frame: The original frame to modify
    ///   - bounds: The available bounds for the layout
    /// - Returns: The modified frame
    func apply(to frame: CGRect, in bounds: CGRect) -> CGRect
}
