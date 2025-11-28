import Foundation

/// Priorities for content hugging and compression resistance
public struct ContentPriority: Sendable {
    public var hugging: LayoutPriority
    public var compressionResistance: LayoutPriority
    
    public init(
        hugging: LayoutPriority = .defaultLow,
        compressionResistance: LayoutPriority = .defaultHigh
    ) {
        self.hugging = hugging
        self.compressionResistance = compressionResistance
    }
    
    public static let `default` = ContentPriority()
    public static let highHugging = ContentPriority(hugging: .defaultHigh)
    public static let lowCompression = ContentPriority(compressionResistance: .defaultLow)
}

