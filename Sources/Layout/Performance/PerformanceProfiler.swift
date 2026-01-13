import Foundation
import QuartzCore

/// Profiling context for tracking operations
private struct ProfilingContext {
    let id: UUID = UUID()
    let name: String
    let startTime: CFAbsoluteTime
    let memoryBefore: UInt64
    var children: [PerformanceProfile] = []
}

/// Advanced performance profiler for layout operations
@MainActor
public final class PerformanceProfiler {
    /// Shared instance
    public static let shared = PerformanceProfiler()
    
    /// Whether profiling is enabled
    public var isEnabled: Bool = true
    
    /// Performance thresholds
    public var thresholds: PerformanceThreshold = .default
    
    /// Collected profiles
    private var profiles: [PerformanceProfile] = []
    
    /// Generated warnings
    private var warnings: [PerformanceWarning] = []
    
    /// Current profiling stack
    private var profilingStack: [ProfilingContext] = []
    
    /// Layout calculation counter
    private var layoutCalculationCount: Int = 0
    
    /// Warning handlers
    private var warningHandlers: [(PerformanceWarning) -> Void] = []
    
    private init() {}
    
    /// Begins profiling an operation
    public func beginProfiling(_ name: String) -> ProfilingToken {
        guard isEnabled else {
            return ProfilingToken(id: UUID(), profiler: self)
        }
        
        let context = ProfilingContext(
            name: name,
            startTime: CFAbsoluteTimeGetCurrent(),
            memoryBefore: currentMemoryUsage()
        )
        profilingStack.append(context)
        
        return ProfilingToken(id: context.id, profiler: self)
    }
    
    /// Ends profiling an operation
    public func endProfiling(_ token: ProfilingToken, viewCount: Int = 0) {
        guard isEnabled else { return }
        
        guard let index = profilingStack.firstIndex(where: { $0.id == token.id }) else {
            return
        }
        
        let context = profilingStack.remove(at: index)
        let endTime = CFAbsoluteTimeGetCurrent()
        let memoryAfter = currentMemoryUsage()
        
        let profile = PerformanceProfile(
            name: context.name,
            startTime: context.startTime,
            endTime: endTime,
            memoryBefore: context.memoryBefore,
            memoryAfter: memoryAfter,
            viewCount: viewCount,
            layoutCalculations: layoutCalculationCount,
            children: context.children,
            cpuUsage: currentCPUUsage()
        )
        
        if var parent = profilingStack.last {
            parent.children.append(profile)
            profilingStack[profilingStack.count - 1] = parent
        } else {
            profiles.append(profile)
        }
        
        checkThresholds(profile)
        layoutCalculationCount = 0
    }
    
    /// Records a layout calculation
    public func recordLayoutCalculation() {
        guard isEnabled else { return }
        layoutCalculationCount += 1
    }
    
    /// Profiles an operation
    @discardableResult
    public func profile<T>(_ name: String, viewCount: Int = 0, operation: () -> T) -> T {
        let token = beginProfiling(name)
        let result = operation()
        endProfiling(token, viewCount: viewCount)
        return result
    }
    
    /// Adds a warning handler
    public func onWarning(_ handler: @escaping (PerformanceWarning) -> Void) {
        warningHandlers.append(handler)
    }
    
    /// Gets all collected profiles
    public var allProfiles: [PerformanceProfile] {
        return profiles
    }
    
    /// Gets all generated warnings
    public var allWarnings: [PerformanceWarning] {
        return warnings
    }
    
    /// Clears all profiles and warnings
    public func clear() {
        profiles.removeAll()
        warnings.removeAll()
    }
    
    /// Generates a performance report
    public func generateReport() -> PerformanceReport {
        return PerformanceReport(
            profiles: profiles,
            warnings: warnings,
            generatedAt: Date()
        )
    }
    
