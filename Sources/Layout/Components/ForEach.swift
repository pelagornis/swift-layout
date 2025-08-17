import UIKit

/// A layout that creates multiple views from a collection of data.
///
/// ``ForEach`` is equivalent to SwiftUI's ForEach and creates multiple views
/// by iterating over a collection of data or a range.
///
/// ## Overview
///
/// `ForEach` is a layout component that creates multiple views by iterating
/// over a collection of data. It's similar to SwiftUI's `ForEach` and provides
/// a declarative way to create dynamic, data-driven layouts.
///
/// ## Key Features
///
/// - **Data-Driven Layouts**: Create layouts from collections of data
/// - **Range Support**: Iterate over ranges of integers
/// - **Identifiable Support**: Works with `Identifiable` types
/// - **Type Safety**: Compile-time type checking for data and content
/// - **Flexible Content**: Each item can have its own layout
///
/// ## Example Usage
///
/// ```swift
/// ForEach(0..<10) { index in
///     Text("Item \(index)")
///         .frame(height: 60)
/// }
///
/// ForEach(items) { item in
///     HStack {
///         item.icon.layout()
///         item.title.layout()
///     }
/// }
/// ```
///
/// ## Topics
///
/// ### Initialization
/// - ``init(_:content:)``
/// - ``init(_:id:content:)``
///
/// ### Layout Behavior
/// - ``calculateLayout(in:)``
/// - ``extractViews()``
public struct ForEach<Data: RandomAccessCollection, Content: Layout>: Layout where Data.Element: Hashable {
    public typealias Body = Never
    
    public var body: Never {
        neverLayout("ForEach")
    }
    
    private let data: Data
    private let content: (Data.Element) -> Content
    
    /// Creates a ForEach with a range and content builder
    /// - Parameters:
    ///   - range: The range to iterate over
    ///   - content: A closure that creates content for each element
    public init(_ range: Range<Int>, @LayoutBuilder content: @escaping (Int) -> Content) where Data == Range<Int> {
        self.data = range
        self.content = content
    }
    
    /// Creates a ForEach with a collection and content builder
    /// - Parameters:
    ///   - data: The collection to iterate over
    ///   - content: A closure that creates content for each element
    public init(_ data: Data, @LayoutBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
    }
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        var frames: [UIView: CGRect] = [:]
        var totalSize = CGSize.zero
        
        // Calculate layout for each item
        for element in data {
            let itemLayout = content(element)
            let itemResult = itemLayout.calculateLayout(in: bounds)
            
            // Merge frames
            frames.merge(itemResult.frames) { _, new in new }
            
            // Update total size
            totalSize.width = max(totalSize.width, itemResult.totalSize.width)
            totalSize.height += itemResult.totalSize.height
        }
        
        return LayoutResult(frames: frames, totalSize: totalSize)
    }
    
    public func extractViews() -> [UIView] {
        var views: [UIView] = []
        
        // Extract views from each item
        for element in data {
            let itemLayout = content(element)
            views.append(contentsOf: itemLayout.extractViews())
        }
        
        return views
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
