import UIKit
import Layout

/// Base class that allows declarative layout DSL similar to SwiftUI.
open class BaseViewController: UIViewController {
    
    // MARK: - Core layout container
    let layoutContainer = LayoutContainer()

    // MARK: - View lifecycle
    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        setupLayoutContainer()
        setLayout()
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutContainer.frame = view.bounds
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
