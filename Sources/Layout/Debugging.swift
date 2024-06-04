#if canImport(UIKit)
    import UIKit
#else
    import AppKit
#endif

struct Debugging<Value>: CustomDebugStringConvertible where Value: Debugable, Value: AnyObject {

    let value: Value

    init(_ value: Value) {
        self.value = value
    }

    var identifier: String {
        if let identifier = value.accessibilityIdentifier {
            return identifier
        } else {
            return Unmanaged<Value>.passUnretained(value).toOpaque().debugDescription
        }
    }
    
    var debugDescription: String {
        "\(type(of: self.value))(\(identifier))"
    }
}

protocol Debugable {
    var accessibilityIdentifier: String? { get }
}

extension Debugable where Self: ViewType {
    var debugDescription: String {
        Debugging(self).debugDescription
    }
}

extension Debugable where Self: LayoutGuide {
    var debugDescription: String {
        Debugable(self).debugDescription
    }
    
    var accessibilityIdentifier: String? { owningView?.accessibilityIdentifier }
}

extension ViewType: Debugable {}
extension LayoutGuide: Debugable {}