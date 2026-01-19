import UIKit
import Foundation
/// A class that manages debug settings for the layout system
///
/// The ``LayoutDebugger`` provides selective debugging capabilities for the custom layout system.
/// You can enable or disable different categories of debug output to help troubleshoot layout issues.
///
/// ## Usage
///
/// ```swift
/// // Enable all debugging
/// LayoutDebugger.shared.enableAll()
///
/// // Enable only specific categories
/// LayoutDebugger.shared.isEnabled = true
/// LayoutDebugger.shared.enableViewHierarchy = true
/// LayoutDebugger.shared.enableSpacerCalculation = true
/// ```
@MainActor
public final class LayoutDebugger {
    
    /// Shared singleton instance
    public static let shared = LayoutDebugger()
    
    private init() {}
    
    // MARK: - Debug Flags
    
    /// Master switch for enabling/disabling all debug output
    public var isEnabled: Bool = false
    
    /// Enable debug output for layout calculations
    public var enableLayoutCalculation: Bool = false
    
    /// Enable debug output for view hierarchy analysis
    public var enableViewHierarchy: Bool = false
    
    /// Enable debug output for frame settings
    public var enableFrameSettings: Bool = false
    
    /// Enable debug output for spacer calculations
    public var enableSpacerCalculation: Bool = false
    
    /// Enable performance monitoring output
    public var enablePerformanceMonitoring: Bool = false
    
    // MARK: - Debug Methods
    
    /// Log layout calculation messages
    public func logLayoutCalculation(_ message: String, component: String = "") {
        guard isEnabled && enableLayoutCalculation else { return }
        if let hook = layoutCalculationHook {
            hook(message, component)
        } else {
            print("🔧 [\(component)] \(message)")
        }
    }
    
    /// Log view hierarchy messages
    public func logViewHierarchy(_ message: String, component: String = "") {
        guard isEnabled && enableViewHierarchy else { return }
        if let hook = viewHierarchyHook {
            hook(message, component)
        } else {
            print("🏗️ [\(component)] \(message)")
        }
    }
    
    /// Log frame setting messages
    public func logFrameSettings(_ message: String, component: String = "") {
        guard isEnabled && enableFrameSettings else { return }
        if let hook = frameSettingsHook {
            hook(message, component)
        } else {
            print("📐 [\(component)] \(message)")
        }
    }
    
    /// Log spacer calculation messages
    public func logSpacerCalculation(_ message: String, component: String = "") {
        guard isEnabled && enableSpacerCalculation else { return }
        print("🔲 [\(component)] \(message)")
    }
    
    /// Log performance monitoring messages
    public func logPerformance(_ message: String, component: String = "") {
        guard isEnabled && enablePerformanceMonitoring else { return }
        print("⚡ [\(component)] \(message)")
    }
    
    /// Analyze view hierarchy in tree format
    ///
    /// Prints a simple tree-style analysis of the view hierarchy starting from the given container.
    ///
    /// - Parameters:
    ///   - container: The root view to analyze
    ///   - title: A custom title for the analysis output
    public func analyzeViewHierarchy(_ container: UIView, title: String = "VIEW HIERARCHY") {
        guard isEnabled && enableViewHierarchy else { return }
        
        print("🔍 ===== \(title) =====")
        analyzeView(container, depth: 0)
        print("🔍 ===== END \(title) =====")
    }
    
    private func analyzeView(_ view: UIView, depth: Int) {
        let indent = String(repeating: "  ", count: depth)
        let prefix = depth == 0 ? "🔍" : "🔍" + String(repeating: " ", count: depth * 2) + "└─"
        
        print("\(prefix) \(type(of: view))")
        print("\(indent)├─ Frame: \(view.frame)")
        print("\(indent)├─ Bounds: \(view.bounds)")
        print("\(indent)├─ Size: \(view.frame.size)")
        print("\(indent)├─ Background: \(view.backgroundColor?.description ?? "nil")")
        print("\(indent)├─ Hidden: \(view.isHidden)")
        print("\(indent)├─ Alpha: \(view.alpha)")
        print("\(indent)├─ UserInteraction: \(view.isUserInteractionEnabled)")
        print("\(indent)└─ IntrinsicSize: \(view.intrinsicContentSize)")

        
        // Analyze child views
        if !view.subviews.isEmpty {
            print("\(indent)└─ Subviews Count: \(view.subviews.count)")
            for (index, subview) in view.subviews.enumerated() {
                let isLast = index == view.subviews.count - 1
                let childPrefix = isLast ? "└─" : "├─"
                print("\(indent)  \(childPrefix) Child \(index): \(type(of: subview))")
                analyzeView(subview, depth: depth + 1)
            }
        }
    }
    
