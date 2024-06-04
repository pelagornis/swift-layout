import Foundation

public struct ViewIdentifiers {

    let views: Set<ViewInformation>

    subscript(_ identifier: String) -> ViewType? {
        views.first(where: { $0.identifier == identifier })?.view
    }

}