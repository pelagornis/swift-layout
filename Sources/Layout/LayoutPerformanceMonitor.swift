import UIKit
/// Utility for measuring and monitoring layout performance.
///
/// ``LayoutPerformanceMonitor`` provides tools for measuring the performance
/// of layout calculations and identifying bottlenecks in complex layouts.
///
/// ## Example Usage
///
/// ```swift
/// LayoutPerformanceMonitor.measureLayout(name: "Complex Layout") {
///     layoutContainer.layoutSubviews()
/// }
/// ```
public enum LayoutPerformanceMonitor {
    /// Measures the execution time of a layout operation.
    ///
    /// This method executes the provided operation and prints the execution time
    /// to the console for performance monitoring.
    ///
    /// - Parameters:
    ///   - name: A descriptive name for the layout operation
    ///   - operation: The layout operation to measure
    /// - Returns: The result of the operation
    public static func measureLayout<T>(name: String, operation: () -> T) -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = operation()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("🔧 Layout '\(name)' took \(String(format: "%.2f", timeElapsed * 1000))ms")
        return result
    }
}
