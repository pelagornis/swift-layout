#if canImport(UIKit)
import UIKit

#endif
public enum LayoutDirection: Sendable {
    case leftToRight
    case rightToLeft
    
    public static var current: LayoutDirection {
        return UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .rightToLeft : .leftToRight
    }
}
