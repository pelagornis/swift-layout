import UIKit

/// Renders layout results to the UIView hierarchy
///
/// `LayoutRenderer` is responsible for applying placement results to the actual
/// UIView hierarchy. It handles:
/// - Frame application with or without animation
/// - View hierarchy updates
/// - Animation coordination with UIKit
///
/// ## Overview
///
/// The renderer separates rendering concerns from layout calculation, allowing
/// the layout engine to focus on measurement and placement while the renderer
/// handles the actual view updates.
///
/// ## Example
///
/// ```swift
/// let renderer = LayoutRenderer()
/// renderer.apply(
///     placement: result,
///     elements: elements,
///     transaction: transaction
/// )
/// ```
@MainActor
public class LayoutRenderer {
    /// Views currently being animated
    private var animatingViews: Set<UIView> = []
    
    /// Creates a new layout renderer
    public init() {}
    
    /// Applies placement result to the view hierarchy
    ///
    /// - Parameters:
    ///   - placement: The placement result with frames
    ///   - elements: Dictionary of elements by ID for view lookup
    ///   - transaction: Animation transaction (if any)
    public func apply(
        placement: PlacementResult,
        elements: [LayoutID: LayoutElement],
        transaction: LayoutAnimationTransaction?
    ) {
        let shouldAnimate = transaction != nil && transaction?.isActive == true
        
        for (id, frame) in placement.frames {
            guard let element = elements[id],
                  let view = element.view else {
                continue
            }
            
            // Skip if view is already animating (unless we have a transaction)
            if animatingViews.contains(view) && !shouldAnimate {
                continue
            }
            
            // Apply frame with or without animation
            if let animation = transaction?.animation, shouldAnimate {
                startAnimating(view)
                
                UIView.animate(
                    withDuration: animation.duration,
                    delay: animation.delay,
                    options: animation.timingFunction.animationOptions,
                    animations: {
                        view.frame = frame
                    },
                    completion: { [weak self] _ in
                        self?.stopAnimating(view)
                    }
                )
            } else {
                view.frame = frame
            }
        }
    }
    
    /// Marks a view as animating
    ///
    /// - Parameter view: The view to mark
    private func startAnimating(_ view: UIView) {
        animatingViews.insert(view)
    }
    
    /// Stops animating a view
    ///
    /// - Parameter view: The view to stop animating
    private func stopAnimating(_ view: UIView) {
        animatingViews.remove(view)
    }
    
    /// Clears all animating views
    public func clearAnimatingViews() {
        animatingViews.removeAll()
    }
}
