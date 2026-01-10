import XCTest
import UIKit
@testable import Layout

@MainActor
final class GeometryReaderTests: XCTestCase {
    
    var container: UIView!
    var testView: UIView!
    
    override func setUp() {
        super.setUp()
        // @MainActor class, so setUp() already runs on MainActor
        container = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 400))
        testView = UIView(frame: .zero)
    }
    
    override func tearDown() {
        // @MainActor class, so tearDown() already runs on MainActor
        container = nil
        testView = nil
        super.tearDown()
    }
    
    // MARK: - GeometryReader Basic Tests
    
    func testGeometryReaderCreation() {
        let geometryReader = GeometryReader { proxy in
            self.testView.layout()
                .size(width: proxy.size.width * 0.8, height: proxy.size.height * 0.5)
        }
        
        XCTAssertNotNil(geometryReader)
    }
    
    func testGeometryReaderSizeAccess() {
        let expectedSize = CGSize(width: 300, height: 400)
        var capturedSize: CGSize?
        
        let geometryReader = GeometryReader { proxy in
            capturedSize = proxy.size
            return self.testView.layout()
        }
        
        // Set frame and trigger layout to create proxy
        geometryReader.frame = CGRect(origin: .zero, size: expectedSize)
        geometryReader.layoutIfNeeded()
        
        XCTAssertEqual(capturedSize, expectedSize)
    }
    
    func testGeometryReaderBounds() {
        var capturedBounds: CGRect?
        
        let geometryReader = GeometryReader { proxy in
            capturedBounds = proxy.bounds
            return self.testView.layout()
        }
        
        let bounds = CGRect(x: 0, y: 0, width: 300, height: 400)
        geometryReader.frame = bounds
        geometryReader.layoutIfNeeded()
        
        XCTAssertEqual(capturedBounds, CGRect(origin: .zero, size: bounds.size))
    }
    
    // MARK: - GeometryReader Dynamic Sizing Tests
    
    func testGeometryReaderProportionalSizing() {
        let geometryReader = GeometryReader { proxy in
            self.testView.layout()
                .size(width: proxy.size.width * 0.5, height: proxy.size.height * 0.3)
        }
        
        let bounds = CGRect(x: 0, y: 0, width: 300, height: 400)
        geometryReader.frame = bounds
        geometryReader.layoutIfNeeded()
        
        let result = geometryReader.calculateLayout(in: bounds)
        
        guard let frame = result.frames[testView] else {
            XCTFail("Frame not found for testView. Frames: \(result.frames.keys)")
            return
        }
        
        XCTAssertEqual(frame.width, 150, accuracy: 0.1)
        XCTAssertEqual(frame.height, 120, accuracy: 0.1)
    }
    
    func testGeometryReaderWithSafeAreaInsets() {
        var capturedInsets: UIEdgeInsets?
        
        let geometryReader = GeometryReader { proxy in
            capturedInsets = proxy.safeAreaInsets
            return self.testView.layout()
        }
        
        let bounds = CGRect(x: 0, y: 0, width: 300, height: 400)
        geometryReader.frame = bounds
        geometryReader.layoutIfNeeded()
        
        XCTAssertNotNil(capturedInsets)
    }
    
    // MARK: - GeometryReader Imperative Style Tests
    
    func testGeometryReaderImperativeStyle() {
        let geometryReader = GeometryReader { proxy, container in
            let view = UIView()
            view.frame = CGRect(x: 10, y: 10, width: proxy.size.width - 20, height: 50)
            container.addSubview(view)
        }
        
        let bounds = CGRect(x: 0, y: 0, width: 300, height: 400)
        geometryReader.frame = bounds
        geometryReader.layoutIfNeeded()
        
        let result = geometryReader.calculateLayout(in: bounds)
        
        XCTAssertNotNil(result)
        XCTAssertGreaterThanOrEqual(geometryReader.subviews.count, 1)
    }
    
    // MARK: - GeometryReader Coordinate Space Tests
    
    func testGeometryReaderGlobalFrame() {
        var capturedGlobalFrame: CGRect?
        
        let geometryReader = GeometryReader { proxy in
            capturedGlobalFrame = proxy.globalFrame
            return self.testView.layout()
        }
        
        let bounds = CGRect(x: 0, y: 0, width: 300, height: 400)
        geometryReader.frame = bounds
        geometryReader.layoutIfNeeded()
        
        XCTAssertNotNil(capturedGlobalFrame)
        XCTAssertEqual(capturedGlobalFrame?.size, bounds.size)
    }
}
