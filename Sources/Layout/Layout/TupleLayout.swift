import UIKit

/// A layout that represents a tuple of layouts
/// Supports both vertical and horizontal arrangement based on context
public struct TupleLayout: Layout {
    public typealias Body = Never
    
    private let layouts: [any Layout]
    private let arrangements: [Arrangement]
    
    public enum Arrangement {
        case vertical, horizontal, independent, overlay
    }
    
    public init(_ layouts: [any Layout], arrangements: [Arrangement] = []) {
        self.layouts = layouts
        
        // arrangements 배열이 비어있거나 layouts보다 짧으면 기본값으로 채움
        if arrangements.isEmpty {
            self.arrangements = Array(repeating: .vertical, count: layouts.count)
        } else if arrangements.count < layouts.count {
            self.arrangements = arrangements + Array(repeating: .vertical, count: layouts.count - arrangements.count)
        } else {
            self.arrangements = Array(arrangements.prefix(layouts.count))
        }
    }
    
    // 기존 호환성을 위한 convenience initializer
    public init(_ layouts: [any Layout], arrangement: Arrangement = .vertical) {
        self.layouts = layouts
        self.arrangements = Array(repeating: arrangement, count: layouts.count)
        print("🔧 TupleLayout - init with arrangement: \(arrangement), layouts count: \(layouts.count)")
    }
    
    public var body: Never { neverLayout("TupleLayout") }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        print("🔧 TupleLayout - calculateLayout with arrangements: \(arrangements)")
        
        // 모든 레이아웃이 independent이면 independent 처리
        if arrangements.allSatisfy({ $0 == .independent }) {
            return calculateIndependentLayout(in: bounds)
        }
        
        // overlay가 있으면 overlay 처리
        if arrangements.contains(.overlay) {
            return calculateOverlayLayout(in: bounds)
        }
        
            // 컨텍스트를 고려한 arrangement 결정
    // VStack 내부에서는 vertical arrangement 사용
    // HStack 내부에서는 horizontal arrangement 사용
    // 독립적인 컨텍스트에서는 첫 번째 arrangement 사용
    
    // 현재 컨텍스트를 감지하기 위해 호출 스택을 확인
    let contextArrangement = detectContextArrangement()
    print("🔧 TupleLayout - detected context arrangement: \(String(describing: contextArrangement))")
    
    // 컨텍스트 arrangement가 있으면 그것을 사용, 없으면 첫 번째 arrangement 사용
    let effectiveArrangement = contextArrangement ?? (arrangements.first ?? .vertical)
    print("🔧 TupleLayout - using effectiveArrangement: \(effectiveArrangement)")
        
