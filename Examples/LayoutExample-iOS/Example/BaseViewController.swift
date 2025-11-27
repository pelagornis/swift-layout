import UIKit
import Layout

/// Base class that allows declarative layout DSL similar to SwiftUI.
open class BaseViewController: UIViewController {
    
    // MARK: - Core layout container
    let layoutContainer = LayoutContainer()
    
    // MARK: - Debug & Monitoring
    
    /// Enable layout debugging for this view controller
    open var enableLayoutDebugging: Bool = false {
        didSet {
            if enableLayoutDebugging {
                LayoutDebugger.shared.enableAll()
            } else {
                LayoutDebugger.shared.disableAll()
            }
        }
    }

    // MARK: - View lifecycle
    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        setupLayoutContainer()
        
        // Measure layout setup time
        LayoutPerformanceMonitor.measureLayout(name: "\(type(of: self)).setLayout") {
            setLayout()
        }
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutContainer.frame = view.bounds
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Log view hierarchy when debugging is enabled
        if enableLayoutDebugging {
            LayoutDebugger.shared.analyzeViewHierarchy(layoutContainer, title: "\(type(of: self)) Layout")
        }
    }

    // MARK: - Setup and update methods
    private func setupLayoutContainer() {
        view.addSubview(layoutContainer)
        layoutContainer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            layoutContainer.topAnchor.constraint(equalTo: view.topAnchor),
            layoutContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            layoutContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            layoutContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// Renders the current layout DSL.
    func setLayout() {}

    /// Allows dynamic re-layout during runtime.
    public func reloadLayout(animated: Bool = false) {
        LayoutPerformanceMonitor.measureLayout(name: "\(type(of: self)).reloadLayout") {
            if animated {
                UIView.animate(withDuration: 0.25) {
                    self.setLayout()
                    self.view.layoutIfNeeded()
                }
            } else {
                setLayout()
            }
        }
    }
    
    // MARK: - Debug Helpers
    
    /// Print current layout performance summary
    public func printLayoutPerformanceSummary() {
        LayoutPerformanceMonitor.printSummary()
    }
    
    /// Analyze and print view hierarchy
    public func analyzeLayoutHierarchy() {
        LayoutDebugger.shared.isEnabled = true
        LayoutDebugger.shared.enableViewHierarchy = true
        LayoutDebugger.shared.analyzeViewHierarchy(layoutContainer, title: "\(type(of: self)) Layout")
    }
}
