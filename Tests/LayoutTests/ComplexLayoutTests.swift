import XCTest
@testable import Layout

final class ComplexLayoutTests: XCTestCase {
    
    func testComplexVStackLayout() {
        // Complex VStack test - without UIKit
        let complexLayout = VStack(spacing: 10) {
            // First section: Header
            HStack(spacing: 8) {
                createMockLayout(width: 40, height: 40, color: "blue")
                VStack(spacing: 4) {
                    createMockLayout(width: 100, height: 20, color: "title")
                    createMockLayout(width: 80, height: 16, color: "subtitle")
                }
                Spacer()
                createMockLayout(width: 60, height: 30, color: "button")
            }
            
            // Second section: Stats cards
            HStack(spacing: 12) {
                createStatCard(title: "Followers", value: "1,234", color: "blue")
                createStatCard(title: "Following", value: "567", color: "green")
                createStatCard(title: "Posts", value: "89", color: "orange")
            }
            
            // Third section: Gallery
            VStack(spacing: 8) {
                createMockLayout(width: 200, height: 24, color: "section_title")
                createPhotoGrid()
            }
            
            // Fourth section: Action buttons
            HStack(spacing: 12) {
                createMockLayout(width: 120, height: 44, color: "primary_button")
                createMockLayout(width: 100, height: 44, color: "secondary_button")
            }
            
            // Fifth section: Nested ZStack
            ZStack {
                createMockLayout(width: 300, height: 80, color: "background")
                VStack(spacing: 8) {
                    createIconLabel(icon: "⭐️", text: "Premium Feature")
                    createIconLabel(icon: "🔒", text: "Security Settings")
                }
                .padding(16)
            }
            .size(height: 80)
        }
        .padding(16)
        
        // Calculate layout
        let bounds = CGRect(x: 0, y: 0, width: 350, height: 600)
        let result = complexLayout.calculateLayout(in: bounds)
        
        // Basic validation
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result.totalSize.width, 0)
        XCTAssertGreaterThan(result.totalSize.height, 0)
        XCTAssertLessThanOrEqual(result.totalSize.width, bounds.width)
        
        // Frame count validation (expected number of views)
        let expectedViewCount = 15 // Header(4) + Stats(6) + Gallery(7) + Buttons(2) + ZStack(3) + Others
        XCTAssertGreaterThanOrEqual(result.frames.count, expectedViewCount)
        
        print("Complex VStack layout result:")
        print("- Total size: \(result.totalSize)")
        print("- Frame count: \(result.frames.count)")
        
