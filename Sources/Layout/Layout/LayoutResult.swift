import UIKit

/// Contains the result of a layout calculation, including view frames and total size.
///
/// ``LayoutResult`` encapsulates both the calculated frames for individual views
/// and the total size required by the layout. It provides methods to apply
/// the calculated layout to a container view.
public struct LayoutResult {
    /// Dictionary mapping UIViews to their calculated frames
    public let frames: [UIView: CGRect]
    
    /// Total size required by the layout
    public let totalSize: CGSize
    
    /// Creates a new layout result.
    ///
    /// - Parameters:
    ///   - frames: Dictionary mapping views to their calculated frames
    ///   - totalSize: Total size required by the layout
    public init(frames: [UIView: CGRect] = [:], totalSize: CGSize = .zero) {
        self.frames = frames
        self.totalSize = totalSize
    }
    
    /// Applies the calculated frames to their corresponding views.
    ///
    /// This method iterates through all view-frame pairs and sets each view's frame
    /// to its calculated position and size.
    ///
    /// - Parameter container: The container view (used for context, frames are applied to individual views)
    public func applying(to container: UIView) {
        frames.forEach { view, frame in
            view.frame = frame
        }
    }
}