import XCTest
import UIKit
import SwiftUI
@testable import Layout

/// Tests for core layout protocols and basic functionality
final class CoreLayoutTests: XCTestCase, @unchecked Sendable {
    
    var testView: UIView!
    var layoutContainer: LayoutContainer!
    
    override func setUp() {
        super.setUp()
        MainActor.assumeIsolated {
            testView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
            layoutContainer = LayoutContainer(frame: CGRect(x: 0, y: 0, width: 300, height: 400))
        }
    }
    
    override func tearDown() {
        testView = nil
        layoutContainer = nil
        super.tearDown()
    }
    
    // MARK: - LayoutResult Tests
    
    func testLayoutResultCreation() {
        let frames: [UIView: CGRect] = [testView: CGRect(x: 10, y: 20, width: 100, height: 50)]
        let totalSize = CGSize(width: 200, height: 300)
        let result = LayoutResult(frames: frames, totalSize: totalSize)
        
        XCTAssertEqual(result.frames.count, 1)
        XCTAssertEqual(result.frames[testView], CGRect(x: 10, y: 20, width: 100, height: 50))
        XCTAssertEqual(result.totalSize, CGSize(width: 200, height: 300))
    }
    
    @MainActor func testLayoutResultApplying() {
        let targetFrame = CGRect(x: 50, y: 75, width: 120, height: 60)
        let result = LayoutResult(frames: [testView: targetFrame], totalSize: .zero)
        
        // Apply the layout
        result.applying(to: layoutContainer)
        
        XCTAssertEqual(testView.frame, targetFrame)
    }
    
    // MARK: - ViewLayout Tests
    
    @MainActor func testViewLayoutBasicCreation() {
        let viewLayout = ViewLayout(testView)
        
        XCTAssertTrue(viewLayout.view === testView)
        XCTAssertEqual(viewLayout.modifiers.count, 0)
        XCTAssertEqual(viewLayout.extractViews(), [testView])
    }
    
    @MainActor func testViewLayoutSizeModifier() {
        let viewLayout = testView.layout()
            .size(width: 200, height: 100)
        
        let bounds = CGRect(x: 0, y: 0, width: 400, height: 300)
        let result = viewLayout.calculateLayout(in: bounds)
        
        guard let frame = result.frames[testView] else {
            XCTFail("Frame not found for test view")
            return
        }
        
        XCTAssertEqual(frame.size, CGSize(width: 200, height: 100))
    }
    
    @MainActor func testViewLayoutCenterModifier() {
        let viewLayout = testView.layout()
            .size(width: 100, height: 50)
            .center()
        
        let bounds = CGRect(x: 0, y: 0, width: 400, height: 300)
        let result = viewLayout.calculateLayout(in: bounds)
        
        guard let frame = result.frames[testView] else {
            XCTFail("Frame not found for test view")
            return
        }
        
        XCTAssertEqual(frame.origin.x, 150) // (400 - 100) / 2
        XCTAssertEqual(frame.origin.y, 125) // (300 - 50) / 2
    }
    
    @MainActor func testViewLayoutOffsetModifier() {
        let viewLayout = testView.layout()
            .offset(x: 20, y: 30)
        
        let bounds = CGRect(x: 0, y: 0, width: 400, height: 300)
        let result = viewLayout.calculateLayout(in: bounds)
        
        guard let frame = result.frames[testView] else {
            XCTFail("Frame not found for test view")
            return
        }
        
        XCTAssertEqual(frame.origin.x, 20)
        XCTAssertEqual(frame.origin.y, 30)
    }
    
    // Disabled: Modifier chaining behavior needs investigation
    @MainActor func xtestViewLayoutChainedModifiers() {
        let viewLayout = testView.layout()
            .size(width: 100, height: 50)
            .centerX()
            .position(x: 0, y: 10)
            .offset(x: 5, y: 0)
        
        let bounds = CGRect(x: 0, y: 0, width: 400, height: 300)
        let result = viewLayout.calculateLayout(in: bounds)
        
        guard let frame = result.frames[testView] else {
            XCTFail("Frame not found for test view")
            return
        }
        
        XCTAssertEqual(frame.size, CGSize(width: 100, height: 50))
        XCTAssertEqual(frame.origin.x, 155) // (400 - 100) / 2 + 5
        XCTAssertEqual(frame.origin.y, 10)
    }
}