    // MARK: - Convenience Methods
    
    /// Enable all debug categories
    public func enableAll() {
        isEnabled = true
        enableLayoutCalculation = true
        enableViewHierarchy = true
        enableFrameSettings = true
        enableSpacerCalculation = true
        enablePerformanceMonitoring = true
    }
    
    /// Disable all debug categories
    public func disableAll() {
        isEnabled = false
        enableLayoutCalculation = false
        enableViewHierarchy = false
        enableFrameSettings = false
        enableSpacerCalculation = false
        enablePerformanceMonitoring = false
    }
    
    // MARK: - Debugging Hooks
    
    /// Custom hook for layout calculation debugging
    /// Set this to intercept and customize layout calculation logs
    public var layoutCalculationHook: ((String, String) -> Void)?
    
    /// Custom hook for view hierarchy debugging
    /// Set this to intercept and customize view hierarchy logs
    public var viewHierarchyHook: ((String, String) -> Void)?
    
    /// Custom hook for frame settings debugging
    /// Set this to intercept and customize frame setting logs
    public var frameSettingsHook: ((String, String) -> Void)?
    
    /// Sets a custom debugging hook
    /// - Parameters:
    ///   - hook: The hook closure that receives (message, component)
    ///   - category: The debug category to hook into
    public func setDebuggingHook(_ hook: @escaping (String, String) -> Void, for category: LayoutDebugCategory) {
        switch category {
        case .layout:
            layoutCalculationHook = hook
        case .hierarchy:
            viewHierarchyHook = hook
        case .frame:
            frameSettingsHook = hook
        case .spacer, .performance:
            // Not implemented yet
            break
        }
    }
    
    /// Enable only basic debugging (view hierarchy + frame settings)
    public func enableBasic() {
        isEnabled = true
        enableLayoutCalculation = false
        enableViewHierarchy = true
        enableFrameSettings = true
        enableSpacerCalculation = false
        enablePerformanceMonitoring = false
    }
    
    /// Enable only spacer-related debugging
    public func enableSpacerOnly() {
        isEnabled = true
        enableLayoutCalculation = false
        enableViewHierarchy = false
        enableFrameSettings = false
        enableSpacerCalculation = true
        enablePerformanceMonitoring = false
    }
}

// MARK: - Global Debug Functions (Convenience)

/// Global debug logging function
///
/// A convenience function that routes debug messages to the appropriate ``LayoutDebugger`` method
/// based on the specified category.
///
/// - Parameters:
///   - message: The debug message to log
///   - component: The component name (optional)
///   - category: The debug category for routing the message
@MainActor
public func debugLog(_ message: String, component: String = "", category: LayoutDebugCategory = .layout) {
    switch category {
    case .layout:
        LayoutDebugger.shared.logLayoutCalculation(message, component: component)
    case .hierarchy:
        LayoutDebugger.shared.logViewHierarchy(message, component: component)
    case .frame:
        LayoutDebugger.shared.logFrameSettings(message, component: component)
    case .spacer:
        LayoutDebugger.shared.logSpacerCalculation(message, component: component)
    case .performance:
        LayoutDebugger.shared.logPerformance(message, component: component)
    }
}

/// Debug category enumeration
///
/// Defines the different categories of debug output available in the layout system.
public enum LayoutDebugCategory: Sendable {
    /// Layout calculation debugging
    case layout
    /// View hierarchy debugging
    case hierarchy
    /// Frame setting debugging
    case frame
    /// Spacer calculation debugging
    case spacer
    /// Performance monitoring debugging
    case performance
}
