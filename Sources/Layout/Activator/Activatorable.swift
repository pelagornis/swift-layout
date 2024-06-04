import Foundation

public protocol Activatorable: Hashable {
    func deactive()
    func viewForIdentifier(_ identifier: String) -> ViewType?
}
