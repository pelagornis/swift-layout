import CoreGraphics
/// Anchor preferences for geometry
public struct AnchorPreferenceKey<Value>: PreferenceKey {
    public static var defaultValue: [Value] { [] }
    
    public static func reduce(value: inout [Value], nextValue: () -> [Value]) {
        value.append(contentsOf: nextValue())
    }
}

/// Bounds preference for layout calculations
public struct BoundsPreferenceKey: PreferenceKey {
    public static let defaultValue: CGRect = .zero
    
    public static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = value.union(nextValue())
    }
}

/// Size preference
public struct SizePreferenceKey: PreferenceKey {
    public static let defaultValue: CGSize = .zero
    
    public static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        let next = nextValue()
        value = CGSize(
            width: max(value.width, next.width),
            height: max(value.height, next.height)
        )
    }
}

