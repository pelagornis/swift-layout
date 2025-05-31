import XCTest
import UIKit
import SwiftUI
@testable import Layout

/// Tests for utility layouts like Spacer and ForEach
class UtilityLayoutTests: XCTestCase {
    
    func testSpacerWithMinLength() {
        let spacer = Spacer(minLength: 50)
        let bounds = CGRect(x: 0, y: 0, width: 300, height: 200)
        let result = spacer.calculateLayout(in: bounds)
        
        XCTAssertEqual(result.totalSize, CGSize(width: 50, height: 50))
        XCTAssertEqual(result.frames.count, 0) // Spacer has no views
        XCTAssertEqual(spacer.extractViews().count, 0)
    }
    
    func testSpacerWithoutMinLength() {
        let spacer = Spacer()
        let bounds = CGRect(x: 0, y: 0, width: 300, height: 200)
        let result = spacer.calculateLayout(in: bounds)
        
        XCTAssertEqual(result.totalSize, CGSize(width: 300, height: 200))
        XCTAssertEqual(result.frames.count, 0)
    }
    
    func testForEachLayout() {
        let views = [
            UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 30)),
            UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 30)),
            UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        ]
        
        let forEach = ForEach(views) { view in
            view.layout().size(width: 100, height: 30)
        }
        
        let bounds = CGRect(x: 0, y: 0, width: 300, height: 200)
        let result = forEach.calculateLayout(in: bounds)
        
        XCTAssertEqual(result.frames.count, 3)
        XCTAssertEqual(forEach.extractViews().count, 3)
        
        // Check vertical stacking
        for (index, view) in views.enumerated() {
            guard let frame = result.frames[view] else {
                XCTFail("Frame not found for view \(index)")
                continue
            }
            XCTAssertEqual(frame.origin.y, CGFloat(index * 30))
            XCTAssertEqual(frame.size, CGSize(width: 100, height: 30))
        }
    }
}