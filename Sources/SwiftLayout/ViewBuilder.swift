import Foundation

@resultBuilder public struct ViewBuilder {
    public static func buildBlock(_ values: ViewConvertable...) -> [View] {
        return values.asViews()
    }
    
}
