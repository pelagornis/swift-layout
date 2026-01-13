#if canImport(UIKit)
import UIKit

#endif
/// Adapter that bridges the old `Layout` protocol to the new `NewLayoutNode` protocol
///
/// This adapter allows existing `Layout` implementations to work with the new
/// layout system while maintaining backward compatibility.
///
/// ## Overview
///
/// The adapter:
/// 1. Converts `SizeProposal` to `CGRect` for `calculateLayout(in:)`
/// 2. Extracts views from `LayoutResult` for placement
/// 3. Handles identity mapping from `extractViews()`
///
/// ## Example
///
/// ```swift
/// let oldLayout = VStack { ... }
/// let adapter = LayoutAdapter(layout: oldLayout, id: "vstack")
/// let measured = adapter.measure(.atMost(width: 300, height: nil))
/// ```
@MainActor
public struct LayoutAdapter: NewLayoutNode {
    public let id: LayoutID
    
    private let layout: any Layout
    
    /// Creates an adapter for an existing Layout
    ///
    /// - Parameters:
    ///   - layout: The existing Layout to adapt
    ///   - id: Unique identifier for this adapter
    public init(layout: any Layout, id: LayoutID) {
        self.layout = layout
        self.id = id
    }
    
    public func measure(_ proposal: SizeProposal) -> MeasuredSize {
        // Convert SizeProposal to CGRect bounds
        let bounds: CGRect
        if let maxSize = proposal.maxSize {
            bounds = CGRect(origin: .zero, size: maxSize)
        } else {
            // Unspecified - use a large bounds
            bounds = CGRect(origin: .zero, size: CGSize(width: 10000, height: 10000))
        }
        
        // Call existing calculateLayout
        let result = layout.calculateLayout(in: bounds)
        
        // Extract size from result
        let size = result.totalSize
        
        // Create cache key from layout's content
        let cacheKey = hashLayout()
        
        return MeasuredSize(
            size: size,
            baselineOffset: nil,
            cacheKey: cacheKey
        )
    }
    
    public func place(
        at origin: CGPoint,
        size: CGSize,
        measuredSizes: [LayoutID: MeasuredSize]
    ) -> PlacementResult {
        // Calculate layout in the allocated size
        let bounds = CGRect(origin: origin, size: size)
        let result = layout.calculateLayout(in: bounds)
        
        // Convert UIView frames to LayoutID frames
        // For now, we use ObjectIdentifier of views as IDs
        var frames: [LayoutID: CGRect] = [:]
        for (view, frame) in result.frames {
            // Try to use layoutIdentity if available, otherwise use ObjectIdentifier
            if let identity = view.layoutIdentity {
                frames[identity] = frame
            } else {
                frames[AnyHashable(ObjectIdentifier(view))] = frame
            }
        }
        
        return PlacementResult(
            frames: frames,
            totalSize: result.totalSize,
            preferences: [:]
        )
    }
    
    public func invalidate(_ reason: LayoutInvalidationReason) {
        // For now, we can't do much with the old Layout protocol
        // The layout will be recalculated on next measure/place
    }
    
    public func collectPreferences() -> [ObjectIdentifier: Any] {
        // Old Layout protocol doesn't support preferences
        return [:]
    }
    
    /// Extracts views from the underlying layout
    public func extractViews() -> [UIView] {
        return layout.extractViews()
    }
    
    /// Hashes the layout for cache invalidation
    private func hashLayout() -> Int {
        // Simple hash based on views
        let views = layout.extractViews()
        var hasher = Hasher()
        hasher.combine(views.count)
        for view in views {
            hasher.combine(ObjectIdentifier(view))
        }
        return hasher.finalize()
    }
    
    /// Converts a `Layout` to a `LayoutElement`
    ///
    /// This is a convenience method that creates a LayoutAdapter and wraps it
    /// in a LayoutElement for use with the new layout system.
    ///
    /// - Parameters:
    ///   - layout: The layout to convert
    ///   - id: Unique identifier for this element (defaults to UUID)
    ///   - environment: Environment values for this element
    /// - Returns: A `LayoutElement` representing the layout
    public static func toElement(
        _ layout: any Layout,
        id: LayoutID = AnyHashable(UUID()),
        environment: EnvironmentValues = EnvironmentValues()
    ) -> LayoutElement {
        let adapter = LayoutAdapter(layout: layout, id: id)
        let views = layout.extractViews()
        let view = views.first // For now, use first view (simplified)
        
        return LayoutElement(
            id: id,
            node: adapter,
            children: [],
            view: view,
            environment: environment
        )
    }
}
