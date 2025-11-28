import Foundation

/// Detailed performance profile for a layout operation
public struct PerformanceProfile: Sendable {
    /// Name of the profiled operation
    public let name: String
    
    /// Start time
    public let startTime: CFAbsoluteTime
    
    /// End time
    public let endTime: CFAbsoluteTime
    
    /// Duration in milliseconds
    public var duration: TimeInterval {
        return (endTime - startTime) * 1000
    }
    
    /// Memory usage before operation (bytes)
    public let memoryBefore: UInt64
    
    /// Memory usage after operation (bytes)
    public let memoryAfter: UInt64
    
    /// Memory delta (bytes)
    public var memoryDelta: Int64 {
        return Int64(memoryAfter) - Int64(memoryBefore)
    }
    
    /// Number of views involved
    public let viewCount: Int
    
    /// Number of layout calculations
    public let layoutCalculations: Int
    
    /// Child profiles (for nested operations)
    public let children: [PerformanceProfile]
    
    /// CPU usage percentage
    public let cpuUsage: Double
    
    public init(
        name: String,
        startTime: CFAbsoluteTime,
        endTime: CFAbsoluteTime,
        memoryBefore: UInt64,
        memoryAfter: UInt64,
        viewCount: Int,
        layoutCalculations: Int,
        children: [PerformanceProfile] = [],
        cpuUsage: Double = 0
    ) {
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.memoryBefore = memoryBefore
        self.memoryAfter = memoryAfter
        self.viewCount = viewCount
        self.layoutCalculations = layoutCalculations
        self.children = children
        self.cpuUsage = cpuUsage
    }
}

