import XCTest
import UIKit
@testable import Layout

@MainActor
final class ScrollViewTests: XCTestCase {
    
    var scrollView: ScrollView!
    var testView1: UIView!
    var testView2: UIView!
    
    override func setUp() {
        super.setUp()
        // @MainActor class, so setUp() already runs on MainActor
        testView1 = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        testView1.backgroundColor = .red
        testView2 = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        testView2.backgroundColor = .blue
    }
    
    override func tearDown() {
        // @MainActor class, so tearDown() already runs on MainActor
        scrollView = nil
        testView1 = nil
        testView2 = nil
        super.tearDown()
    }
    
    // MARK: - ScrollView Initialization Tests
    
    func testScrollViewInitialization() {
        scrollView = ScrollView {
            self.testView1.layout()
        }
        
        XCTAssertNotNil(scrollView)
        XCTAssertEqual(scrollView.axis, .vertical)
    }
    
    func testScrollViewHorizontalAxis() {
        scrollView = ScrollView(.horizontal) {
            self.testView1.layout()
        }
        
        XCTAssertEqual(scrollView.axis, .horizontal)
    }
    
    // MARK: - ScrollView Layout Tests
    
    func testScrollViewVerticalLayout() {
        scrollView = ScrollView {
            VStack(spacing: 10) {
                self.testView1.layout().size(width: 100, height: 50)
                self.testView2.layout().size(width: 100, height: 50)
            }
        }
        
        let bounds = CGRect(x: 0, y: 0, width: 200, height: 100)
        let result = scrollView.calculateLayout(in: bounds)
        
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result.totalSize.height, 100)
    }
    
    func testScrollViewHorizontalLayout() {
        scrollView = ScrollView(.horizontal) {
            HStack(spacing: 10) {
                self.testView1.layout().size(width: 100, height: 50)
                self.testView2.layout().size(width: 100, height: 50)
            }
        }
        
        let bounds = CGRect(x: 0, y: 0, width: 200, height: 100)
        let result = scrollView.calculateLayout(in: bounds)
        
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result.totalSize.width, 200)
    }
    
    // MARK: - Content Offset Preservation Tests
    
    func testScrollViewContentOffsetPreservation() {
        scrollView = ScrollView {
            VStack(spacing: 0) {
                ForEach(0..<10) { index in
                    UIView().layout().size(width: 200, height: 100)
                }
            }
        }
        scrollView.frame = CGRect(x: 0, y: 0, width: 200, height: 400)
        scrollView.layoutIfNeeded()
        
        let initialOffset = CGPoint(x: 0, y: 200)
        scrollView.contentOffset = initialOffset
        
        scrollView.updateChildLayout(scrollView.getChildLayout()!)
        scrollView.layoutIfNeeded()
        
        XCTAssertEqual(scrollView.contentOffset.y, initialOffset.y, accuracy: 1.0)
    }
    
    func testScrollViewContentOffsetWithSafeArea() {
        scrollView = ScrollView {
            VStack(spacing: 0) {
                ForEach(0..<10) { index in
                    UIView().layout().size(width: 200, height: 100)
                }
            }
        }
        scrollView.frame = CGRect(x: 0, y: 0, width: 200, height: 400)
        scrollView.adjustsContentOffsetForSafeArea = true
        scrollView.layoutIfNeeded()
        
        let initialOffset = CGPoint(x: 0, y: -116)
        scrollView.contentOffset = initialOffset
        
        scrollView.updateChildLayout(scrollView.getChildLayout()!)
        scrollView.layoutIfNeeded()
        
        XCTAssertEqual(scrollView.contentOffset.y, initialOffset.y, accuracy: 1.0)
    }
    
    // MARK: - ScrollView with Spacer Tests
    
    func testScrollViewWithSpacer() {
        scrollView = ScrollView {
            VStack(spacing: 0) {
                self.testView1.layout().size(width: 100, height: 50)
                Spacer(minLength: 100)
                self.testView2.layout().size(width: 100, height: 50)
            }
        }
        
        let bounds = CGRect(x: 0, y: 0, width: 200, height: 100)
        let result = scrollView.calculateLayout(in: bounds)
        
        XCTAssertGreaterThanOrEqual(result.totalSize.height, 200)
    }
}
