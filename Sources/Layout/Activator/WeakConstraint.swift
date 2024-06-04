#if canImport(UIKit)
    import UIKit
#else
    import AppKit
#endif

struct WeakConstraint {
    private(set) weak var origin: LayoutConstraint?
    private var customHashValue: Int

    init(origin: LayoutConstraint? = nil) {
        self.origin = origin

        var hasher = Hasher()
        hasher.combine(origin?.firstItem as? NSObject)
        hasher.combine(origin?.firstAttribute)
        hasher.combine(origin?.secondItem as? NSObject)
        hasher.combine(origin?.secondAttribute)
        hasher.combine(origin?.relation)
        hasher.combine(origin?.constant)
        hasher.combine(origin?.multiplier)
        hasher.combine(origin?.priority)
        self.customHashValue = hasher.finalize()
    }
}

extension WeakConstraint: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(customHashValue)
    }

    static func == (lhs: WeakConstraint, rhs: WeakConstraint) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

extension Set where Element == WeakConstraint {
    init(ofWeakConstraintsFrom sequence: [LayoutConstraint]) {
        self.init(sequence.map(WeakConstraint.init))
    }
}