import Foundation

final class Activation: Activatorable {
    let uuid = UUID()
    
    var views: Set<ViewInformation> = []
    var constraints: Set<WeakReference<NSLayoutConstraint>> = []

}