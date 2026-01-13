#if canImport(UIKit)
import UIKit

#endif
/// Contains the result of a layout calculation, including view frames and total size.
///
/// ``LayoutResult`` encapsulates both the calculated frames for individual views
/// and the total size required by the layout. It provides methods to apply
/// the calculated layout to a container view.
///
/// ## Overview
///
/// When a layout calculates its arrangement, it returns a `LayoutResult` that
/// contains all the information needed to position views in their final locations.
/// This includes the frame for each view and the total size required by the layout.
///
/// ## Key Properties
///
/// - **frames**: A dictionary mapping each view to its calculated frame
/// - **totalSize**: The total size required by the layout
///
/// ## Example Usage
///
/// ```swift
/// let result = layout.calculateLayout(in: bounds)
/// result.applying(to: containerView)
/// ```
public struct LayoutResult {
    /// Dictionary mapping UIViews to their calculated frames.
    ///
    /// Each key-value pair represents a view and its calculated position and size
    /// within the layout. The layout system uses this information to position
    /// views in their final locations.
    public let frames: [UIView: CGRect]
    
    /// Total size required by the layout.
    ///
    /// This represents the total space needed by the layout, including all
    /// child views and any spacing or padding. This is used to determine
    /// the container size and for layout calculations.
    public let totalSize: CGSize
    
    /// Creates a new layout result.
    ///
    /// - Parameters:
    ///   - frames: Dictionary mapping views to their calculated frames
    ///   - totalSize: Total size required by the layout
    ///
    /// ## Example
    ///
    /// ```swift
    /// let result = LayoutResult(
    ///     frames: [view1: CGRect(x: 0, y: 0, width: 100, height: 50)],
    ///     totalSize: CGSize(width: 100, height: 50)
    /// )
    /// ```
    public init(frames: [UIView: CGRect] = [:], totalSize: CGSize = .zero) {
        self.frames = frames
        self.totalSize = totalSize
    }
    
    /// Applies the calculated frames to their corresponding views.
    ///
    /// This method iterates through all view-frame pairs and sets each view's frame
    /// to its calculated position and size. This is typically called after a layout
    /// calculation to update the visual positions of all views.
    ///
    /// - Parameter container: The container view (used for context, frames are applied to individual views)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let result = layout.calculateLayout(in: bounds)
    /// result.applying(to: containerView)
    /// ```
    @MainActor
    public func applying(to container: UIView) {
        frames.forEach { view, frame in
            view.frame = frame
        }
    }
}
