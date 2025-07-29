import UIKit

/// A layout that creates views from a collection of data.
///
/// ``ForEach`` is equivalent to SwiftUI's ForEach and creates views
/// dynamically from a collection of data with automatic view management.
///
/// ## Example Usage
///
/// ```swift
/// ForEach(items) { item in
///     itemView.layout()
///         .size(width: 280, height: 44)
///         .centerX()
/// }
/// ```
public struct ForEach<Data: RandomAccessCollection, Content: Layout>: Layout {
    public typealias Body = Never
    
    private let data: Data
    private let content: (Data.Element) -> Content
    
    public init(_ data: Data, @LayoutBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
    }
    
    public var body: Never {
        neverLayout("ForEach")
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        var allFrames: [UIView: CGRect] = [:]
        var totalSize = CGSize.zero
        
        for element in data {
            let elementLayout = content(element)
            let elementResult = elementLayout.calculateLayout(in: bounds)
            
            // 모든 뷰의 프레임을 수집
            for (view, frame) in elementResult.frames {
                allFrames[view] = frame
            }
            
            // 전체 크기 업데이트
            totalSize.width = max(totalSize.width, elementResult.totalSize.width)
            totalSize.height = max(totalSize.height, elementResult.totalSize.height)
        }
        
        return LayoutResult(frames: allFrames, totalSize: totalSize)
    }
    
    public func extractViews() -> [UIView] {
        return data.flatMap { element in
            content(element).extractViews()
        }
    }
}

// MARK: - Convenience Initializers

extension ForEach where Data.Element: Identifiable {
    /// Creates a ForEach with identifiable data
    public init(_ data: Data, id: KeyPath<Data.Element, Data.Element.ID>, @LayoutBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
    }
}

extension ForEach where Data.Element == String {
    /// Creates a ForEach with string data
    public init(_ data: Data, @LayoutBuilder content: @escaping (String) -> Content) {
        self.data = data
        self.content = content
    }
}

extension ForEach where Data.Element == Int {
    /// Creates a ForEach with integer data
    public init(_ data: Data, @LayoutBuilder content: @escaping (Int) -> Content) {
        self.data = data
        self.content = content
    }
}
