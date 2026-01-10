import XCTest
import UIKit
@testable import Layout

@MainActor
final class AnimationTests: XCTestCase {
    
    var testView: UIView!
    var layoutContainer: LayoutContainer!
    
    override func setUp() {
        super.setUp()
        testView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        layoutContainer = LayoutContainer()
    }
    
    override func tearDown() {
        testView = nil
        layoutContainer = nil
        super.tearDown()
    }
    
    // MARK: - AnimationTimingFunction Tests
    
    func testAnimationTimingFunctionLinear() {
        let timing = AnimationTimingFunction.linear
        XCTAssertEqual(timing.animationOptions, .curveLinear)
    }
    
    func testAnimationTimingFunctionEaseIn() {
        let timing = AnimationTimingFunction.easeIn
        XCTAssertEqual(timing.animationOptions, .curveEaseIn)
    }
    
    func testAnimationTimingFunctionEaseOut() {
        let timing = AnimationTimingFunction.easeOut
        XCTAssertEqual(timing.animationOptions, .curveEaseOut)
    }
    
    func testAnimationTimingFunctionEaseInOut() {
        let timing = AnimationTimingFunction.easeInOut
        XCTAssertEqual(timing.animationOptions, .curveEaseInOut)
    }
    
    func testAnimationTimingFunctionSpring() {
        let timing = AnimationTimingFunction.spring(damping: 0.7, initialVelocity: 0.5)
        if case .spring(let damping, let initialVelocity) = timing {
            XCTAssertEqual(damping, 0.7, accuracy: 0.001)
            XCTAssertEqual(initialVelocity, 0.5, accuracy: 0.001)
        } else {
            XCTFail("Expected spring timing function")
        }
    }
    
    func testAnimationTimingFunctionValueLinear() {
        let linear = AnimationTimingFunction.linear
        XCTAssertEqual(linear.value(at: 0.0), 0.0, accuracy: 0.001)
        XCTAssertEqual(linear.value(at: 0.5), 0.5, accuracy: 0.001)
        XCTAssertEqual(linear.value(at: 1.0), 1.0, accuracy: 0.001)
    }
    
    func testAnimationTimingFunctionValueEaseInOut() {
        let easeInOut = AnimationTimingFunction.easeInOut
        let value = easeInOut.value(at: 0.5)
        XCTAssertGreaterThan(value, 0.4)
        XCTAssertLessThan(value, 0.6)
        
        XCTAssertEqual(easeInOut.value(at: 0.0), 0.0, accuracy: 0.001)
        XCTAssertEqual(easeInOut.value(at: 1.0), 1.0, accuracy: 0.001)
    }
    
    // MARK: - LayoutAnimation Tests
    
    func testLayoutAnimationCreation() {
        let animation = LayoutAnimation(
            duration: 0.3,
            delay: 0.1,
            timingFunction: .easeInOut,
            repeatCount: 1,
            autoreverses: false
        )
        
        XCTAssertEqual(animation.duration, 0.3)
        XCTAssertEqual(animation.delay, 0.1)
        XCTAssertEqual(animation.repeatCount, 1)
        XCTAssertFalse(animation.autoreverses)
        XCTAssertEqual(animation.timingFunction.animationOptions, .curveEaseInOut)
    }
    
    func testLayoutAnimationDefault() {
        let animation = LayoutAnimation.default
        XCTAssertEqual(animation.duration, 0.3)
        XCTAssertEqual(animation.delay, 0)
        XCTAssertEqual(animation.timingFunction.animationOptions, .curveEaseInOut)
        XCTAssertEqual(animation.repeatCount, 1)
        XCTAssertFalse(animation.autoreverses)
    }
    
    func testLayoutAnimationSpring() {
        let animation = LayoutAnimation.spring
        XCTAssertEqual(animation.duration, 0.5)
        if case .spring(let damping, let initialVelocity) = animation.timingFunction {
            XCTAssertEqual(damping, 0.7, accuracy: 0.001)
            XCTAssertEqual(initialVelocity, 0, accuracy: 0.001)
        } else {
            XCTFail("Expected spring timing function")
        }
    }
    
    func testLayoutAnimationQuick() {
        let animation = LayoutAnimation.quick
        XCTAssertEqual(animation.duration, 0.15)
        XCTAssertEqual(animation.timingFunction.animationOptions, .curveEaseOut)
    }
    
    func testLayoutAnimationSpringFactory() {
        let animation = LayoutAnimation.spring(damping: 0.6, velocity: 0.8, duration: 0.4)
        XCTAssertEqual(animation.duration, 0.4)
        if case .spring(let damping, let initialVelocity) = animation.timingFunction {
            XCTAssertEqual(damping, 0.6, accuracy: 0.001)
            XCTAssertEqual(initialVelocity, 0.8, accuracy: 0.001)
        } else {
            XCTFail("Expected spring timing function")
        }
    }
    
    func testLayoutAnimationEaseInFactory() {
        let animation = LayoutAnimation.easeIn(duration: 0.25)
        XCTAssertEqual(animation.duration, 0.25)
        XCTAssertEqual(animation.timingFunction.animationOptions, .curveEaseIn)
    }
    
    func testLayoutAnimationEaseOutFactory() {
        let animation = LayoutAnimation.easeOut(duration: 0.35)
        XCTAssertEqual(animation.duration, 0.35)
        XCTAssertEqual(animation.timingFunction.animationOptions, .curveEaseOut)
    }
    
