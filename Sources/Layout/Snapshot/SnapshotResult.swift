#if canImport(UIKit)
import UIKit

#endif
/// Result of a snapshot comparison
public struct SnapshotResult {
    public let matched: Bool
    public let difference: CGFloat
    public let diffImage: UIImage?
    public let actualImage: UIImage
    public let expectedImage: UIImage?
    
    public init(
        matched: Bool,
        difference: CGFloat,
        diffImage: UIImage? = nil,
        actualImage: UIImage,
        expectedImage: UIImage? = nil
    ) {
        self.matched = matched
        self.difference = difference
        self.diffImage = diffImage
        self.actualImage = actualImage
        self.expectedImage = expectedImage
    }
}

