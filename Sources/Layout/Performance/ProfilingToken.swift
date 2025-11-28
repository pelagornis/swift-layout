import Foundation

/// Token for ending a profiling session
@MainActor
public struct ProfilingToken {
    let id: UUID
    weak var profiler: PerformanceProfiler?
    
    /// Ends the profiling session
    public func end(viewCount: Int = 0) {
        profiler?.endProfiling(self, viewCount: viewCount)
    }
}

