import CoreGraphics
/// Calculates sizes based on priorities
@MainActor
public final class PrioritySizeCalculator {
    /// Calculates the distributed sizes for items with different priorities
    public static func calculateSizes(
        for items: [(minSize: CGFloat, maxSize: CGFloat, priority: LayoutPriority)],
        availableSpace: CGFloat,
        spacing: CGFloat
    ) -> [CGFloat] {
        guard !items.isEmpty else { return [] }
        
        let totalSpacing = spacing * CGFloat(items.count - 1)
        let availableForContent = availableSpace - totalSpacing
        
        let totalMinSize = items.reduce(0) { $0 + $1.minSize }
        let totalMaxSize = items.reduce(0) { $0 + $1.maxSize }
        
        if availableForContent <= totalMinSize {
            return items.map { item in
                let ratio = totalMinSize > 0 ? item.minSize / totalMinSize : 1.0 / CGFloat(items.count)
                return max(availableForContent * ratio, 0)
            }
        }
        
        if availableForContent >= totalMaxSize {
            let extraSpace = availableForContent - totalMaxSize
            return distributeExtraSpace(items: items, baseSpace: totalMaxSize, extraSpace: extraSpace)
        }
        
        return distributeSpace(items: items, availableSpace: availableForContent)
    }
    
    private static func distributeSpace(
        items: [(minSize: CGFloat, maxSize: CGFloat, priority: LayoutPriority)],
        availableSpace: CGFloat
    ) -> [CGFloat] {
        var sizes = items.map { $0.minSize }
        var remainingSpace = availableSpace - sizes.reduce(0, +)
        
        let sortedIndices = items.indices.sorted { items[$0].priority > items[$1].priority }
        
        for index in sortedIndices {
            guard remainingSpace > 0 else { break }
            
            let item = items[index]
            let maxGrow = item.maxSize - sizes[index]
            let grow = min(maxGrow, remainingSpace)
            
            sizes[index] += grow
            remainingSpace -= grow
        }
        
        return sizes
    }
    
    private static func distributeExtraSpace(
        items: [(minSize: CGFloat, maxSize: CGFloat, priority: LayoutPriority)],
        baseSpace: CGFloat,
        extraSpace: CGFloat
    ) -> [CGFloat] {
        var sizes = items.map { $0.maxSize }
        
        let maxPriority = items.max(by: { $0.priority < $1.priority })?.priority ?? .defaultLow
        let highPriorityIndices = items.indices.filter { items[$0].priority == maxPriority }
        
        if !highPriorityIndices.isEmpty {
            let extraPerItem = extraSpace / CGFloat(highPriorityIndices.count)
            for index in highPriorityIndices {
                sizes[index] += extraPerItem
            }
        }
        
        return sizes
    }
}
