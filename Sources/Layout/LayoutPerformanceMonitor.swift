import Foundation

/// Performance monitoring for layout calculations
///
/// ``LayoutPerformanceMonitor`` provides tools to measure and optimize
/// layout performance, similar to SwiftUI's performance monitoring.
///
/// ## Overview
///
/// `LayoutPerformanceMonitor` helps you identify performance bottlenecks
/// in your layout calculations by measuring execution time and collecting
/// statistics. It's particularly useful for optimizing complex layouts
/// and identifying slow layout operations.
///
/// ## Key Features
///
/// - **Time Measurement**: Measure execution time of layout operations
/// - **Statistics Collection**: Track min, max, average, and total times
/// - **Thread-Safe**: Concurrent access to performance data
/// - **Custom Logging**: Support for custom logging functions
/// - **Summary Reports**: Detailed performance summaries
///
/// ## Example Usage
///
/// ```swift
/// // Basic measurement
/// LayoutPerformanceMonitor.measureLayout(name: "Complex Layout") {
///     layoutContainer.layoutSubviews()
/// }
///
/// // With custom logging
/// LayoutPerformanceMonitor.measureLayout(
///     name: "Grid Layout",
///     operation: { grid.calculateLayout(in: bounds) },
///     logger: { name, duration in
///         print("\(name) took \(duration)ms")
///     }
/// )
///
/// // Print performance summary
/// LayoutPerformanceMonitor.printSummary()
/// ```
///
/// ## Topics
///
/// ### Measurement
/// - ``measureLayout(name:operation:)``
/// - ``measureLayout(name:operation:logger:)``
///
/// ### Statistics
/// - ``Statistics``
/// - ``PerformanceCollector``
/// - ``statistics(for:)``
///
/// ### Management
/// - ``record(_:duration:)``
/// - ``clearMeasurements()``
/// - ``printSummary()``
public struct LayoutPerformanceMonitor {
    
    /// Measures the time taken for a layout operation
    ///
    /// - Parameters:
    ///   - name: The name of the layout operation for identification
    ///   - operation: The layout operation to measure
    /// - Returns: The result of the operation
    @discardableResult
    public static func measureLayout<T>(name: String, operation: () -> T) -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = operation()
        let endTime = CFAbsoluteTimeGetCurrent()
        
        let duration = (endTime - startTime) * 1000 // Convert to milliseconds
        print("📊 [LayoutPerformance] \(name): \(String(format: "%.2f", duration))ms")
        
        // Record the measurement
        shared.record(name, duration: duration)
        
        return result
    }
    
    /// Measures the time taken for a layout operation with custom logging
    ///
    /// - Parameters:
    ///   - name: The name of the layout operation
    ///   - operation: The layout operation to measure
    ///   - logger: Custom logging function
    /// - Returns: The result of the operation
    @discardableResult
    public static func measureLayout<T>(name: String, operation: () -> T, logger: (String, TimeInterval) -> Void) -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = operation()
        let endTime = CFAbsoluteTimeGetCurrent()
        
        let duration = (endTime - startTime) * 1000 // Convert to milliseconds
        logger(name, duration)
        
        // Record the measurement
        shared.record(name, duration: duration)
        
        return result
    }
    
    /// Performance statistics for layout operations.
    ///
    /// Contains aggregated performance data for layout operations,
    /// including total operations, average time, and min/max times.
    public struct Statistics: Sendable {
        /// Total number of operations measured
        public let totalOperations: Int
        
        /// Average time per operation in milliseconds
        public let averageTime: TimeInterval
        
        /// Minimum time recorded in milliseconds
        public let minTime: TimeInterval
        
        /// Maximum time recorded in milliseconds
        public let maxTime: TimeInterval
        
        /// Total time for all operations in milliseconds
        public let totalTime: TimeInterval
        
        /// Creates performance statistics.
        ///
        /// - Parameters:
        ///   - totalOperations: Total number of operations measured
        ///   - averageTime: Average time per operation
        ///   - minTime: Minimum time recorded
        ///   - maxTime: Maximum time recorded
        ///   - totalTime: Total time for all operations
        public init(totalOperations: Int, averageTime: TimeInterval, minTime: TimeInterval, maxTime: TimeInterval, totalTime: TimeInterval) {
            self.totalOperations = totalOperations
            self.averageTime = averageTime
            self.minTime = minTime
            self.maxTime = maxTime
            self.totalTime = totalTime
        }
    }
    
    /// Thread-safe performance statistics collector.
    ///
    /// Collects and manages performance measurements for layout operations
    /// in a thread-safe manner. Provides methods to record measurements,
    /// retrieve statistics, and generate performance reports.
    public class PerformanceCollector: @unchecked Sendable {
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
                print("📊 [LayoutPerformance] Summary:")
                print("==================================================")
                
                for (name, times) in measurements {
                    let stats = Statistics(
                        totalOperations: times.count,
                        averageTime: times.reduce(0, +) / Double(times.count),
                        minTime: times.min() ?? 0,
                        maxTime: times.max() ?? 0,
                        totalTime: times.reduce(0, +)
                    )
                    
                    print("📋 \(name):")
                    print("   Operations: \(stats.totalOperations)")
                    print("   Average: \(String(format: "%.2f", stats.averageTime))ms")
                    print("   Min: \(String(format: "%.2f", stats.minTime))ms")
                    print("   Max: \(String(format: "%.2f", stats.maxTime))ms")
                    print("   Total: \(String(format: "%.2f", stats.totalTime))ms")
                    print("")
                }
                
                print("==================================================")
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