        // Validate each section
        validateHeaderSection(result)
        validateStatsSection(result)
        validateGallerySection(result)
        validateActionSection(result)
        validateZStackSection(result)
    }
    
    func testComplexHStackLayout() {
        // Complex HStack test
        let complexLayout = HStack(spacing: 16) {
            // Left panel
            VStack(spacing: 12) {
                createMockLayout(width: 80, height: 80, color: "profile")
                createMockLayout(width: 80, height: 20, color: "name")
                createMockLayout(width: 80, height: 16, color: "status")
            }
            
            // Center panel
            VStack(spacing: 8) {
                createMockLayout(width: 120, height: 24, color: "title")
                createMockLayout(width: 120, height: 16, color: "description")
                HStack(spacing: 8) {
                    createMockLayout(width: 50, height: 20, color: "tag1")
                    createMockLayout(width: 50, height: 20, color: "tag2")
                }
            }
            
            // Right panel
            VStack(spacing: 8) {
                createMockLayout(width: 60, height: 30, color: "action1")
                createMockLayout(width: 60, height: 30, color: "action2")
            }
        }
        .padding(16)
        
        let bounds = CGRect(x: 0, y: 0, width: 400, height: 200)
        let result = complexLayout.calculateLayout(in: bounds)
        
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result.totalSize.width, 0)
        XCTAssertGreaterThan(result.totalSize.height, 0)
        
        print("Complex HStack layout result:")
        print("- Total size: \(result.totalSize)")
        print("- Frame count: \(result.frames.count)")
    }
    
    func testNestedZStackLayout() {
        // Nested ZStack test
        let complexLayout = ZStack {
            // Background
            createMockLayout(width: 300, height: 200, color: "background")
            
            // Center content
            VStack(spacing: 12) {
                createMockLayout(width: 100, height: 40, color: "title")
                HStack(spacing: 16) {
                    createMockLayout(width: 60, height: 60, color: "icon1")
                    createMockLayout(width: 60, height: 60, color: "icon2")
                    createMockLayout(width: 60, height: 60, color: "icon3")
                }
            }
            
            // Overlay
            ZStack {
                createMockLayout(width: 80, height: 30, color: "overlay")
                createMockLayout(width: 40, height: 20, color: "badge")
            }
        }
        .size(width: 300, height: 200)
        
        let bounds = CGRect(x: 0, y: 0, width: 300, height: 200)
        let result = complexLayout.calculateLayout(in: bounds)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result.totalSize.width, 300)
        XCTAssertEqual(result.totalSize.height, 200)
        
        print("Nested ZStack layout result:")
        print("- Total size: \(result.totalSize)")
        print("- Frame count: \(result.frames.count)")
    }
    
    func testMixedLayoutPerformance() {
        // Performance test: Measure calculation time of complex layout
        let complexLayout = createComplexMixedLayout()
        
        let bounds = CGRect(x: 0, y: 0, width: 400, height: 800)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = complexLayout.calculateLayout(in: bounds)
        let endTime = CFAbsoluteTimeGetCurrent()
        
        let executionTime = endTime - startTime
        
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result.totalSize.width, 0)
        XCTAssertGreaterThan(result.totalSize.height, 0)
        
        print("Complex layout performance test:")
        print("- Execution time: \(executionTime * 1000)ms")
        print("- Total size: \(result.totalSize)")
        print("- Frame count: \(result.frames.count)")
        
        // Performance criteria: within 10ms
        XCTAssertLessThan(executionTime, 0.01)
    }
    
    // MARK: - Helper Methods
    
    private func createMockLayout(width: CGFloat, height: CGFloat, color: String) -> MockLayout {
        return MockLayout(size: CGSize(width: width, height: height), color: color)
    }
    
    private func createStatCard(title: String, value: String, color: String) -> VStack {
        return VStack(spacing: 4) {
            createMockLayout(width: 60, height: 24, color: "\(color)_value")
            createMockLayout(width: 60, height: 16, color: "\(color)_title")
        }
    }
    
    private func createPhotoGrid() -> VStack {
        return VStack(spacing: 8) {
            HStack(spacing: 8) {
                createMockLayout(width: 60, height: 60, color: "photo1")
                createMockLayout(width: 60, height: 60, color: "photo2")
                createMockLayout(width: 60, height: 60, color: "photo3")
            }
            HStack(spacing: 8) {
                createMockLayout(width: 60, height: 60, color: "photo4")
                createMockLayout(width: 60, height: 60, color: "photo5")
                createMockLayout(width: 60, height: 60, color: "photo6")
            }
        }
    }
    
    private func createIconLabel(icon: String, text: String) -> HStack {
        return HStack(spacing: 8) {
            createMockLayout(width: 20, height: 20, color: "icon")
            createMockLayout(width: 80, height: 20, color: "text")
        }
    }
    
    private func createComplexMixedLayout() -> VStack {
        return VStack(spacing: 16) {
            // Header
            HStack(spacing: 12) {
                createMockLayout(width: 50, height: 50, color: "avatar")
                VStack(spacing: 4) {
                    createMockLayout(width: 120, height: 20, color: "name")
                    createMockLayout(width: 100, height: 16, color: "status")
                }
                Spacer()
                createMockLayout(width: 80, height: 32, color: "menu")
            }
            
            // Content sections
            ForEach(0..<5) { index in
                VStack(spacing: 8) {
                    self.createMockLayout(width: 300, height: 24, color: "section_\(index)")
                    HStack(spacing: 8) {
                        ForEach(0..<3) { subIndex in
                            self.createMockLayout(width: 80, height: 60, color: "item_\(index)_\(subIndex)")
                        }
                    }
                }
            }
            
            // Footer
            HStack(spacing: 12) {
                createMockLayout(width: 100, height: 44, color: "action1")
                createMockLayout(width: 100, height: 44, color: "action2")
                Spacer()
                createMockLayout(width: 60, height: 44, color: "action3")
            }
        }
    }
    
    // MARK: - Validation Methods
    
    private func validateHeaderSection(_ result: LayoutResult) {
        // Header section validation logic
        let headerFrames = result.frames.filter { _, frame in
            frame.height <= 50 && frame.width > 0
        }
        XCTAssertGreaterThanOrEqual(headerFrames.count, 4)
    }
    
    private func validateStatsSection(_ result: LayoutResult) {
        // Stats section validation logic
        let statsFrames = result.frames.filter { _, frame in
            frame.height <= 80 && frame.width <= 100
        }
        XCTAssertGreaterThanOrEqual(statsFrames.count, 6)
    }
    
    private func validateGallerySection(_ result: LayoutResult) {
        // Gallery section validation logic
        let galleryFrames = result.frames.filter { _, frame in
            frame.width == 60 && frame.height == 60
        }
        XCTAssertGreaterThanOrEqual(galleryFrames.count, 6)
    }
    
    private func validateActionSection(_ result: LayoutResult) {
        // Action section validation logic
        let actionFrames = result.frames.filter { _, frame in
            frame.height == 44 && frame.width >= 80
        }
        XCTAssertGreaterThanOrEqual(actionFrames.count, 2)
    }
    
    private func validateZStackSection(_ result: LayoutResult) {
        // ZStack section validation logic
        let zstackFrames = result.frames.filter { _, frame in
            frame.height <= 80 && frame.width > 0
        }
        XCTAssertGreaterThanOrEqual(zstackFrames.count, 3)
    }
}

// MARK: - Mock Layout

class MockLayout: Layout {
    public typealias Body = Never
    
    private let size: CGSize
    private let color: String
    private let mockView: MockView
    
    init(size: CGSize, color: String) {
        self.size = size
        self.color = color
        self.mockView = MockView(frame: CGRect(origin: .zero, size: size))
        self.mockView.colorName = color
    }
    
    public var body: Never {
        neverLayout("MockLayout")
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        let frame = CGRect(origin: .zero, size: size)
        return LayoutResult(frames: [mockView: frame], totalSize: size)
    }
    
    public func extractViews() -> [UIView] {
        return [mockView]
    }
}

// MARK: - Mock View

class MockView: UIView {
    var colorName: String = "default"
} 
