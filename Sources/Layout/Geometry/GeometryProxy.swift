import UIKit

/// Provides access to the size and coordinate space of a container
@MainActor
public struct GeometryProxy {
    /// The size of the container
    public let size: CGSize
    
    /// The safe area insets
    public let safeAreaInsets: UIEdgeInsets
    
    /// The bounds of the container
    public var bounds: CGRect {
        return CGRect(origin: .zero, size: size)
    }
    
    /// The frame in the global coordinate space
    public let globalFrame: CGRect
    
    /// The frame in the local coordinate space
    public var localFrame: CGRect {
        return CGRect(origin: .zero, size: size)
    }
    
    /// Creates a geometry proxy
    public init(
        size: CGSize,
        safeAreaInsets: UIEdgeInsets = .zero,
        globalFrame: CGRect = .zero
    ) {
        self.size = size
        self.safeAreaInsets = safeAreaInsets
        self.globalFrame = globalFrame
    }
    
    /// Converts a point from local to global coordinates
    public func frame(in coordinateSpace: CoordinateSpace) -> CGRect {
        switch coordinateSpace {
        case .local:
            return localFrame
        case .global:
            return globalFrame
        case .named(let name):
            return CoordinateSpaceRegistry.shared.frame(for: name, relativeTo: globalFrame)
        }
    }
}