    func testLayoutAnimationEaseInOutFactory() {
        let animation = LayoutAnimation.easeInOut(duration: 0.45)
        XCTAssertEqual(animation.duration, 0.45)
        XCTAssertEqual(animation.timingFunction.animationOptions, .curveEaseInOut)
    }
    
    func testLayoutAnimationLinearFactory() {
        let animation = LayoutAnimation.linear(duration: 0.2)
        XCTAssertEqual(animation.duration, 0.2)
        XCTAssertEqual(animation.timingFunction.animationOptions, .curveLinear)
    }
    
    // MARK: - withAnimation Tests
    
    func testWithAnimationBasic() {
        let initialAlpha = testView.alpha
        let initialSize = testView.frame.size
        
        withAnimation {
            self.testView.alpha = 0.5
            self.testView.frame.size = CGSize(width: 200, height: 100)
        }
        
        XCTAssertNotNil(testView)
        XCTAssertEqual(testView.alpha, 0.5)
        XCTAssertEqual(testView.frame.size, CGSize(width: 200, height: 100))
    }
    
    func testWithAnimationDefault() {
        withAnimation {
            self.testView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }
        
        XCTAssertEqual(testView.transform.a, 1.5, accuracy: 0.001)
        XCTAssertEqual(testView.transform.d, 1.5, accuracy: 0.001)
    }
    
    func testWithAnimationSpring() {
        withAnimation(.spring(damping: 0.7, velocity: 0.5)) {
            self.testView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
        
        XCTAssertEqual(testView.transform.a, 1.2, accuracy: 0.001)
        XCTAssertEqual(testView.transform.d, 1.2, accuracy: 0.001)
    }
    
    func testWithAnimationCustomTiming() {
        withAnimation(.easeInOut(duration: 0.2)) {
            self.testView.frame.origin = CGPoint(x: 50, y: 50)
        }
        
        XCTAssertEqual(testView.frame.origin, CGPoint(x: 50, y: 50))
    }
    
    func testWithAnimationWithCompletion() {
        var completionCalled = false
        var completionFinished = false
        
        withAnimation(.easeInOut(duration: 0.1), {
            self.testView.frame.origin = CGPoint(x: 100, y: 100)
        }, completion: { finished in
            completionCalled = true
            completionFinished = finished
        })
        
        XCTAssertNotNil(testView)
        XCTAssertEqual(testView.frame.origin, CGPoint(x: 100, y: 100))
    }
    
    // MARK: - Animation Protection Tests
    
    func testAnimationProtection() {
        layoutContainer.addSubview(testView)
        
        XCTAssertTrue(layoutContainer.subviews.contains(testView))
        XCTAssertFalse(layoutContainer.isAnimating, "Should not be animating initially")
        
        layoutContainer.startAnimating(testView)
        XCTAssertTrue(layoutContainer.isAnimating, "Should be animating after startAnimating")
        
        layoutContainer.stopAnimating(testView)
        XCTAssertFalse(layoutContainer.isAnimating, "Should not be animating after stopAnimating")
    }
    
    func testAnimationProtectionMultipleViews() {
        let view1 = UIView()
        let view2 = UIView()
        
        layoutContainer.addSubview(view1)
        layoutContainer.addSubview(view2)
        
        layoutContainer.startAnimating(view1)
        XCTAssertTrue(layoutContainer.isAnimating)
        
        layoutContainer.startAnimating(view2)
        XCTAssertTrue(layoutContainer.isAnimating)
        
        layoutContainer.stopAnimating(view1)
        XCTAssertTrue(layoutContainer.isAnimating, "Should still be animating while view2 is animating")
        
        layoutContainer.stopAnimating(view2)
        XCTAssertFalse(layoutContainer.isAnimating, "Should not be animating after all views stop")
    }
    
    func testAnimationProtectionWithLayout() {
        // Set frame for layoutContainer to ensure layout can be calculated
        layoutContainer.frame = CGRect(x: 0, y: 0, width: 300, height: 400)
        
        layoutContainer.updateBody {
            self.testView.layout()
        }
        
        // Force layout to ensure views are added to hierarchy
        layoutContainer.layoutIfNeeded()
        
        // Verify body was set
        XCTAssertNotNil(layoutContainer.body, "Body should be set")
        
        // Verify testView is in the body's extracted views
        let bodyViews = layoutContainer.body?.extractViews() ?? []
        XCTAssertTrue(bodyViews.contains(testView), "Test view should be in body's extracted views")
        
        // Helper function to find view recursively in view hierarchy
        func findViewRecursively(_ view: UIView, in container: UIView) -> UIView? {
            if container === view {
                return view
            }
            for subview in container.subviews {
                if subview === view {
                    return view
                }
                if let found = findViewRecursively(view, in: subview) {
                    return found
                }
            }
            return nil
        }
        
        // Find testView in the actual view hierarchy
        let targetView = findViewRecursively(testView, in: layoutContainer)
        
        XCTAssertNotNil(targetView, "Test view should be in the layout hierarchy. Container subviews: \(layoutContainer.subviews.count), Body views: \(bodyViews.count)")
        
        guard let view = targetView else { return }
        
        XCTAssertFalse(layoutContainer.isAnimating)
        
        layoutContainer.startAnimating(view)
        XCTAssertTrue(layoutContainer.isAnimating)
        
        layoutContainer.stopAnimating(view)
        XCTAssertFalse(layoutContainer.isAnimating)
    }
}
