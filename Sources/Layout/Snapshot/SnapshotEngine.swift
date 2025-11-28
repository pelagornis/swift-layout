import UIKit

/// Engine for creating and comparing layout snapshots
@MainActor
public final class SnapshotEngine {
    /// Shared instance
    public static let shared = SnapshotEngine()
    
    /// Tolerance for pixel comparison (0-1)
    public var tolerance: CGFloat = 0.01
    
    /// Directory for storing reference snapshots
    public var referenceDirectory: URL?
    
    private init() {}
    
    /// Creates a snapshot of a layout
    public func snapshot(_ layout: any Layout, config: SnapshotConfig = SnapshotConfig()) -> UIImage {
        let containerView = UIView(frame: CGRect(origin: .zero, size: config.size))
        containerView.backgroundColor = config.backgroundColor
        
        let views = layout.extractViews()
        for view in views {
            containerView.addSubview(view)
        }
        
        let result = layout.calculateLayout(in: containerView.bounds)
        for (view, frame) in result.frames {
            view.frame = frame
        }
        
        containerView.layoutIfNeeded()
        
        let renderer = UIGraphicsImageRenderer(size: config.size, format: imageRendererFormat(for: config))
        
        return renderer.image { context in
            containerView.layer.render(in: context.cgContext)
        }
    }
    
    /// Creates a snapshot of a UIView
    public func snapshot(_ view: UIView, config: SnapshotConfig = SnapshotConfig()) -> UIImage {
        let originalFrame = view.frame
        view.frame = CGRect(origin: .zero, size: config.size)
        view.layoutIfNeeded()
        
        let renderer = UIGraphicsImageRenderer(size: config.size, format: imageRendererFormat(for: config))
        
        let image = renderer.image { context in
            view.layer.render(in: context.cgContext)
        }
        
        view.frame = originalFrame
        return image
    }
    
    /// Compares two images
    public func compare(_ actual: UIImage, with expected: UIImage) -> SnapshotResult {
        guard let actualCG = actual.cgImage, let expectedCG = expected.cgImage else {
            return SnapshotResult(matched: false, difference: 1.0, actualImage: actual, expectedImage: expected)
        }
        
        guard actualCG.width == expectedCG.width && actualCG.height == expectedCG.height else {
            return SnapshotResult(matched: false, difference: 1.0, actualImage: actual, expectedImage: expected)
        }
        
        let width = actualCG.width
        let height = actualCG.height
        let totalPixels = width * height
        
        guard let actualData = actualCG.dataProvider?.data,
              let expectedData = expectedCG.dataProvider?.data else {
            return SnapshotResult(matched: false, difference: 1.0, actualImage: actual, expectedImage: expected)
        }
        
        let actualBytes = CFDataGetBytePtr(actualData)
        let expectedBytes = CFDataGetBytePtr(expectedData)
        let byteCount = CFDataGetLength(actualData)
        
        guard byteCount == CFDataGetLength(expectedData) else {
            return SnapshotResult(matched: false, difference: 1.0, actualImage: actual, expectedImage: expected)
        }
        
        var differentPixels = 0
        
        for i in stride(from: 0, to: byteCount, by: 4) {
            let r1 = actualBytes?[i] ?? 0
            let g1 = actualBytes?[i + 1] ?? 0
            let b1 = actualBytes?[i + 2] ?? 0
            let a1 = actualBytes?[i + 3] ?? 0
            
            let r2 = expectedBytes?[i] ?? 0
            let g2 = expectedBytes?[i + 1] ?? 0
            let b2 = expectedBytes?[i + 2] ?? 0
            let a2 = expectedBytes?[i + 3] ?? 0
            
            if r1 != r2 || g1 != g2 || b1 != b2 || a1 != a2 {
                differentPixels += 1
            }
        }
        
        let difference = CGFloat(differentPixels) / CGFloat(totalPixels)
        let matched = difference <= tolerance
        
        var diffImage: UIImage? = nil
        if !matched {
            diffImage = generateDiffImage(actual: actual, expected: expected)
        }
        
        return SnapshotResult(
            matched: matched,
            difference: difference,
            diffImage: diffImage,
            actualImage: actual,
            expectedImage: expected
        )
    }
    
    /// Verifies a layout against a reference snapshot
    public func verify(
        _ layout: any Layout,
        named name: String,
        config: SnapshotConfig = SnapshotConfig(),
        record: Bool = false
    ) -> SnapshotResult {
        let actual = snapshot(layout, config: config)
        
        if record {
            saveReference(actual, named: name)
            return SnapshotResult(matched: true, difference: 0, actualImage: actual)
        }
        
        guard let expected = loadReference(named: name) else {
            return SnapshotResult(matched: false, difference: 1.0, actualImage: actual)
        }
        
        return compare(actual, with: expected)
    }
    
    private func imageRendererFormat(for config: SnapshotConfig) -> UIGraphicsImageRendererFormat {
        let format = UIGraphicsImageRendererFormat()
        format.scale = config.scale
        format.opaque = false
        return format
    }
    
    private func generateDiffImage(actual: UIImage, expected: UIImage) -> UIImage? {
        guard let actualCG = actual.cgImage, let expectedCG = expected.cgImage else {
            return nil
        }
        
        let width = actualCG.width
        let height = actualCG.height
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            return nil
        }
        
        context.setAlpha(0.5)
        context.draw(expectedCG, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        context.setBlendMode(.difference)
        context.setAlpha(1.0)
        context.draw(actualCG, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let diffCG = context.makeImage() else {
            return nil
        }
        
        return UIImage(cgImage: diffCG)
    }
    
    private func referenceURL(for name: String) -> URL? {
        guard let directory = referenceDirectory else {
            return nil
        }
        return directory.appendingPathComponent("\(name).png")
    }
    
    private func saveReference(_ image: UIImage, named name: String) {
        guard let url = referenceURL(for: name),
              let data = image.pngData() else {
            return
        }
        
        try? FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try? data.write(to: url)
    }
    
    private func loadReference(named name: String) -> UIImage? {
        guard let url = referenceURL(for: name),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return UIImage(data: data)
    }
}

// MARK: - Layout Extension for Snapshot Testing

extension Layout {
    /// Creates a snapshot of this layout
    @MainActor
    public func snapshot(config: SnapshotConfig = SnapshotConfig()) -> UIImage {
        return SnapshotEngine.shared.snapshot(self, config: config)
    }
    
    /// Verifies this layout against a reference snapshot
    @MainActor
    public func verifySnapshot(
        named name: String,
        config: SnapshotConfig = SnapshotConfig(),
        record: Bool = false
    ) -> SnapshotResult {
        return SnapshotEngine.shared.verify(self, named: name, config: config, record: record)
    }
}

// MARK: - UIView Extension for Snapshot

extension UIView {
    /// Creates a snapshot of this view
    @MainActor
    public func snapshot(config: SnapshotConfig = SnapshotConfig()) -> UIImage {
        return SnapshotEngine.shared.snapshot(self, config: config)
    }
}

