import XCTest
import UIKit
import SwiftUI

extension XCTestCase {
    
    /// Helper method to create a test view with specific properties
    func createTestView(width: CGFloat = 100, height: CGFloat = 50, tag: Int = 0) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        view.tag = tag
        return view
    }
    
    /// Helper method to assert frame equality with tolerance
    func assertFrameEqual(_ frame1: CGRect, _ frame2: CGRect, tolerance: CGFloat = 0.001, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(frame1.origin.x, frame2.origin.x, accuracy: tolerance, file: file, line: line)
        XCTAssertEqual(frame1.origin.y, frame2.origin.y, accuracy: tolerance, file: file, line: line)
        XCTAssertEqual(frame1.size.width, frame2.size.width, accuracy: tolerance, file: file, line: line)
        XCTAssertEqual(frame1.size.height, frame2.size.height, accuracy: tolerance, file: file, line: line)
    }
    
    /// Helper method to measure layout calculation time
    func measureLayoutTime<T>(_ operation: () -> T) -> (result: T, time: TimeInterval) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = operation()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        return (result, timeElapsed)
    }
}