    /// Prints a summary
    public func printSummary() {
        print("🔬 Performance Profiler Summary")
        print("================================")
        
        if profiles.isEmpty {
            print("No profiles collected")
            return
        }
        
        for profile in profiles {
            printProfile(profile, indent: 0)
        }
        
        if !warnings.isEmpty {
            print("\n⚠️ Warnings (\(warnings.count)):")
            for warning in warnings {
                print("  - \(warning.description)")
            }
        }
        
        print("================================")
    }
    
    private func printProfile(_ profile: PerformanceProfile, indent: Int) {
        let indentString = String(repeating: "  ", count: indent)
        print("\(indentString)📊 \(profile.name):")
        print("\(indentString)   Duration: \(String(format: "%.2f", profile.duration))ms")
        print("\(indentString)   Memory: \(formatBytes(profile.memoryDelta))")
        print("\(indentString)   Views: \(profile.viewCount)")
        print("\(indentString)   Calculations: \(profile.layoutCalculations)")
        
        for child in profile.children {
            printProfile(child, indent: indent + 1)
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .memory
        formatter.includesUnit = true
        return formatter.string(fromByteCount: bytes)
    }
    
    private func checkThresholds(_ profile: PerformanceProfile) {
        if profile.duration > thresholds.maxLayoutTime {
            let warning = PerformanceWarning(
                type: .slowLayout(actual: profile.duration, threshold: thresholds.maxLayoutTime),
                operationName: profile.name,
                timestamp: Date()
            )
            addWarning(warning)
        }
        
        if profile.memoryDelta > thresholds.maxMemoryIncrease {
            let warning = PerformanceWarning(
                type: .highMemoryUsage(delta: profile.memoryDelta, threshold: thresholds.maxMemoryIncrease),
                operationName: profile.name,
                timestamp: Date()
            )
            addWarning(warning)
        }
        
        if profile.viewCount > thresholds.maxViewCount {
            let warning = PerformanceWarning(
                type: .tooManyViews(count: profile.viewCount, threshold: thresholds.maxViewCount),
                operationName: profile.name,
                timestamp: Date()
            )
            addWarning(warning)
        }
        
        if profile.layoutCalculations > thresholds.maxLayoutCalculations {
            let warning = PerformanceWarning(
                type: .excessiveLayoutCalculations(count: profile.layoutCalculations, threshold: thresholds.maxLayoutCalculations),
                operationName: profile.name,
                timestamp: Date()
            )
            addWarning(warning)
        }
    }
    
    private func addWarning(_ warning: PerformanceWarning) {
        warnings.append(warning)
        for handler in warningHandlers {
            handler(warning)
        }
    }
    
    private func currentMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        return result == KERN_SUCCESS ? info.resident_size : 0
    }
    
    private func currentCPUUsage() -> Double {
        var threadList: thread_act_array_t?
        var threadCount = mach_msg_type_number_t()
        
        guard task_threads(mach_task_self_, &threadList, &threadCount) == KERN_SUCCESS,
              let threads = threadList else {
            return 0
        }
        
        var totalUsage: Double = 0
        
        for i in 0..<Int(threadCount) {
            var info = thread_basic_info()
            var count = mach_msg_type_number_t(MemoryLayout<thread_basic_info>.size / MemoryLayout<natural_t>.size)
            
            let result = withUnsafeMutablePointer(to: &info) {
                $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                    thread_info(threads[i], thread_flavor_t(THREAD_BASIC_INFO), $0, &count)
                }
            }
            
            if result == KERN_SUCCESS && (info.flags & TH_FLAGS_IDLE) == 0 {
                totalUsage += Double(info.cpu_usage) / Double(TH_USAGE_SCALE)
            }
        }
        
        vm_deallocate(mach_task_self_, vm_address_t(bitPattern: threads), vm_size_t(Int(threadCount) * MemoryLayout<thread_t>.stride))
        
        return totalUsage * 100
    }
}

// MARK: - Layout Extension

extension Layout {
    /// Profiles the layout calculation
    @MainActor
    @discardableResult
    public func profiled(_ name: String) -> Self {
        PerformanceProfiler.shared.recordLayoutCalculation()
        return self
    }
}

