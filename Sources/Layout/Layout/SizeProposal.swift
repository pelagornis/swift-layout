import CoreGraphics
/// Size proposal for measurement (like SwiftUI's ProposedViewSize)
///
/// A `SizeProposal` represents constraints that a parent layout provides to its children
/// during the measurement phase. This allows children to understand what size the parent
/// expects or allows, enabling proper layout calculations.
///
/// ## Overview
///
/// Unlike the current `calculateLayout(in bounds: CGRect)` which only provides available
/// bounds, `SizeProposal` explicitly communicates the parent's intent:
/// - `.unspecified`: No constraints - child can choose any size
/// - `.fixed`: Fixed size - child must use exactly this size
/// - `.atMost`: Maximum size - child can be smaller but not larger
/// - `.atLeast`: Minimum size - child can be larger but not smaller
/// - `.range`: Range - child must be within this range
///
/// ## Example
///
/// ```swift
/// func measure(_ proposal: SizeProposal) -> MeasuredSize {
///     switch proposal {
///     case .unspecified:
///         // Use intrinsic content size
///         return MeasuredSize(size: intrinsicSize)
///     case .fixed(let size):
///         // Must use exactly this size
///         return MeasuredSize(size: size)
///     case .atMost(let maxSize):
///         // Can be smaller, but not larger
///         let size = min(intrinsicSize, maxSize)
///         return MeasuredSize(size: size)
///     case .atLeast(let minSize):
///         // Can be larger, but not smaller
///         let size = max(intrinsicSize, minSize)
///         return MeasuredSize(size: size)
///     case .range(let min, let max):
///         // Must be within range
///         let size = clamp(intrinsicSize, min: min, max: max)
///         return MeasuredSize(size: size)
///     }
/// }
/// ```
@MainActor
public enum SizeProposal: Equatable, Hashable {
    /// No constraints - child can choose any size
    case unspecified
    
    /// Fixed size - child must use exactly this size
    case fixed(CGSize)
    
    /// Maximum size - child can be smaller but not larger
    case atMost(CGSize)
    
    /// Minimum size - child can be larger but not smaller
    case atLeast(CGSize)
    
    /// Range - child must be within this range
    case range(min: CGSize, max: CGSize)
    
    /// Convenience initializer for fixed size
    public static func fixed(width: CGFloat, height: CGFloat) -> SizeProposal {
        .fixed(CGSize(width: width, height: height))
    }
    
    /// Convenience initializer for atMost size
    public static func atMost(width: CGFloat, height: CGFloat) -> SizeProposal {
        .atMost(CGSize(width: width, height: height))
    }
    
    /// Convenience initializer for atLeast size
    public static func atLeast(width: CGFloat, height: CGFloat) -> SizeProposal {
        .atLeast(CGSize(width: width, height: height))
    }
    
    /// Convenience initializer for range
    public static func range(
        minWidth: CGFloat, minHeight: CGFloat,
        maxWidth: CGFloat, maxHeight: CGFloat
    ) -> SizeProposal {
        .range(
            min: CGSize(width: minWidth, height: minHeight),
            max: CGSize(width: maxWidth, height: maxHeight)
        )
    }
    
    /// Converts a CGRect bounds to a SizeProposal
    /// - Parameter bounds: The bounds to convert
    /// - Returns: An `.atMost` proposal with the bounds size
    public static func from(bounds: CGRect) -> SizeProposal {
        .atMost(bounds.size)
    }
    
    /// Gets the maximum size allowed by this proposal
    /// Returns nil for `.unspecified`
    public var maxSize: CGSize? {
        switch self {
        case .unspecified:
            return nil
        case .fixed(let size):
            return size
        case .atMost(let size):
            return size
        case .atLeast:
            return nil
        case .range(_, let max):
            return max
        }
    }
    
    /// Gets the minimum size required by this proposal
    /// Returns nil for `.unspecified` or `.atMost`
    public var minSize: CGSize? {
        switch self {
        case .unspecified, .atMost:
            return nil
        case .fixed(let size):
            return size
        case .atLeast(let size):
            return size
        case .range(let min, _):
            return min
        }
    }
}

extension SizeProposal {
    /// Clamps a size to fit within this proposal
    /// - Parameter size: The size to clamp
    /// - Returns: The clamped size
    public func clamp(_ size: CGSize) -> CGSize {
        switch self {
        case .unspecified:
            return size
        case .fixed(let fixedSize):
            return fixedSize
        case .atMost(let maxSize):
            return CGSize(
                width: min(size.width, maxSize.width),
                height: min(size.height, maxSize.height)
            )
        case .atLeast(let minSize):
            return CGSize(
                width: max(size.width, minSize.width),
                height: max(size.height, minSize.height)
            )
        case .range(let minSize, let maxSize):
            return CGSize(
                width: max(minSize.width, min(size.width, maxSize.width)),
                height: max(minSize.height, min(size.height, maxSize.height))
            )
        }
    }
}
