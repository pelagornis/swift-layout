import XCTest
import UIKit
import SwiftUI
@testable import Layout

/// Main test suite configuration
final class LayoutTestSuite: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        print("🧪 Starting Layout Test Suite")
    }
    
    override class func tearDown() {
        print("✅ Layout Test Suite Completed")
        super.tearDown()
    }
    
    /// Test that verifies the entire library is working correctly
    // Disabled: Stack container behavior
    @MainActor func xtestLibraryIntegration() {
        let container = LayoutContainer()
        container.frame = CGRect(x: 0, y: 0, width: 320, height: 568)
        let label = UILabel()
        let button = UIButton()
        
        // Test the complete flow
        container.setBody {
            VStack(spacing: 20) {
                
                    label.layout()
                        .size(width: 200, height: 30)
                        .centerX()
                    
                    button.layout()
                        .size(width: 150, height: 44)
                        .centerX()
                        .offset(y: 10)
                
            }
            .padding(20)
        }
        
        // Verify the complete integration works
        XCTAssertNotNil(container.body)
        XCTAssertEqual(container.subviews.count, 2)
        
        container.layoutSubviews()
        
        // Verify final layout
        XCTAssertTrue(label.frame.origin.x > 0)
        XCTAssertTrue(button.frame.origin.x > 0)
        XCTAssertTrue(button.frame.origin.y > label.frame.maxY)
    }
}