        switch effectiveArrangement {
        case .vertical:
            return calculateVerticalLayout(in: bounds)
        case .horizontal:
            return calculateHorizontalLayout(in: bounds)
        case .independent:
            return calculateIndependentLayout(in: bounds)
        case .overlay:
            return calculateOverlayLayout(in: bounds)
        }
    }
    
    private func calculateVerticalLayout(in bounds: CGRect) -> LayoutResult {
        var allFrames: [UIView: CGRect] = [:]
        var currentY: CGFloat = 0
        var maxWidth: CGFloat = 0
        
        print("🔧 TupleLayout - calculateVerticalLayout - layouts count: \(layouts.count)")
        
        for (index, layout) in layouts.enumerated() {
            let arrangement = arrangements[index]
            print("🔧 TupleLayout - Processing layout \(index): \(type(of: layout)), arrangement: \(arrangement)")
            
            switch arrangement {
            case .vertical, .independent:
                let availableHeight = max(0, bounds.height - currentY)
                let result = layout.calculateLayout(in: CGRect(x: 0, y: currentY, width: bounds.width, height: availableHeight))
                
                for (view, frame) in result.frames {
                    var adjustedFrame = frame
                    adjustedFrame.origin.y += currentY
                    allFrames[view] = adjustedFrame
                }
                
                currentY += result.totalSize.height
                maxWidth = max(maxWidth, result.totalSize.width)
                
            case .horizontal:
                // horizontal arrangement는 현재 위치에서 가로로 배치
                let availableHeight = max(0, bounds.height - currentY)
                let result = layout.calculateLayout(in: CGRect(x: 0, y: currentY, width: bounds.width, height: availableHeight))
                
                for (view, frame) in result.frames {
                    var adjustedFrame = frame
                    adjustedFrame.origin.y += currentY
                    allFrames[view] = adjustedFrame
                }
                
                currentY += result.totalSize.height
                maxWidth = max(maxWidth, result.totalSize.width)
                
            case .overlay:
                // overlay는 현재 위치에 오버레이
                let availableHeight = max(0, bounds.height - currentY)
                let result = layout.calculateLayout(in: CGRect(x: 0, y: currentY, width: bounds.width, height: availableHeight))
                
                for (view, frame) in result.frames {
                    var adjustedFrame = frame
                    adjustedFrame.origin.y += currentY
                    allFrames[view] = adjustedFrame
                }
                
                maxWidth = max(maxWidth, result.totalSize.width)
            }
        }
        
        // 최소 크기 보장
        let totalHeight = max(currentY, 100)
        let totalWidth = max(maxWidth, 200)
        
        print("🔧 TupleLayout - calculateVerticalLayout - totalSize: \(CGSize(width: totalWidth, height: totalHeight))")
        return LayoutResult(frames: allFrames, totalSize: CGSize(width: totalWidth, height: totalHeight))
    }
    
    private func calculateHorizontalLayout(in bounds: CGRect) -> LayoutResult {
        var allFrames: [UIView: CGRect] = [:]
        var currentX: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        for (index, layout) in layouts.enumerated() {
            let arrangement = arrangements[index]
            
            switch arrangement {
            case .horizontal, .independent:
                let result = layout.calculateLayout(in: CGRect(x: currentX, y: 0, width: bounds.width - currentX, height: bounds.height))
                
                for (view, frame) in result.frames {
                    var adjustedFrame = frame
                    adjustedFrame.origin.x += currentX
                    allFrames[view] = adjustedFrame
                }
                
                currentX += result.totalSize.width
                maxHeight = max(maxHeight, result.totalSize.height)
                
            case .vertical:
                // vertical arrangement는 현재 위치에서 세로로 배치
                let result = layout.calculateLayout(in: CGRect(x: currentX, y: 0, width: bounds.width - currentX, height: bounds.height))
                
                for (view, frame) in result.frames {
                    var adjustedFrame = frame
                    adjustedFrame.origin.x += currentX
                    allFrames[view] = adjustedFrame
                }
                
                currentX += result.totalSize.width
                maxHeight = max(maxHeight, result.totalSize.height)
                
            case .overlay:
                // overlay는 현재 위치에 오버레이
                let result = layout.calculateLayout(in: CGRect(x: currentX, y: 0, width: bounds.width - currentX, height: bounds.height))
                
                for (view, frame) in result.frames {
                    var adjustedFrame = frame
                    adjustedFrame.origin.x += currentX
                    allFrames[view] = adjustedFrame
                }
                
                maxHeight = max(maxHeight, result.totalSize.height)
            }
        }
        
        return LayoutResult(frames: allFrames, totalSize: CGSize(width: currentX, height: maxHeight))
    }
    
    private func calculateIndependentLayout(in bounds: CGRect) -> LayoutResult {
        var allFrames: [UIView: CGRect] = [:]
        var maxWidth: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        for layout in layouts {
            let result = layout.calculateLayout(in: bounds)
            
            for (view, frame) in result.frames {
                allFrames[view] = frame
            }
            
            maxWidth = max(maxWidth, result.totalSize.width)
            maxHeight = max(maxHeight, result.totalSize.height)
        }
        
        return LayoutResult(frames: allFrames, totalSize: CGSize(width: maxWidth, height: maxHeight))
    }
    
    private func calculateOverlayLayout(in bounds: CGRect) -> LayoutResult {
        var allFrames: [UIView: CGRect] = [:]
        var maxWidth: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        for layout in layouts {
            let result = layout.calculateLayout(in: bounds)
            
            for (view, frame) in result.frames {
                allFrames[view] = frame
            }
            
            maxWidth = max(maxWidth, result.totalSize.width)
            maxHeight = max(maxHeight, result.totalSize.height)
        }
        
        return LayoutResult(frames: allFrames, totalSize: CGSize(width: maxWidth, height: maxHeight))
    }
    
    public func extractViews() -> [UIView] {
        return layouts.flatMap { $0.extractViews() }
    }
    
    // 내부 레이아웃들을 반환하는 메서드
    public func getLayouts() -> [any Layout] {
        return layouts
    }
    
    // arrangement 배열을 반환하는 메서드
    public func getArrangements() -> [Arrangement] {
        return arrangements
    }
    
    // 컨텍스트를 감지하여 적절한 arrangement를 반환하는 메서드
    private func detectContextArrangement() -> Arrangement? {
        // 호출 스택을 통해 컨텍스트를 감지
        let callStack = Thread.callStackSymbols
        print("🔧 TupleLayout - callStack count: \(callStack.count)")
        
        // VStack이나 HStack의 calculateLayout이 호출 스택에 있는지 확인
        for symbol in callStack {
            if symbol.contains("VStack") && symbol.contains("calculateLayout") {
                print("🔧 TupleLayout - detected VStack context")
                return .vertical
            }
            if symbol.contains("HStack") && symbol.contains("calculateLayout") {
                print("🔧 TupleLayout - detected HStack context")
                return .horizontal
            }
        }
        
        print("🔧 TupleLayout - no specific context detected")
        return nil
    }
}
