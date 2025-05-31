import XCTest
import UIKit
import SwiftUI
@testable import Layout

/// Tests for LayoutContainer view hierarchy management
class LayoutContainerTests: XCTestCase {
    
    var container: LayoutContainer!
    var view1: UIView!
    var view2: UIView!
    
    override func setUp() {
        super.setUp()
        container = LayoutContainer(frame: CGRect(x: 0, y: 0, width: 300, height: 400))
        view1 = UIView()
        view2 = UIView()
    }
    
    override func tearDown() {
        container = nil
        view1 = nil
        view2 = nil
        super.tearDown()
    }
    
    func testAutomaticViewAddition() {
        XCTAssertEqual(container.subviews.count, 0)
        
        container.setBody {
            Vertical {
                [
                    view1.layout(),
                    view2.layout()
                ]
            }
        }
        
        XCTAssertEqual(container.subviews.count, 2)
        XCTAssertTrue(container.subviews.contains(view1))
        XCTAssertTrue(container.subviews.contains(view2))
    }
    
    func testAutomaticViewRemoval() {
        // First add both views
        container.setBody {
            Vertical {
                [
                    view1.layout(),
                    view2.layout()
                ]
            }
        }
        XCTAssertEqual(container.subviews.count, 2)
        
        // Then remove one view
        container.setBody {
            Vertical {
                [view1.layout()]
            }
        }
        
        XCTAssertEqual(container.subviews.count, 1)
        XCTAssertTrue(container.subviews.contains(view1))
        XCTAssertFalse(container.subviews.contains(view2))
    }
    
    func testConditionalViewManagement() {
        var showView2 = true
        
        func updateLayout() {
            container.setBody {
                Vertical {
                    if showView2 {
                        [
                            view1.layout(),
                            view2.layout()
                        ]
                    } else {
                        [view1.layout()]
                    }
                }
            }
        }
        
        // Initially show both views
        updateLayout()
        XCTAssertEqual(container.subviews.count, 2)
        
        // Hide view2
        showView2 = false
        updateLayout()
        XCTAssertEqual(container.subviews.count, 1)
        XCTAssertTrue(container.subviews.contains(view1))
        XCTAssertFalse(container.subviews.contains(view2))
        
        // Show view2 again
        showView2 = true
        updateLayout()
        XCTAssertEqual(container.subviews.count, 2)
        XCTAssertTrue(container.subviews.contains(view1))
        XCTAssertTrue(container.subviews.contains(view2))
    }
}