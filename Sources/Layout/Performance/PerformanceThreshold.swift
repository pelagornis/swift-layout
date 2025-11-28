import Foundation

/// Thresholds for performance warnings
public struct PerformanceThreshold: Sendable {
    /// Maximum acceptable layout time (ms)
    public var maxLayoutTime: TimeInterval = 16.67 // 60 FPS target
    
    /// Maximum acceptable memory increase (bytes)
    public var maxMemoryIncrease: Int64 = 1024 * 1024 // 1 MB
    
    /// Maximum acceptable view count
    public var maxViewCount: Int = 100
    
    /// Maximum acceptable layout calculations
    public var maxLayoutCalculations: Int = 50
    
    public init() {}
    
    public static let `default` = PerformanceThreshold()
    public static let strict = PerformanceThreshold(
        maxLayoutTime: 8,
        maxMemoryIncrease: 512 * 1024,
        maxViewCount: 50,
        maxLayoutCalculations: 25
    )
    
    public init(
        maxLayoutTime: TimeInterval = 16.67,
        maxMemoryIncrease: Int64 = 1024 * 1024,
        maxViewCount: Int = 100,
        maxLayoutCalculations: Int = 50
    ) {
        self.maxLayoutTime = maxLayoutTime
        self.maxMemoryIncrease = maxMemoryIncrease
        self.maxViewCount = maxViewCount
        self.maxLayoutCalculations = maxLayoutCalculations
    }
}

