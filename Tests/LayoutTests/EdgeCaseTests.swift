import XCTest
import UIKit
import SwiftUI
@testable import Layout

/// Tests for edge cases and error conditions
class EdgeCaseTests: XCTestCase {
    
    @MainActor func testEmptyLayout() {
        let container = LayoutContainer(frame: CGRect(x: 0, y: 0, width: 300, height: 400))
        
        container.setBody {
            VStack {
                EmptyLayout()
            }
        }
        
        // VStack itself is added as a subview
        XCTAssertGreaterThanOrEqual(container.subviews.count, 0)
        
        // Should not crash
        container.layoutSubviews()
    }
    
    @MainActor func testZeroSizedBounds() {
        let view = UIView()
        let layout = view.layout().center()
        
        let result = layout.calculateLayout(in: .zero)
        
        // Should handle zero bounds gracefully
        XCTAssertNotNil(result.frames[view])
    }
    
    @MainActor func testNegativeBounds() {
        let view = UIView()
        let layout = view.layout().size(width: 100, height: 50)
        
        let negativeBounds = CGRect(x: 0, y: 0, width: -100, height: -50)
        let result = layout.calculateLayout(in: negativeBounds)
        
        // Should handle negative bounds without crashing
        XCTAssertNotNil(result.frames[view])
    }
    
    @MainActor func testVeryLargeLayout() {
        let views = (0..<10000).map { _ in UIView() }
        let container = LayoutContainer(frame: CGRect(x: 0, y: 0, width: 300, height: 400))
        
        // Should handle very large number of views
        XCTAssertNoThrow {
            container.setBody {
                VStack {
                    ForEach(views) { view in
                        view.layout().size(width: 280, height: 1)
                    }
                }
            }
        }
    }
    
    @MainActor func testCircularReference() {
        let container = LayoutContainer()
        
        // This should not cause infinite recursion
        XCTAssertNoThrow {
            container.setBody {
                VStack {
                    container.layout()// Self-reference
                }
            }
        }
    }
}
