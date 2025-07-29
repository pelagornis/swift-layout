import XCTest
@testable import Layout

final class ComplexLayoutTests: XCTestCase {
    
    func testComplexVStackLayout() {
        // 복잡한 VStack 테스트 - UIKit 없이
        let complexLayout = VStack(spacing: 10) {
            // 첫 번째 섹션: 헤더
            HStack(spacing: 8) {
                createMockLayout(width: 40, height: 40, color: "blue")
                VStack(spacing: 4) {
                    createMockLayout(width: 100, height: 20, color: "title")
                    createMockLayout(width: 80, height: 16, color: "subtitle")
                }
                Spacer()
                createMockLayout(width: 60, height: 30, color: "button")
            }
            
            // 두 번째 섹션: 통계 카드들
            HStack(spacing: 12) {
                createStatCard(title: "팔로워", value: "1,234", color: "blue")
                createStatCard(title: "팔로잉", value: "567", color: "green")
                createStatCard(title: "게시물", value: "89", color: "orange")
            }
            
            // 세 번째 섹션: 갤러리
            VStack(spacing: 8) {
                createMockLayout(width: 200, height: 24, color: "section_title")
                createPhotoGrid()
            }
            
            // 네 번째 섹션: 액션 버튼들
            HStack(spacing: 12) {
                createMockLayout(width: 120, height: 44, color: "primary_button")
                createMockLayout(width: 100, height: 44, color: "secondary_button")
            }
            
            // 다섯 번째 섹션: 중첩된 ZStack
            ZStack {
                createMockLayout(width: 300, height: 80, color: "background")
                VStack(spacing: 8) {
                    createIconLabel(icon: "⭐️", text: "프리미엄 기능")
                    createIconLabel(icon: "🔒", text: "보안 설정")
                }
                .padding(16)
            }
            .frame(height: 80)
        }
        .padding(16)
        
        // 레이아웃 계산
        let bounds = CGRect(x: 0, y: 0, width: 350, height: 600)
        let result = complexLayout.calculateLayout(in: bounds)
        
        // 기본 검증
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result.totalSize.width, 0)
        XCTAssertGreaterThan(result.totalSize.height, 0)
        XCTAssertLessThanOrEqual(result.totalSize.width, bounds.width)
        
        // 프레임 개수 검증 (예상되는 뷰 개수)
        let expectedViewCount = 15 // 헤더(4) + 통계(6) + 갤러리(7) + 버튼(2) + ZStack(3) + 기타
        XCTAssertGreaterThanOrEqual(result.frames.count, expectedViewCount)
        
        print("복잡한 VStack 레이아웃 결과:")
        print("- 전체 크기: \(result.totalSize)")
        print("- 프레임 개수: \(result.frames.count)")
        
