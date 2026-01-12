import UIKit

/// Engine that orchestrates the measurement and placement phases of layout
///
/// `LayoutEngine` is the core orchestrator for the new layout system. It separates
/// measurement (size calculation) from placement (position calculation), enabling
/// efficient caching and partial updates.
///
/// ## Overview
///
/// The layout engine performs two distinct phases:
/// 1. **Measurement Phase**: Calculate sizes for all elements given proposals
/// 2. **Placement Phase**: Position elements using cached measurements
///
/// This separation allows:
/// - Measurement results to be cached by proposal
/// - Placement to be recalculated without remeasuring
/// - Partial invalidation (only affected subtrees)
/// - Animation stability (frames aren't overwritten during animation)
///
/// ## Example
///
/// ```swift
/// let engine = LayoutEngine(root: rootElement)
/// engine.performLayout(in: bounds)
/// ```
@MainActor
public class LayoutEngine {
    /// Root element of the layout tree
    private var rootElement: LayoutElement
    
    /// Cache of measured sizes by element ID and proposal
    private var measuredSizesCache: [LayoutID: [SizeProposal: MeasuredSize]] = [:]
    
    /// Registry of all elements by ID for quick lookup
    private var elementRegistry: [LayoutID: LayoutElement] = [:]
    
    /// Current animation transaction (if any)
    private var currentTransaction: LayoutAnimationTransaction?
    
    /// Creates a new layout engine
    ///
    /// - Parameter root: The root layout element
    public init(root: LayoutElement) {
        self.rootElement = root
        buildRegistry(from: root)
    }
    
    /// Updates the root element
    ///
    /// - Parameter root: The new root element
    public func updateRoot(_ root: LayoutElement) {
        self.rootElement = root
        buildRegistry(from: root)
        // Invalidate all cached measurements
        invalidate(.children)
    }
    
    /// Invalidates cached measurements
    ///
    /// - Parameter reason: Reason for invalidation
    public func invalidate(_ reason: LayoutInvalidationReason) {
        switch reason {
        case .size, .content, .full:
            // Clear measurement cache
            measuredSizesCache.removeAll()
        case .children:
            // Clear cache and rebuild registry
            measuredSizesCache.removeAll()
            buildRegistry(from: rootElement)
        case .environment:
            // Environment changes might affect measurement, so clear cache
            measuredSizesCache.removeAll()
        }
    }
    
    /// Sets the current animation transaction
    ///
    /// - Parameter transaction: The animation transaction (nil to clear)
    public func setTransaction(_ transaction: LayoutAnimationTransaction?) {
        self.currentTransaction = transaction
    }
    
    /// Performs layout calculation in the given bounds
    ///
    /// This method performs both measurement and placement phases:
    /// 1. Measures all elements starting from root
    /// 2. Places all elements using cached measurements
    ///
    /// - Parameter bounds: The available bounds for layout
    /// - Returns: Placement result with frames for all views
    @discardableResult
    public func performLayout(in bounds: CGRect) -> PlacementResult {
        // Check for active transaction
        let transaction = LayoutAnimationTransaction.current ?? currentTransaction
        
        // MEASURE PHASE: Calculate sizes for all elements
        let proposal = SizeProposal.from(bounds: bounds)
        let rootMeasured = measureElement(rootElement, proposal: proposal)
        
        // Store root measurement
        measuredSizesCache[rootElement.id, default: [:]][proposal] = rootMeasured
        
        // PLACE PHASE: Position all elements using cached measurements
        let placement = placeElement(
            rootElement,
            at: bounds.origin,
            size: rootMeasured.size,
            measuredSizes: measuredSizesCache
        )
        
        return placement
    }
    
    /// Measures an element and its children recursively
    ///
    /// - Parameters:
    ///   - element: The element to measure
    ///   - proposal: Size proposal from parent
    /// - Returns: Measured size for this element
    private func measureElement(_ element: LayoutElement, proposal: SizeProposal) -> MeasuredSize {
        // Check cache first
        if let cached = measuredSizesCache[element.id]?[proposal] {
            return cached
        }
        
        // Measure this element
        let measured = element.measure(proposal)
        
        // Cache the result
        measuredSizesCache[element.id, default: [:]][proposal] = measured
        
        // Recursively measure children
        for child in element.children {
            _ = measureElement(child, proposal: proposal)
        }
        
        return measured
    }
    
    /// Places an element and its children recursively
    ///
    /// - Parameters:
    ///   - element: The element to place
    ///   - origin: Origin point for this element
    ///   - size: Size allocated to this element
    ///   - measuredSizes: Cached measurements for all elements
    /// - Returns: Placement result with frames
    private func placeElement(
        _ element: LayoutElement,
        at origin: CGPoint,
        size: CGSize,
        measuredSizes: [LayoutID: [SizeProposal: MeasuredSize]]
    ) -> PlacementResult {
        // Get measured size for this element (use first available proposal)
        let elementMeasured = measuredSizes[element.id]?.values.first ?? MeasuredSize.zero
        
        // Place this element's node
        let placement = element.node.place(
            at: origin,
            size: size,
            measuredSizes: flattenMeasuredSizes(measuredSizes)
        )
        
        // Recursively place children
        var allFrames = placement.frames
        var allPreferences = placement.preferences
        
        for child in element.children {
            // Get child's measured size
            let childMeasured = measuredSizes[child.id]?.values.first ?? MeasuredSize.zero
            
            // Find child's frame in placement result
            if let childFrame = placement.frames[child.id] {
                // Recursively place child
                let childPlacement = placeElement(
                    child,
                    at: childFrame.origin,
                    size: childFrame.size,
                    measuredSizes: measuredSizes
                )
                
                // Merge child's frames and preferences
                allFrames.merge(childPlacement.frames) { _, new in new }
                allPreferences.merge(childPlacement.preferences) { _, new in new }
            }
        }
        
        return PlacementResult(
            frames: allFrames,
            totalSize: placement.totalSize,
            preferences: allPreferences
        )
    }
    
    /// Flattens nested measured sizes dictionary to single-level by ID
    ///
    /// - Parameter measuredSizes: Nested dictionary of measured sizes
    /// - Returns: Flattened dictionary by LayoutID
    private func flattenMeasuredSizes(_ measuredSizes: [LayoutID: [SizeProposal: MeasuredSize]]) -> [LayoutID: MeasuredSize] {
        var flattened: [LayoutID: MeasuredSize] = [:]
        for (id, proposals) in measuredSizes {
            // Use first available measurement
            if let first = proposals.values.first {
                flattened[id] = first
            }
        }
        return flattened
    }
    
    /// Builds a registry of all elements by ID for quick lookup
    ///
    /// - Parameter element: Root element to start from
    private func buildRegistry(from element: LayoutElement) {
        elementRegistry[element.id] = element
        for child in element.children {
            buildRegistry(from: child)
        }
    }
    
    /// Gets an element by ID
    ///
    /// - Parameter id: The element ID
    /// - Returns: The element if found
    public func element(for id: LayoutID) -> LayoutElement? {
        return elementRegistry[id]
    }
}
