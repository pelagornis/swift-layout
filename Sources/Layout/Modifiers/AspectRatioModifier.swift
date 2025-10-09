import UIKit

/// Modifier for maintaining aspect ratios.
///
/// Use ``AspectRatioModifier`` to ensure a view maintains a specific
/// width-to-height ratio using either fit or fill content modes.
public struct AspectRatioModifier: LayoutModifier {
    /// The desired aspect ratio (width / height)
    public let ratio: CGFloat
    
    /// How the aspect ratio should be applied
    public let contentMode: ContentMode
    
    /// Content mode for aspect ratio application
    public enum ContentMode: Sendable {
        /// Fit the view within the bounds while maintaining aspect ratio
        case fit
        /// Fill the bounds while maintaining aspect ratio (may clip)
        case fill
    }
    
    /// Creates an aspect ratio modifier.
    ///
    /// - Parameters:
    ///   - ratio: The desired aspect ratio (width / height)
    ///   - contentMode: How to apply the aspect ratio
    public init(ratio: CGFloat, contentMode: ContentMode) {
        self.ratio = ratio
        self.contentMode = contentMode
    }
    
    public func apply(to frame: CGRect, in bounds: CGRect) -> CGRect {
        var newFrame = frame
        
        switch contentMode {
        case .fit:
            let currentRatio = frame.width / frame.height
            if currentRatio > ratio {
                newFrame.size.width = frame.height * ratio
            } else {
                newFrame.size.height = frame.width / ratio
            }
        case .fill:
            let currentRatio = frame.width / frame.height
            if currentRatio > ratio {
                newFrame.size.height = frame.width / ratio
            } else {
                newFrame.size.width = frame.height * ratio
            }
        }
        
        return newFrame
    }
}
