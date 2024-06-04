#if canImport(UIKit)
    import UIKit
#else
    import AppKit
#endif

public final class ViewInformation: Hashable {
    public static func == (lhs: ViewInformation, rhs: ViewInformation) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    public init(superview: ViewType?, view: ViewType?, identifier: String?) {
        self.superview = superview
        self.view = view
        self.identifier = identifier
    }
    
    private(set) weak var superview: ViewType?
    private(set) weak var view: ViewType?
    let identifier: String?
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(superview)
        hasher.combine(view)
        hasher.combine(identifier)
    }
    
    func addSuperview() {
        guard let view = view else {
            return
        }
        guard let superview = superview, superview != view.superview else {
            return
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(view)
    }
    
    func removeFromSuperview() {
        view?.removeFromSuperview()
    }
    
    func updatingSuperview(_ superview: ViewType?) -> Self {
        ViewInformation(superview: superview, view: view, identifier: identifier)
    }
} 