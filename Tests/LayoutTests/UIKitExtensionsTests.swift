import XCTest
import UIKit
@testable import Layout

/// Tests for UIKit SwiftUI-style extensions
@available(iOS 13.0, *)
class UIKitExtensionsTests: XCTestCase {
    
    func testUILabelChainableModifiers() {
        let label = UILabel()
            .text("Test Label")
            .font(.boldSystemFont(ofSize: 18))
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
            .lineLimit(2)
        
        XCTAssertEqual(label.text, "Test Label")
        XCTAssertEqual(label.font, .boldSystemFont(ofSize: 18))
        XCTAssertEqual(label.textColor, .red)
        XCTAssertEqual(label.textAlignment, .center)
        XCTAssertEqual(label.numberOfLines, 2)
    }
    
    func testUIButtonChainableModifiers() {
        let button = UIButton(type: .system)
            .title("Test Button")
            .foregroundColor(.white)
            .font(.systemFont(ofSize: 16))
            .background(.blue)
            .cornerRadius(8)
        
        XCTAssertEqual(button.title(for: .normal), "Test Button")
        XCTAssertEqual(button.titleColor(for: .normal), .white)
        XCTAssertEqual(button.titleLabel?.font, .systemFont(ofSize: 16))
        XCTAssertEqual(button.backgroundColor, .blue)
        XCTAssertEqual(button.layer.cornerRadius, 8)
    }
    
    func testUIViewChainableModifiers() {
        let view = UIView()
            .background(.green)
            .cornerRadius(12)
            .border(.black, width: 2)
            .opacity(0.8)
        
        XCTAssertEqual(view.backgroundColor, .green)
        XCTAssertEqual(view.layer.cornerRadius, 12)
        XCTAssertEqual(view.layer.borderColor, UIColor.black.cgColor)
        XCTAssertEqual(view.layer.borderWidth, 2)
        XCTAssertEqual(view.alpha, 0.8)
    }
    
    func testUIImageViewChainableModifiers() {
        let imageView = UIImageView()
            .aspectRatio(.scaleAspectFill)
            .clipsToBounds(true)
        
        XCTAssertEqual(imageView.contentMode, .scaleAspectFill)
        XCTAssertTrue(imageView.clipsToBounds)
    }
}
