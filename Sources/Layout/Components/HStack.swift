#if canImport(UIKit)
import UIKit
#endif
/// A horizontal stack layout that arranges child layouts in a row.
///
/// ``HStack`` is equivalent to SwiftUI's HStack and arranges its children
/// horizontally with customizable spacing, alignment, and padding.
///
/// ## Example Usage
///
/// ```swift
/// HStack(spacing: 12, alignment: .center) {
///     profileImage.layout()
///     nameLabel.layout()
///     Spacer()
///     actionButton.layout()
/// }
/// .padding(16)
/// ```
public struct HStack: Layout {
    public typealias Body = Never
    
    private let children: [any Layout]
    public var spacing: CGFloat = 8
    public var alignment: VerticalAlignment = .center
    public var padding: UIEdgeInsets = .zero
    
    public enum VerticalAlignment {
        case top, center, bottom
    }
    
    public init<Content: Layout>(spacing: CGFloat = 8, alignment: VerticalAlignment = .center, @LayoutBuilder content: () -> Content) {
        let builtContent = content()
        print("🔵 Horizontal init: builtContent type = \(type(of: builtContent))")
        self.children = Self.extractChildren(from: builtContent)
        print("🔵 Horizontal init: extracted \(self.children.count) children")
        for (index, child) in self.children.enumerated() {
            print("🔵   Child \(index): \(type(of: child))")
        }
        self.spacing = spacing
        self.alignment = alignment
    }
    
    private static func extractChildren(from content: any Layout) -> [any Layout] {
        if let tupleLayout = content as? TupleLayout {
            return tupleLayout.getLayouts()
        } else {
            return [content]
        }
    }
    
    public var body: Never {
        neverLayout("Horizontal")
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        var frames: [UIView: CGRect] = [:]
        var currentX: CGFloat = padding.left
        let availableHeight = bounds.height - padding.top - padding.bottom
        var maxHeight: CGFloat = 0

        // 각 child를 순차적으로 가로 배치
          for (index, child) in children.enumerated() {
              
              let childBounds = CGRect(x: 0, y: 0, width: bounds.width - currentX - padding.right, height: availableHeight)
              
              let childResult = child.calculateLayout(in: childBounds)
              
              // 이 child의 실제 너비 계산
              let childWidth = childResult.totalSize.width
              
              // 이 child의 모든 뷰를 적절한 위치에 배치
              for (viewIndex, (view, childFrame)) in childResult.frames.enumerated() {
                  var finalFrame = childFrame
                  
                  // X 위치: 현재 X + child 내에서의 상대적 위치
                  finalFrame.origin.x = currentX + childFrame.origin.x
                  
                  // Y 위치: 수직 정렬 적용
                  switch alignment {
                  case .top:
                      finalFrame.origin.y = padding.top + childFrame.origin.y
                  case .center:
                      let centerOffset = (availableHeight - childResult.totalSize.height) / 2
                      finalFrame.origin.y = padding.top + centerOffset + childFrame.origin.y
                  case .bottom:
                      let bottomOffset = availableHeight - childResult.totalSize.height
                      finalFrame.origin.y = padding.top + bottomOffset + childFrame.origin.y
                  }
                  
                  frames[view] = finalFrame
              }
              
              // 다음 child를 위해 X 위치 업데이트
              currentX += childWidth + spacing
              maxHeight = max(maxHeight, childResult.totalSize.height)
          }
          
          // Remove last spacing
          if !children.isEmpty {
              currentX -= spacing
          }
          
          currentX += padding.right
          let totalSize = CGSize(width: currentX, height: maxHeight + padding.top + padding.bottom)
          return LayoutResult(frames: frames, totalSize: totalSize)
      }
      
      public func extractViews() -> [UIView] {
          let views = children.flatMap { $0.extractViews() }
          return views
      }
      
      // MARK: - Modifier Methods
      
      public func spacing(_ spacing: CGFloat) -> Self {
          var copy = self
          copy.spacing = spacing
          return copy
      }
      
      public func padding(_ value: CGFloat) -> Self {
          var copy = self
          copy.padding = UIEdgeInsets(top: value, left: value, bottom: value, right: value)
          return copy
      }
      
      public func padding(_ insets: UIEdgeInsets) -> Self {
          var copy = self
          copy.padding = insets
          return copy
      }
      
      public func alignment(_ alignment: VerticalAlignment) -> Self {
          var copy = self
          copy.alignment = alignment
          return copy
      }
  }
