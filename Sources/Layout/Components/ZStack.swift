#if canImport(UIKit)
import UIKit
#endif

/// A z-stack layout that overlays child layouts on top of each other.
///
/// ``ZStack`` is equivalent to SwiftUI's ZStack and places all children
/// at the same position with customizable alignment.
///
/// ## Example Usage
///
/// ```swift
/// Overlay(alignment: .topLeading) {
///     backgroundView.layout()
///     overlayLabel.layout()
///     actionButton.layout()
/// }
/// ```
public struct ZStack: Layout {
    public typealias Body = Never
    
    private let children: [any Layout]
    public var alignment: Alignment = .center
    
    public enum Alignment {
        case topLeading, top, topTrailing
        case leading, center, trailing
        case bottomLeading, bottom, bottomTrailing
    }
    
    public init<Content: Layout>(alignment: Alignment = .center, @LayoutBuilder content: () -> Content) {
        let builtContent = content()
        self.children = Self.extractChildren(from: builtContent)
        self.alignment = alignment
    }
    
    private static func extractChildren(from content: any Layout) -> [any Layout] {
        if let tupleLayout = content as? TupleLayout {
            return tupleLayout.getLayouts()
        } else {
            return [content]
        }
    }
    
    public var body: Never { neverLayout("ZStack") }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        var frames: [UIView: CGRect] = [:]
        var maxWidth: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        // 각 자식 레이아웃을 개별적으로 처리
        for child in children {
            let childResult = child.calculateLayout(in: bounds)
            
            // 자식 레이아웃의 전체 크기를 기준으로 배치 위치 계산
            let childBounds = calculateChildBounds(for: childResult.totalSize, in: bounds, alignment: alignment)
            
            // 자식의 모든 뷰를 상대적 위치를 유지하면서 새 위치로 이동
            let offset = calculateOffset(from: childResult, to: childBounds)
            
            for (view, childFrame) in childResult.frames {
                let finalFrame = CGRect(
                    x: childFrame.origin.x + offset.x,
                    y: childFrame.origin.y + offset.y,
                    width: childFrame.width,
                    height: childFrame.height
                )
                
                frames[view] = finalFrame
                maxWidth = max(maxWidth, finalFrame.maxX)
                maxHeight = max(maxHeight, finalFrame.maxY)
            }
        }
        
        let totalSize = CGSize(width: max(maxWidth, bounds.width), height: max(maxHeight, bounds.height))
        return LayoutResult(frames: frames, totalSize: totalSize)
    }
    
    private func calculateChildBounds(for childSize: CGSize, in bounds: CGRect, alignment: Alignment) -> CGRect {
        var childBounds = CGRect(origin: .zero, size: childSize)
        
        switch alignment {
        case .topLeading:
            childBounds.origin = CGPoint(x: bounds.minX, y: bounds.minY)
            
        case .top:
            childBounds.origin = CGPoint(
                x: bounds.midX - childSize.width / 2,
                y: bounds.minY
            )
            
        case .topTrailing:
            childBounds.origin = CGPoint(
                x: bounds.maxX - childSize.width,
                y: bounds.minY
            )
            
        case .leading:
            childBounds.origin = CGPoint(
                x: bounds.minX,
                y: bounds.midY - childSize.height / 2
            )
            
        case .center:
            childBounds.origin = CGPoint(
                x: bounds.midX - childSize.width / 2,
                y: bounds.midY - childSize.height / 2
            )
            
        case .trailing:
            childBounds.origin = CGPoint(
                x: bounds.maxX - childSize.width,
                y: bounds.midY - childSize.height / 2
            )
            
        case .bottomLeading:
            childBounds.origin = CGPoint(
                x: bounds.minX,
                y: bounds.maxY - childSize.height
            )
            
        case .bottom:
            childBounds.origin = CGPoint(
                x: bounds.midX - childSize.width / 2,
                y: bounds.maxY - childSize.height
            )
            
        case .bottomTrailing:
            childBounds.origin = CGPoint(
                x: bounds.maxX - childSize.width,
                y: bounds.maxY - childSize.height
            )
        }
        
        return childBounds
    }
    
    private func calculateOffset(from childResult: LayoutResult, to targetBounds: CGRect) -> CGPoint {
        // 자식 레이아웃의 현재 최소 좌표 찾기
        var minX: CGFloat = CGFloat.greatestFiniteMagnitude
        var minY: CGFloat = CGFloat.greatestFiniteMagnitude
        
        for (_, frame) in childResult.frames {
            minX = min(minX, frame.origin.x)
            minY = min(minY, frame.origin.y)
        }
        
        // 목표 위치로 이동하기 위한 오프셋 계산
        return CGPoint(
            x: targetBounds.origin.x - minX,
            y: targetBounds.origin.y - minY
        )
    }
    
    public func extractViews() -> [UIView] {
        return children.flatMap { $0.extractViews() }
    }
}
