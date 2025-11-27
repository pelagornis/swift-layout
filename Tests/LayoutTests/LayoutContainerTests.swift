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
        layoutContainer.layoutIfNeeded()
        
        // Single view wrapped in auto VStack
        XCTAssertGreaterThanOrEqual(layoutContainer.subviews.count, 1)
    }
    
    func testSetBodyWithVStack() {
        // VStack itself is added as a subview, containing the child views
        layoutContainer.setBody {
            VStack {
                self.testView1.layout()
                self.testView2.layout()
            }
        }
        layoutContainer.layoutIfNeeded()
        
        // VStack is the direct subview of container
        XCTAssertEqual(layoutContainer.subviews.count, 1)
        
        // VStack should be a VStack type
        let vstack = layoutContainer.subviews.first as? VStack
        XCTAssertNotNil(vstack)
        
        // Child views are inside VStack
        XCTAssertTrue(vstack?.subviews.contains(testView1) ?? false)
        XCTAssertTrue(vstack?.subviews.contains(testView2) ?? false)
    }
    
    func testSetBodyWithHStack() {
        layoutContainer.setBody {
            HStack {
                self.testView1.layout()
                self.testView2.layout()
            }
        }
        layoutContainer.layoutIfNeeded()
        
        // HStack is the direct subview
        XCTAssertEqual(layoutContainer.subviews.count, 1)
        
        let hstack = layoutContainer.subviews.first as? HStack
        XCTAssertNotNil(hstack)
        
        // Child views are inside HStack
        XCTAssertTrue(hstack?.subviews.contains(testView1) ?? false)
        XCTAssertTrue(hstack?.subviews.contains(testView2) ?? false)
    }
    
    func testSetBodyWithZStack() {
        layoutContainer.setBody {
            ZStack {
                self.testView1.layout()
                self.testView2.layout()
                self.testView3.layout()
            }
        }
        layoutContainer.layoutIfNeeded()
        
        // ZStack is the direct subview
        XCTAssertEqual(layoutContainer.subviews.count, 1)
        
        let zstack = layoutContainer.subviews.first as? ZStack
        XCTAssertNotNil(zstack)
        
        // Child views are inside ZStack
        XCTAssertTrue(zstack?.subviews.contains(testView1) ?? false)
        XCTAssertTrue(zstack?.subviews.contains(testView2) ?? false)
        XCTAssertTrue(zstack?.subviews.contains(testView3) ?? false)
    }
    
    // MARK: - View Hierarchy Management Tests
    
    func testViewHierarchyUpdate() {
        // Initially set with one view
        layoutContainer.setBody {
            self.testView1.layout()
        }
        layoutContainer.layoutIfNeeded()
        XCTAssertGreaterThanOrEqual(layoutContainer.subviews.count, 1)
        
        // Update to different view
        layoutContainer.setBody {
            self.testView2.layout()
        }
        layoutContainer.layoutIfNeeded()
        XCTAssertGreaterThanOrEqual(layoutContainer.subviews.count, 1)
    }
    
    func testViewHierarchyWithStackReplacement() {
        // Start with single view
        layoutContainer.setBody {
            self.testView1.layout()
        }
        layoutContainer.layoutIfNeeded()
        XCTAssertGreaterThanOrEqual(layoutContainer.subviews.count, 1)
        
        // Replace with VStack
        layoutContainer.setBody {
            VStack {
                self.testView1.layout()
                self.testView2.layout()
            }
        }
        layoutContainer.layoutIfNeeded()
        
        // Now container has VStack as single subview
        XCTAssertEqual(layoutContainer.subviews.count, 1)
        XCTAssertTrue(layoutContainer.subviews.first is VStack)
    }
    
    // MARK: - Layout Calculation Tests
    
    func testVStackLayoutCalculation() {
        let vstack = VStack(spacing: 10) {
            self.testView1.layout().size(width: 100, height: 50)
            self.testView2.layout().size(width: 80, height: 40)
        }
        
        let bounds = CGRect(x: 0, y: 0, width: 400, height: 300)
        let result = vstack.calculateLayout(in: bounds)
        
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result.frames.count, 0)
        
        // Total height should be view1(50) + spacing(10) + view2(40) = 100
        XCTAssertEqual(result.totalSize.height, 100, accuracy: 1.0)
    }
    
    func testHStackLayoutCalculation() {
        let hstack = HStack(spacing: 10) {
            self.testView1.layout().size(width: 100, height: 50)
            self.testView2.layout().size(width: 80, height: 40)
        }
        
        let bounds = CGRect(x: 0, y: 0, width: 400, height: 300)
        let result = hstack.calculateLayout(in: bounds)
        
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result.frames.count, 0)
        
        // Total width should be view1(100) + spacing(10) + view2(80) = 190
        XCTAssertEqual(result.totalSize.width, 190, accuracy: 1.0)
    }
    
    func testZStackLayoutCalculation() {
        let zstack = ZStack(alignment: .center) {
            self.testView1.layout().size(width: 100, height: 50)
            self.testView2.layout().size(width: 80, height: 40)
        }
        
        let bounds = CGRect(x: 0, y: 0, width: 400, height: 300)
        let result = zstack.calculateLayout(in: bounds)
        
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result.frames.count, 0)
        
        // ZStack size should match the largest child
        XCTAssertEqual(result.totalSize.width, 100, accuracy: 1.0)
        XCTAssertEqual(result.totalSize.height, 50, accuracy: 1.0)
    }
    
    // MARK: - Spacer Tests
    
    func testVStackWithSpacer() {
        let vstack = VStack(spacing: 0) {
            self.testView1.layout().size(width: 100, height: 50)
            Spacer(minLength: 100)
            self.testView2.layout().size(width: 100, height: 50)
        }
        
        let bounds = CGRect(x: 0, y: 0, width: 400, height: 300)
        let result = vstack.calculateLayout(in: bounds)
        
        XCTAssertNotNil(result)
        
        // Total height should include spacer's minLength
        // view1(50) + spacer(at least 100) + view2(50) = at least 200
        XCTAssertGreaterThanOrEqual(result.totalSize.height, 200)
    }
    
    func testHStackWithSpacer() {
        let hstack = HStack(spacing: 0) {
            self.testView1.layout().size(width: 50, height: 100)
            Spacer(minLength: 80)
            self.testView2.layout().size(width: 50, height: 100)
        }
        
        let bounds = CGRect(x: 0, y: 0, width: 400, height: 300)
        let result = hstack.calculateLayout(in: bounds)
        
        XCTAssertNotNil(result)
        
        // Total width should include spacer's minLength
        // view1(50) + spacer(at least 80) + view2(50) = at least 180
        XCTAssertGreaterThanOrEqual(result.totalSize.width, 180)
    }
    
    func testSpacerMinLengthProperty() {
        let spacer = Spacer(minLength: 120)
        
        XCTAssertEqual(spacer.minLength, 120)
        XCTAssertEqual(spacer.intrinsicContentSize, CGSize(width: 120, height: 120))
        XCTAssertTrue(spacer.isSpacer)
    }
    
    // MARK: - Nested Layout Tests
    
    func testNestedStackLayout() {
        let layout = VStack(spacing: 10) {
            HStack(spacing: 5) {
                self.testView1.layout().size(width: 50, height: 30)
                self.testView2.layout().size(width: 50, height: 30)
            }
            self.testView3.layout().size(width: 100, height: 40)
        }
        
        let bounds = CGRect(x: 0, y: 0, width: 400, height: 300)
        let result = layout.calculateLayout(in: bounds)
        
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result.frames.count, 0)
        
        // Height: HStack(30) + spacing(10) + view3(40) = 80
        XCTAssertEqual(result.totalSize.height, 80, accuracy: 1.0)
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
    
    func testBodyReplacement() {
        // Set initial body
        layoutContainer.setBody {
            self.testView1.layout()
        }
        layoutContainer.layoutIfNeeded()
        XCTAssertNotNil(layoutContainer.body)
        
        // Replace with new body
        layoutContainer.setBody {
            VStack {
                self.testView2.layout()
            }
        }
        layoutContainer.layoutIfNeeded()
        XCTAssertNotNil(layoutContainer.body)
        
        // Should have VStack as subview now
        XCTAssertEqual(layoutContainer.subviews.count, 1)
        XCTAssertTrue(layoutContainer.subviews.first is VStack)
    }
    
    func testLayoutWithScrollView() {
        let scrollView = ScrollView {
            VStack(spacing: 0) {
                self.testView1.layout().size(width: 100, height: 50)
                Spacer(minLength: 100)
                self.testView2.layout().size(width: 100, height: 50)
            }
        }
        
        let bounds = CGRect(x: 0, y: 0, width: 400, height: 300)
        let result = scrollView.calculateLayout(in: bounds)
        
        XCTAssertNotNil(result)
        // Content size should include spacer minLength
        XCTAssertGreaterThanOrEqual(result.totalSize.height, 200)
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
