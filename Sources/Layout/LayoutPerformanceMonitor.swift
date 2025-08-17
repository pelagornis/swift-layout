import UIKit
import Foundation

/// Performance monitoring for layout calculations
///
/// ``LayoutPerformanceMonitor`` provides tools to measure and optimize
/// layout performance, similar to SwiftUI's performance monitoring.
///
/// ## Example Usage
///
/// ```swift
/// LayoutPerformanceMonitor.measureLayout(name: "Complex Layout") {
///     layoutContainer.layoutSubviews()
/// }
/// ```
public struct LayoutPerformanceMonitor {
    
    /// Measures the time taken for a layout operation
    ///
    /// - Parameters:
    ///   - name: The name of the layout operation for identification
    ///   - operation: The layout operation to measure
    /// - Returns: The time taken in milliseconds
    @discardableResult
    public static func measureLayout<T>(name: String, operation: () -> T) -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = operation()
        let endTime = CFAbsoluteTimeGetCurrent()
        
        let duration = (endTime - startTime) * 1000 // Convert to milliseconds
        
        #if DEBUG
        #endif
        
        return result
    }
    
    /// Measures the time taken for a layout operation with custom logging
    ///
    /// - Parameters:
    ///   - name: The name of the layout operation
    ///   - operation: The layout operation to measure
    ///   - logger: Custom logging function
    /// - Returns: The time taken in milliseconds
    @discardableResult
    public static func measureLayout<T>(name: String, operation: () -> T, logger: (String, TimeInterval) -> Void) -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = operation()
        let endTime = CFAbsoluteTimeGetCurrent()
        
        let duration = endTime - startTime
        logger(name, duration)
        
        return result
    }
    
    /// Performance statistics for layout operations
    public struct Statistics {
        public let totalOperations: Int
        public let averageTime: TimeInterval
        public let minTime: TimeInterval
        public let maxTime: TimeInterval
        public let totalTime: TimeInterval
        
        public init(totalOperations: Int, averageTime: TimeInterval, minTime: TimeInterval, maxTime: TimeInterval, totalTime: TimeInterval) {
            self.totalOperations = totalOperations
            self.averageTime = averageTime
            self.minTime = minTime
            self.maxTime = maxTime
            self.totalTime = totalTime
        }
    }
    
    /// Thread-safe performance statistics collector
    public class PerformanceCollector {
        private var measurements: [String: [TimeInterval]] = [:]
        private let queue = DispatchQueue(label: "LayoutPerformanceMonitor", attributes: .concurrent)
        
        /// Records a measurement for a named operation
        public func record(_ name: String, duration: TimeInterval) {
            queue.async(flags: .barrier) {
                if self.measurements[name] == nil {
                    self.measurements[name] = []
                }
                self.measurements[name]?.append(duration)
            }
        }
        
        /// Gets statistics for a named operation
        public func statistics(for name: String) -> Statistics? {
            return queue.sync {
                guard let times = measurements[name], !times.isEmpty else { return nil }
                
                let totalOperations = times.count
                let totalTime = times.reduce(0, +)
                let averageTime = totalTime / Double(totalOperations)
                let minTime = times.min() ?? 0
                let maxTime = times.max() ?? 0
                
                return Statistics(
                    totalOperations: totalOperations,
                    averageTime: averageTime,
                    minTime: minTime,
                    maxTime: maxTime,
                    totalTime: totalTime
                )
            }
        }
        
        /// Clears all measurements
        public func clear() {
            queue.async(flags: .barrier) {
                self.measurements.removeAll()
            }
        }
        
        /// Prints a summary of all measurements
        public func printSummary() {
            queue.sync {
                for (name, times) in measurements {
                    let stats = Statistics(
                        totalOperations: times.count,
                        averageTime: times.reduce(0, +) / Double(times.count),
                        minTime: times.min() ?? 0,
                        maxTime: times.max() ?? 0,
                        totalTime: times.reduce(0, +)
                    )
                    
                    let summary = "\(name): Operations: \(stats.totalOperations), Average: \(String(format: "%.2f", stats.averageTime * 1000))ms, Min: \(String(format: "%.2f", stats.minTime * 1000))ms, Max: \(String(format: "%.2f", stats.maxTime * 1000))ms, Total: \(String(format: "%.2f", stats.totalTime * 1000))ms"
            
                }
            }
        }
    }
    
    /// Shared performance collector instance
    public static let shared = PerformanceCollector()
    
    /// Records a measurement using the shared collector
    public static func record(_ name: String, duration: TimeInterval) {
        shared.record(name, duration: duration)
    }
    
    /// Gets statistics for a named operation from the shared collector
    public static func statistics(for name: String) -> Statistics? {
        return shared.statistics(for: name)
    }
    
    /// Clears all measurements from the shared collector
    public static func clearMeasurements() {
        shared.clear()
    }
    
    /// Prints a summary of all measurements from the shared collector
    public static func printSummary() {
        shared.printSummary()
    }
}
