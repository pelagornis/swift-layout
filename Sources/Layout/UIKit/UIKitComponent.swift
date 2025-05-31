import UIKit

/// Factory for creating SwiftUI-style UIKit components.
///
/// ``UIKitComponents`` provides static methods for creating common UIKit
/// components with SwiftUI-like initialization and immediate SwiftUI conversion.
@available(iOS 13.0, *)
public enum UIKitComponents {
    
    /// Creates a SwiftUI-wrapped UILabel.
    ///
    /// - Parameter text: The label text
    /// - Returns: A SwiftUI view wrapping a UILabel
    public static func Label(_ text: String) -> UIViewWrapper {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 17)
        label.textColor = .label
        return label.swiftui
    }
    
    /// Creates a SwiftUI-wrapped UIButton.
    ///
    /// - Parameters:
    ///   - title: The button title
    ///   - action: Action closure for button taps
    /// - Returns: A SwiftUI view wrapping a UIButton
    public static func Button(_ title: String, action: @escaping () -> Void) -> UIViewWrapper {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return button.swiftui
    }
    
    /// Creates a SwiftUI-wrapped UIImageView.
    ///
    /// - Parameter image: The image to display
    /// - Returns: A SwiftUI view wrapping a UIImageView
    public static func Image(_ image: UIImage?) -> UIViewWrapper {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView.swiftui
    }
    
    /// Creates a SwiftUI-wrapped UITextField with binding support.
    ///
    /// - Parameters:
    ///   - placeholder: Placeholder text
    ///   - text: SwiftUI binding for the text value
    /// - Returns: A SwiftUI view wrapping a UITextField
    public static func TextField(_ placeholder: String, text: Binding<String>) -> UIViewWrapper {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        
        return textField.swiftui.onUpdate { view, context in
            guard let textField = view as? UITextField else { return }
            if textField.text != text.wrappedValue {
                textField.text = text.wrappedValue
            }
        }
    }
}
