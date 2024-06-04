import Foundation

public protocol Layout: AnyObject {
    associatedtype Body: ViewLayout
    var activatorable: Activatorable? { get set }
    var body: Self.Body { get }
}

public extension Layout {

    func updateLayout(animated: Bool = false) {
        let layout: some Layout = self.layout
        
        if let activatorable = self.activatorable as? Activation {
            activatorable.updateLayout(layout, animated: animated)
        } else {
            self.activatorable = Activation(layout)
        }
    }
}
