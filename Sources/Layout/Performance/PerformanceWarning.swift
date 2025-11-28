import Foundation

/// Warning generated when performance thresholds are exceeded
public struct PerformanceWarning: Sendable {
    public enum WarningType: Sendable {
        case slowLayout(actual: TimeInterval, threshold: TimeInterval)
        case highMemoryUsage(delta: Int64, threshold: Int64)
        case tooManyViews(count: Int, threshold: Int)
        case excessiveLayoutCalculations(count: Int, threshold: Int)
    }
    
    public let type: WarningType
    public let operationName: String
    public let timestamp: Date
    
    public var description: String {
        switch type {
        case .slowLayout(let actual, let threshold):
            return "⚠️ Slow layout '\(operationName)': \(String(format: "%.2f", actual))ms (threshold: \(String(format: "%.2f", threshold))ms)"
        case .highMemoryUsage(let delta, let threshold):
            return "⚠️ High memory usage in '\(operationName)': \(formatBytes(delta)) (threshold: \(formatBytes(threshold)))"
        case .tooManyViews(let count, let threshold):
            return "⚠️ Too many views in '\(operationName)': \(count) (threshold: \(threshold))"
        case .excessiveLayoutCalculations(let count, let threshold):
            return "⚠️ Excessive layout calculations in '\(operationName)': \(count) (threshold: \(threshold))"
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: bytes)
    }
}

