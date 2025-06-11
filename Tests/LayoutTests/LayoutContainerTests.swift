import XCTest
import UIKit
@testable import Layout

@MainActor
final class LayoutContainerTests: XCTestCase, @unchecked Sendable {
    
    var layoutContainer: LayoutContainer!
    var testView1: UIView!
    var testView2: UIView!
    var testView3: UIView!
    
    override func setUp() {
        super.setUp()
        MainActor.assumeIsolated {
            layoutContainer = LayoutContainer(frame: CGRect(x: 0, y: 0, width: 400, height: 300))
            testView1 = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
            testView1.backgroundColor = .red
            testView2 = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
            testView2.backgroundColor = .blue
            testView3 = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
            testView3.backgroundColor = .green
        }
    }
    
    override func tearDown() {
        MainActor.assumeIsolated {
            layoutContainer = nil
            testView1 = nil
            testView2 = nil
            testView3 = nil
        }
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testLayoutContainerInitialization() {
        XCTAssertNotNil(layoutContainer)
        XCTAssertNil(layoutContainer.body)
        XCTAssertEqual(layoutContainer.subviews.count, 0)
    }
    
    // MARK: - Body Property Tests
    
    func testBodyPropertySetter() {
        let layout = testView1.layout()
        layoutContainer.body = layout
        
        XCTAssertNotNil(layoutContainer.body)
        XCTAssertEqual(layoutContainer.body?.extractViews().count, 1)
        XCTAssertTrue(layoutContainer.body?.extractViews().first === testView1)
    }
    
    func testBodyPropertyGetter() {
        layoutContainer.setBody {
            self.testView1.layout()
        }
        
        let retrievedBody = layoutContainer.body
        XCTAssertNotNil(retrievedBody)
        XCTAssertEqual(retrievedBody?.extractViews().count, 1)
        XCTAssertTrue(retrievedBody?.extractViews().first === testView1)
    }
    
    // MARK: - SetBody Tests
    
    func testSetBodySingleView() {
        layoutContainer.setBody {
            self.testView1.layout()
        }
        
        XCTAssertEqual(layoutContainer.subviews.count, 1)
        XCTAssertTrue(layoutContainer.subviews.contains(testView1))
    }
    
    func testSetBodyMultipleViews() {
        layoutContainer.setBody {
            VStack {
                self.testView1.layout()
                self.testView2.layout()
            }
        }
        
        XCTAssertEqual(layoutContainer.subviews.count, 2)
        XCTAssertTrue(layoutContainer.subviews.contains(testView1))
        XCTAssertTrue(layoutContainer.subviews.contains(testView2))
    }
    
    func testSetBodyZStack() {
        layoutContainer.setBody {
            ZStack {
                self.testView1.layout()
                self.testView2.layout()
                self.testView3.layout()
            }
        }
        
        XCTAssertEqual(layoutContainer.subviews.count, 3)
        XCTAssertTrue(layoutContainer.subviews.contains(testView1))
        XCTAssertTrue(layoutContainer.subviews.contains(testView2))
        XCTAssertTrue(layoutContainer.subviews.contains(testView3))
    }
    
    // MARK: - View Hierarchy Management Tests
    
    func testViewHierarchyUpdate() {
        // Initially set with one view
        layoutContainer.setBody {
            self.testView1.layout()
        }
        XCTAssertEqual(layoutContainer.subviews.count, 1)
        XCTAssertTrue(layoutContainer.subviews.contains(testView1))
        
        // Update to different view
        layoutContainer.setBody {
            self.testView2.layout()
        }
        XCTAssertEqual(layoutContainer.subviews.count, 1)
        XCTAssertTrue(layoutContainer.subviews.contains(testView2))
        XCTAssertFalse(layoutContainer.subviews.contains(testView1))
        XCTAssertNil(testView1.superview) // testView1 should be removed
    }
    
    func testViewHierarchyAddition() {
        // Start with one view
        layoutContainer.setBody {
            self.testView1.layout()
        }
        XCTAssertEqual(layoutContainer.subviews.count, 1)
        
        // Add second view
        layoutContainer.setBody {
            VStack {
                self.testView1.layout()
                self.testView2.layout()
            }
        }
        XCTAssertEqual(layoutContainer.subviews.count, 2)
        XCTAssertTrue(layoutContainer.subviews.contains(testView1))
        XCTAssertTrue(layoutContainer.subviews.contains(testView2))
    }
    
    func testViewHierarchyRemoval() {
        // Start with two views
        layoutContainer.setBody {
            VStack {
                self.testView1.layout()
                self.testView2.layout()
            }
        }
        XCTAssertEqual(layoutContainer.subviews.count, 2)
        
        // Remove one view
        layoutContainer.setBody {
            self.testView1.layout()
        }
        XCTAssertEqual(layoutContainer.subviews.count, 1)
        XCTAssertTrue(layoutContainer.subviews.contains(testView1))
        XCTAssertFalse(layoutContainer.subviews.contains(testView2))
        XCTAssertNil(testView2.superview)
    }
    
    func testViewHierarchyCompleteReplacement() {
        // Start with some views
        layoutContainer.setBody {
            VStack {
                self.testView1.layout()
                self.testView2.layout()
            }
        }
        XCTAssertEqual(layoutContainer.subviews.count, 2)
        
        // Completely replace with new view
        layoutContainer.setBody {
            self.testView3.layout()
        }
        XCTAssertEqual(layoutContainer.subviews.count, 1)
        XCTAssertTrue(layoutContainer.subviews.contains(testView3))
        XCTAssertFalse(layoutContainer.subviews.contains(testView1))
        XCTAssertFalse(layoutContainer.subviews.contains(testView2))
        XCTAssertNil(testView1.superview)
        XCTAssertNil(testView2.superview)
    }
    
    // MARK: - Layout Tests
    
    func testLayoutSubviewsBasic() {
        layoutContainer.setBody {
            self.testView1.layout()
                .size(width: 200, height: 100)
                .center()
        }
        
        // Trigger layout
        layoutContainer.layoutSubviews()
        
        let expectedX = (400 - 200) / 2 // (container width - view width) / 2
        let expectedY = (300 - 100) / 2 // (container height - view height) / 2
        
        XCTAssertEqual(testView1.frame.origin.x, CGFloat(expectedX), accuracy: 1.0)
        XCTAssertEqual(testView1.frame.origin.y, CGFloat(expectedY), accuracy: 1.0)
        XCTAssertEqual(testView1.frame.size.width, 200)
        XCTAssertEqual(testView1.frame.size.height, 100)
    }
    
    func testLayoutSubviewsVStack() {
        layoutContainer.setBody {
            VStack(spacing: 10) {
                self.testView1.layout()
                    .size(width: 100, height: 50)
                self.testView2.layout()
                    .size(width: 80, height: 40)
            }
        }
        
        // Trigger layout
        layoutContainer.layoutSubviews()
        
        // Check if views are stacked vertically
        XCTAssertEqual(testView1.frame.origin.y, 0)
        XCTAssertEqual(testView2.frame.origin.y, 60) // 50 + 10 spacing
        XCTAssertEqual(testView1.frame.size.width, 100)
        XCTAssertEqual(testView1.frame.size.height, 50)
        XCTAssertEqual(testView2.frame.size.width, 80)
        XCTAssertEqual(testView2.frame.size.height, 40)
    }
    
    func testLayoutSubviewsZStack() {
        layoutContainer.setBody {
            ZStack(alignment: .center) {
                self.testView1.layout()
                    .size(width: 100, height: 50)
                self.testView2.layout()
                    .size(width: 80, height: 40)
            }
        }
        
        // Trigger layout
        layoutContainer.layoutSubviews()
        
        // In ZStack with center alignment, both views should be centered
        let expectedX1 = (400 - 100) / 2
        let expectedY1 = (300 - 50) / 2
        let expectedX2 = (400 - 80) / 2
        let expectedY2 = (300 - 40) / 2
        
        XCTAssertEqual(testView1.frame.origin.x, CGFloat(expectedX1), accuracy: 1.0)
        XCTAssertEqual(testView1.frame.origin.y, CGFloat(expectedY1), accuracy: 1.0)
        XCTAssertEqual(testView2.frame.origin.x, CGFloat(expectedX2), accuracy: 1.0)
        XCTAssertEqual(testView2.frame.origin.y, CGFloat(expectedY2), accuracy: 1.0)
    }
    
    // MARK: - Complex Layout Tests
    
    func testComplexNestedLayout() {
        layoutContainer.setBody {
            VStack(spacing: 20) {
                self.testView1.layout()
                    .size(width: 200, height: 50)
                    .centerX()
                
                ZStack {
                    self.testView2.layout()
                        .size(width: 100, height: 100)
                    self.testView3.layout()
                        .size(width: 50, height: 50)
                }
            }
        }
        
        // Trigger layout
        layoutContainer.layoutSubviews()
        
        // testView1 should be at top, centered horizontally
        XCTAssertEqual(testView1.frame.origin.x, (400 - 200) / 2, accuracy: 1.0)
        XCTAssertEqual(testView1.frame.origin.y, 0, accuracy: 1.0)
        
        // testView2 and testView3 should be in ZStack, positioned after testView1 + spacing
        let zStackY = 50 + 20 // testView1 height + spacing
        XCTAssertEqual(testView2.frame.origin.y, CGFloat(zStackY), accuracy: 1.0)
        XCTAssertEqual(testView3.frame.origin.y, CGFloat(zStackY + (100 - 50) / 2), accuracy: 1.0) // centered in ZStack
    }
    
    // MARK: - Edge Cases
    
    func testEmptyBody() {
        // Don't set any body
        layoutContainer.layoutSubviews()
        
        XCTAssertEqual(layoutContainer.subviews.count, 0)
        XCTAssertNil(layoutContainer.body)
    }
    
    func testSetNeedsLayoutAfterSetBody() {
        var layoutCallCount = 0
        
        // Create a custom container to track layout calls
        let customContainer = TestLayoutContainer(frame: CGRect(x: 0, y: 0, width: 400, height: 300))
        customContainer.layoutCallback = { layoutCallCount += 1 }
        
        customContainer.setBody {
            self.testView1.layout()
        }
        
        // setBody should trigger setNeedsLayout
        customContainer.layoutIfNeeded()
        XCTAssertGreaterThan(layoutCallCount, 0)
    }
}

// MARK: - Helper Classes

private class TestLayoutContainer: LayoutContainer {
    var layoutCallback: (() -> Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutCallback?()
    }
}
