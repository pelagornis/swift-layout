import UIKit
import QuartzCore

/// Monitors frame rate during layout operations
@MainActor
public final class FrameRateMonitor {
    /// Shared instance
    public static let shared = FrameRateMonitor()
    
    /// Current frame rate
    private(set) public var currentFPS: Double = 60
    
    /// Frame rate history
    private var fpsHistory: [Double] = []
    
    /// Maximum history size
    public var maxHistorySize: Int = 60
    
    /// Display link for monitoring
    private var displayLink: CADisplayLink?
    
    /// Last timestamp
    private var lastTimestamp: CFTimeInterval = 0
    
    /// Whether monitoring is active
    public var isMonitoring: Bool {
        return displayLink != nil
    }
    
    private init() {}
    
    /// Starts monitoring
    public func start() {
        guard displayLink == nil else { return }
        
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkFired))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    /// Stops monitoring
    public func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func displayLinkFired(_ link: CADisplayLink) {
        if lastTimestamp > 0 {
            let delta = link.timestamp - lastTimestamp
            let fps = 1.0 / delta
            
            currentFPS = fps
            fpsHistory.append(fps)
            
            if fpsHistory.count > maxHistorySize {
                fpsHistory.removeFirst()
            }
        }
        
        lastTimestamp = link.timestamp
    }
    
    /// Gets the average FPS
    public var averageFPS: Double {
        guard !fpsHistory.isEmpty else { return 60 }
        return fpsHistory.reduce(0, +) / Double(fpsHistory.count)
    }
    
    /// Gets the minimum FPS recorded
    public var minFPS: Double {
        return fpsHistory.min() ?? 60
    }
    
    /// Clears the history
    public func clearHistory() {
        fpsHistory.removeAll()
    }
}

