import Foundation

/// Complete performance report
public struct PerformanceReport {
    public let profiles: [PerformanceProfile]
    public let warnings: [PerformanceWarning]
    public let generatedAt: Date
    
    /// Total duration of all profiled operations
    public var totalDuration: TimeInterval {
        return profiles.reduce(0) { $0 + $1.duration }
    }
    
    /// Average duration
    public var averageDuration: TimeInterval {
        guard !profiles.isEmpty else { return 0 }
        return totalDuration / Double(profiles.count)
    }
    
    /// Exports the report as JSON
    public func exportJSON() -> Data? {
        let dict: [String: Any] = [
            "generatedAt": ISO8601DateFormatter().string(from: generatedAt),
            "totalDuration": totalDuration,
            "averageDuration": averageDuration,
            "profileCount": profiles.count,
            "warningCount": warnings.count
        ]
        return try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
    }
}