        // 각 섹션별 검증
        validateHeaderSection(result)
        validateStatsSection(result)
        validateGallerySection(result)
        validateActionSection(result)
        validateZStackSection(result)
    }
    
    func testComplexHStackLayout() {
        // 복잡한 HStack 테스트
        let complexLayout = HStack(spacing: 16) {
            // 왼쪽 패널
            VStack(spacing: 12) {
                createMockLayout(width: 80, height: 80, color: "profile")
                createMockLayout(width: 80, height: 20, color: "name")
                createMockLayout(width: 80, height: 16, color: "status")
            }
            
            // 중앙 패널
            VStack(spacing: 8) {
                createMockLayout(width: 120, height: 24, color: "title")
                createMockLayout(width: 120, height: 16, color: "description")
                HStack(spacing: 8) {
                    createMockLayout(width: 50, height: 20, color: "tag1")
                    createMockLayout(width: 50, height: 20, color: "tag2")
                }
            }
            
            // 오른쪽 패널
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
        
        print("복잡한 HStack 레이아웃 결과:")
        print("- 전체 크기: \(result.totalSize)")
        print("- 프레임 개수: \(result.frames.count)")
    }
    
    func testNestedZStackLayout() {
        // 중첩된 ZStack 테스트
        let complexLayout = ZStack {
            // 배경
            createMockLayout(width: 300, height: 200, color: "background")
            
            // 중앙 콘텐츠
            VStack(spacing: 12) {
                createMockLayout(width: 100, height: 40, color: "title")
                HStack(spacing: 16) {
                    createMockLayout(width: 60, height: 60, color: "icon1")
                    createMockLayout(width: 60, height: 60, color: "icon2")
                    createMockLayout(width: 60, height: 60, color: "icon3")
                }
            }
            
            // 오버레이
            ZStack {
                createMockLayout(width: 80, height: 30, color: "overlay")
                createMockLayout(width: 40, height: 20, color: "badge")
            }
            .offset(x: 100, y: -50)
        }
        .frame(width: 300, height: 200)
        
        let bounds = CGRect(x: 0, y: 0, width: 300, height: 200)
        let result = complexLayout.calculateLayout(in: bounds)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result.totalSize.width, 300)
        XCTAssertEqual(result.totalSize.height, 200)
        
        print("중첩된 ZStack 레이아웃 결과:")
        print("- 전체 크기: \(result.totalSize)")
        print("- 프레임 개수: \(result.frames.count)")
    }
    
    func testMixedLayoutPerformance() {
        // 성능 테스트: 복잡한 레이아웃의 계산 시간 측정
        let complexLayout = createComplexMixedLayout()
        
        let bounds = CGRect(x: 0, y: 0, width: 400, height: 800)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = complexLayout.calculateLayout(in: bounds)
        let endTime = CFAbsoluteTimeGetCurrent()
        
        let executionTime = endTime - startTime
        
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result.totalSize.width, 0)
        XCTAssertGreaterThan(result.totalSize.height, 0)
        
        print("복잡한 레이아웃 성능 테스트:")
        print("- 실행 시간: \(executionTime * 1000)ms")
        print("- 전체 크기: \(result.totalSize)")
        print("- 프레임 개수: \(result.frames.count)")
        
        // 성능 기준: 10ms 이내
        XCTAssertLessThan(executionTime, 0.01)
    }
    
    // MARK: - 헬퍼 메서드들
    
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
            // 헤더
            HStack(spacing: 12) {
                createMockLayout(width: 50, height: 50, color: "avatar")
                VStack(spacing: 4) {
                    createMockLayout(width: 120, height: 20, color: "name")
                    createMockLayout(width: 100, height: 16, color: "status")
                }
                Spacer()
                createMockLayout(width: 80, height: 32, color: "menu")
            }
            
            // 콘텐츠 섹션들
            ForEach(0..<5) { index in
                VStack(spacing: 8) {
                    createMockLayout(width: 300, height: 24, color: "section_\(index)")
                    HStack(spacing: 8) {
                        ForEach(0..<3) { subIndex in
                            createMockLayout(width: 80, height: 60, color: "item_\(index)_\(subIndex)")
                        }
                    }
                }
            }
            
            // 푸터
            HStack(spacing: 12) {
                createMockLayout(width: 100, height: 44, color: "action1")
                createMockLayout(width: 100, height: 44, color: "action2")
                Spacer()
                createMockLayout(width: 60, height: 44, color: "action3")
            }
        }
    }
    
    // MARK: - 검증 메서드들
    
    private func validateHeaderSection(_ result: LayoutResult) {
        // 헤더 섹션 검증 로직
        let headerFrames = result.frames.filter { _, frame in
            frame.height <= 50 && frame.width > 0
        }
        XCTAssertGreaterThanOrEqual(headerFrames.count, 4)
    }
    
    private func validateStatsSection(_ result: LayoutResult) {
        // 통계 섹션 검증 로직
        let statsFrames = result.frames.filter { _, frame in
            frame.height <= 80 && frame.width <= 100
        }
        XCTAssertGreaterThanOrEqual(statsFrames.count, 6)
    }
    
    private func validateGallerySection(_ result: LayoutResult) {
        // 갤러리 섹션 검증 로직
        let galleryFrames = result.frames.filter { _, frame in
            frame.width == 60 && frame.height == 60
        }
        XCTAssertGreaterThanOrEqual(galleryFrames.count, 6)
    }
    
    private func validateActionSection(_ result: LayoutResult) {
        // 액션 섹션 검증 로직
        let actionFrames = result.frames.filter { _, frame in
            frame.height == 44 && frame.width >= 80
        }
        XCTAssertGreaterThanOrEqual(actionFrames.count, 2)
    }
    
    private func validateZStackSection(_ result: LayoutResult) {
        // ZStack 섹션 검증 로직
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
        self.mockView = MockView()
        self.mockView.frame = CGRect(origin: .zero, size: size)
        self.mockView.backgroundColor = color
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

class MockView {
    var frame: CGRect = .zero
    var backgroundColor: String = "default"
} 