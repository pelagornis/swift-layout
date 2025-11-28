import UIKit

/// A container that provides access to its geometry
@MainActor
public class GeometryReader: UIView, Layout {
    public typealias Body = Never
    
    public var body: Never {
        fatalError("GeometryReader is a primitive layout")
    }
    
    /// The content builder that receives geometry
    private var contentBuilder: ((GeometryProxy) -> any Layout)?
    
    /// The current content layout
    private var currentContent: (any Layout)?
    
    /// The geometry proxy
    private var geometryProxy: GeometryProxy?
    
    /// Callback when geometry changes
    private var onGeometryChange: ((GeometryProxy) -> Void)?
    
    /// Creates a geometry reader with LayoutBuilder
    public init(@LayoutBuilder content: @escaping (GeometryProxy) -> any Layout) {
        self.contentBuilder = content
        super.init(frame: .zero)
    }
    
    /// Creates a geometry reader with raw content builder (for imperative view setup)
    public init(content: @escaping (GeometryProxy, UIView) -> Void) {
        super.init(frame: .zero)
        self.imperativeBuilder = content
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// Imperative content builder
    private var imperativeBuilder: ((GeometryProxy, UIView) -> Void)?
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard bounds.width > 0 && bounds.height > 0 else { return }
        
        let proxy = GeometryProxy(
            size: bounds.size,
            safeAreaInsets: safeAreaInsets,
            globalFrame: convert(bounds, to: nil)
        )
        
        let geometryChanged = geometryProxy?.size != proxy.size ||
                             geometryProxy?.globalFrame != proxy.globalFrame
        
        geometryProxy = proxy
        
        if geometryChanged {
            onGeometryChange?(proxy)
            updateContent()
        }
    }
    
    private func updateContent() {
        guard let proxy = geometryProxy else { return }
        
        subviews.forEach { $0.removeFromSuperview() }
        
        // Imperative builder takes priority
        if let imperativeBuilder = imperativeBuilder {
            imperativeBuilder(proxy, self)
            return
        }
        
        guard let builder = contentBuilder else { return }
        
        let content = builder(proxy)
        currentContent = content
        
        let views = content.extractViews()
        for view in views {
            addSubview(view)
        }
        
        let result = content.calculateLayout(in: bounds)
        for (view, frame) in result.frames {
            view.frame = frame
        }
    }
    
    /// Sets a callback for geometry changes
    public func onGeometryChange(_ handler: @escaping (GeometryProxy) -> Void) -> Self {
        onGeometryChange = handler
        return self
    }
    
    // MARK: - Layout Protocol
    
    public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        var frames: [UIView: CGRect] = [:]
        frames[self] = bounds
        
        if let content = currentContent {
            let contentResult = content.calculateLayout(in: bounds)
            frames.merge(contentResult.frames) { _, new in new }
        }
        
        return LayoutResult(frames: frames, totalSize: bounds.size)
    }
    
    public func extractViews() -> [UIView] {
        return [self]
    }
    
    override public var intrinsicContentSize: CGSize {
        return currentContent?.intrinsicContentSize ?? CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }
}

