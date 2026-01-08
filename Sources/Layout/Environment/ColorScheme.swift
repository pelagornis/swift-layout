import UIKit

public enum ColorScheme: Sendable {
    case light
    case dark
    
    public static var current: ColorScheme {
        if #available(iOS 13.0, *) {
            return UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light
        }
        return .light
    }
}
