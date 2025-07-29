import XCTest
@testable import Layout

final class SimpleComplexLayoutTests: XCTestCase {
    
    func testComplexLayoutStructure() {
        // 복잡한 레이아웃 구조 테스트 - UIKit 없이
        let complexLayout = createComplexLayout()
        
        // 레이아웃 구조 검증
        XCTAssertNotNil(complexLayout)
        
        // 레이아웃 계산 시뮬레이션
        let bounds = CGRect(x: 0, y: 0, width: 400, height: 600)
        let result = simulateLayoutCalculation(complexLayout, in: bounds)
        
        // 결과 검증
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result.totalWidth, 0)
        XCTAssertGreaterThan(result.totalHeight, 0)
        XCTAssertLessThanOrEqual(result.totalWidth, bounds.width)
        
        print("복잡한 레이아웃 구조 테스트 결과:")
        print("- 전체 크기: \(result.totalWidth) x \(result.totalHeight)")
        print("- 컴포넌트 개수: \(result.componentCount)")
        print("- 레이아웃 타입: \(result.layoutType)")
    }
    
    func testNestedLayoutPerformance() {
        // 중첩된 레이아웃 성능 테스트
        let complexLayout = createNestedLayout()
        
        let bounds = CGRect(x: 0, y: 0, width: 500, height: 800)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = simulateLayoutCalculation(complexLayout, in: bounds)
        let endTime = CFAbsoluteTimeGetCurrent()
        
        let executionTime = endTime - startTime
        
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result.totalWidth, 0)
        XCTAssertGreaterThan(result.totalHeight, 0)
        
        print("중첩된 레이아웃 성능 테스트:")
        print("- 실행 시간: \(executionTime * 1000)ms")
        print("- 전체 크기: \(result.totalWidth) x \(result.totalHeight)")
        print("- 컴포넌트 개수: \(result.componentCount)")
        
        // 성능 기준: 1ms 이내
        XCTAssertLessThan(executionTime, 0.001)
    }
    
    func testMixedLayoutTypes() {
        // 다양한 레이아웃 타입 혼합 테스트
        let mixedLayout = createMixedLayout()
        
        let bounds = CGRect(x: 0, y: 0, width: 400, height: 600)
        let result = simulateLayoutCalculation(mixedLayout, in: bounds)
        
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result.totalWidth, 0)
        XCTAssertGreaterThan(result.totalHeight, 0)
        
        print("혼합 레이아웃 타입 테스트:")
        print("- 전체 크기: \(result.totalWidth) x \(result.totalHeight)")
        print("- 레이아웃 타입: \(result.layoutType)")
        print("- 컴포넌트 개수: \(result.componentCount)")
        
        // 다양한 레이아웃 타입이 포함되었는지 확인
        XCTAssertTrue(result.layoutType.contains("VStack"))
        XCTAssertTrue(result.layoutType.contains("HStack"))
        XCTAssertTrue(result.layoutType.contains("ZStack"))
    }
    
    // MARK: - 헬퍼 메서드들
    
    private func createComplexLayout() -> ComplexLayoutNode {
        return ComplexLayoutNode(
            type: "VStack",
            children: [
                ComplexLayoutNode(type: "HStack", children: [
                    ComplexLayoutNode(type: "View", size: CGSize(width: 50, height: 50)),
                    ComplexLayoutNode(type: "VStack", children: [
                        ComplexLayoutNode(type: "View", size: CGSize(width: 100, height: 20)),
                        ComplexLayoutNode(type: "View", size: CGSize(width: 80, height: 16))
                    ]),
                    ComplexLayoutNode(type: "Spacer"),
                    ComplexLayoutNode(type: "View", size: CGSize(width: 60, height: 30))
                ]),
                ComplexLayoutNode(type: "HStack", children: [
                    ComplexLayoutNode(type: "View", size: CGSize(width: 80, height: 80)),
                    ComplexLayoutNode(type: "View", size: CGSize(width: 80, height: 80)),
                    ComplexLayoutNode(type: "View", size: CGSize(width: 80, height: 80))
                ]),
                ComplexLayoutNode(type: "VStack", children: [
                    ComplexLayoutNode(type: "View", size: CGSize(width: 200, height: 24)),
                    ComplexLayoutNode(type: "HStack", children: [
                        ComplexLayoutNode(type: "View", size: CGSize(width: 60, height: 60)),
                        ComplexLayoutNode(type: "View", size: CGSize(width: 60, height: 60)),
                        ComplexLayoutNode(type: "View", size: CGSize(width: 60, height: 60))
                    ])
                ]),
                ComplexLayoutNode(type: "ZStack", children: [
                    ComplexLayoutNode(type: "View", size: CGSize(width: 300, height: 80)),
                    ComplexLayoutNode(type: "VStack", children: [
                        ComplexLayoutNode(type: "View", size: CGSize(width: 100, height: 20)),
                        ComplexLayoutNode(type: "View", size: CGSize(width: 100, height: 20))
                    ])
                ])
            ]
        )
    }
    
    private func createNestedLayout() -> ComplexLayoutNode {
        return ComplexLayoutNode(
            type: "VStack",
            children: [
                ComplexLayoutNode(type: "HStack", children: [
                    ComplexLayoutNode(type: "VStack", children: [
                        ComplexLayoutNode(type: "View", size: CGSize(width: 40, height: 40)),
                        ComplexLayoutNode(type: "View", size: CGSize(width: 40, height: 20))
                    ]),
                    ComplexLayoutNode(type: "VStack", children: [
                        ComplexLayoutNode(type: "View", size: CGSize(width: 60, height: 30)),
                        ComplexLayoutNode(type: "HStack", children: [
                            ComplexLayoutNode(type: "View", size: CGSize(width: 25, height: 25)),
                            ComplexLayoutNode(type: "View", size: CGSize(width: 25, height: 25))
                        ])
                    ])
                ]),
                ComplexLayoutNode(type: "ZStack", children: [
                    ComplexLayoutNode(type: "View", size: CGSize(width: 200, height: 100)),
                    ComplexLayoutNode(type: "VStack", children: [
                        ComplexLayoutNode(type: "View", size: CGSize(width: 80, height: 30)),
                        ComplexLayoutNode(type: "HStack", children: [
                            ComplexLayoutNode(type: "View", size: CGSize(width: 30, height: 30)),
                            ComplexLayoutNode(type: "View", size: CGSize(width: 30, height: 30)),
                            ComplexLayoutNode(type: "View", size: CGSize(width: 30, height: 30))
                        ])
                    ])
                ])
            ]
        )
    }
    
    private func createMixedLayout() -> ComplexLayoutNode {
        return ComplexLayoutNode(
            type: "VStack",
            children: [
                ComplexLayoutNode(type: "HStack", children: [
                    ComplexLayoutNode(type: "View", size: CGSize(width: 50, height: 50)),
                    ComplexLayoutNode(type: "Spacer"),
                    ComplexLayoutNode(type: "View", size: CGSize(width: 80, height: 40))
                ]),
                ComplexLayoutNode(type: "ZStack", children: [
                    ComplexLayoutNode(type: "View", size: CGSize(width: 300, height: 150)),
                    ComplexLayoutNode(type: "VStack", children: [
                        ComplexLayoutNode(type: "View", size: CGSize(width: 100, height: 40)),
                        ComplexLayoutNode(type: "HStack", children: [
                            ComplexLayoutNode(type: "View", size: CGSize(width: 40, height: 40)),
                            ComplexLayoutNode(type: "View", size: CGSize(width: 40, height: 40)),
                            ComplexLayoutNode(type: "View", size: CGSize(width: 40, height: 40))
                        ])
                    ])
                ]),
                ComplexLayoutNode(type: "HStack", children: [
                    ComplexLayoutNode(type: "View", size: CGSize(width: 100, height: 60)),
                    ComplexLayoutNode(type: "View", size: CGSize(width: 100, height: 60)),
                    ComplexLayoutNode(type: "View", size: CGSize(width: 100, height: 60))
                ])
            ]
        )
    }
    
    private func simulateLayoutCalculation(_ layout: ComplexLayoutNode, in bounds: CGRect) -> LayoutSimulationResult {
        var totalWidth: CGFloat = 0
        var totalHeight: CGFloat = 0
        var componentCount = 0
        
        func calculateNode(_ node: ComplexLayoutNode, x: CGFloat, y: CGFloat) -> (width: CGFloat, height: CGFloat) {
            componentCount += 1
            
            switch node.type {
            case "VStack":
                var maxWidth: CGFloat = 0
                var currentHeight: CGFloat = 0
                
                for child in node.children {
                    let (childWidth, childHeight) = calculateNode(child, x: x, y: y + currentHeight)
                    maxWidth = max(maxWidth, childWidth)
                    currentHeight += childHeight
                }
                
                return (maxWidth, currentHeight)
                
            case "HStack":
                var currentWidth: CGFloat = 0
                var maxHeight: CGFloat = 0
                
                for child in node.children {
                    let (childWidth, childHeight) = calculateNode(child, x: x + currentWidth, y: y)
                    currentWidth += childWidth
                    maxHeight = max(maxHeight, childHeight)
                }
                
                return (currentWidth, maxHeight)
                
            case "ZStack":
                var maxWidth: CGFloat = 0
                var maxHeight: CGFloat = 0
                
                for child in node.children {
                    let (childWidth, childHeight) = calculateNode(child, x: x, y: y)
                    maxWidth = max(maxWidth, childWidth)
                    maxHeight = max(maxHeight, childHeight)
                }
                
                return (maxWidth, maxHeight)
                
            case "Spacer":
                return (bounds.width - x, 0)
                
            case "View":
                return (node.size?.width ?? 0, node.size?.height ?? 0)
                
            default:
                return (0, 0)
            }
        }
        
        let (width, height) = calculateNode(layout, x: 0, y: 0)
        totalWidth = width
        totalHeight = height
        
        return LayoutSimulationResult(
            totalWidth: totalWidth,
            totalHeight: totalHeight,
            componentCount: componentCount,
            layoutType: layout.type
        )
    }
}

// MARK: - 헬퍼 구조체들

struct ComplexLayoutNode {
    let type: String
    let children: [ComplexLayoutNode]
    let size: CGSize?
    
    init(type: String, children: [ComplexLayoutNode] = [], size: CGSize? = nil) {
        self.type = type
        self.children = children
        self.size = size
    }
}

struct LayoutSimulationResult {
    let totalWidth: CGFloat
    let totalHeight: CGFloat
    let componentCount: Int
    let layoutType: String
} 