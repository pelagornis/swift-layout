import CoreGraphics
/// Registry for named coordinate spaces
@MainActor
public final class CoordinateSpaceRegistry {
    public static let shared = CoordinateSpaceRegistry()
    
    private var coordinateSpaces: [String: CGRect] = [:]
    
    private init() {}
    
    /// Registers a named coordinate space
    public func register(name: String, frame: CGRect) {
        coordinateSpaces[name] = frame
    }
    
    /// Unregisters a named coordinate space
    public func unregister(name: String) {
        coordinateSpaces.removeValue(forKey: name)
    }
    
    /// Gets the frame for a named coordinate space
    public func frame(for name: String) -> CGRect? {
        return coordinateSpaces[name]
    }
    
    /// Converts a frame relative to a named coordinate space
    func frame(for name: String, relativeTo globalFrame: CGRect) -> CGRect {
        guard let spaceFrame = coordinateSpaces[name] else {
            return globalFrame
        }
        return CGRect(
            x: globalFrame.origin.x - spaceFrame.origin.x,
            y: globalFrame.origin.y - spaceFrame.origin.y,
            width: globalFrame.width,
            height: globalFrame.height
        )
    }
}
