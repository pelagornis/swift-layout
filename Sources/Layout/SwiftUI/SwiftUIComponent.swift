/// SwiftUI-style chainable modifiers for UILabel.
@available(iOS 13.0, *)
public extension UILabel {
    /// Sets the label text.
    ///
    /// - Parameter text: The text to set
    /// - Returns: Self for chaining
    func text(_ text: String) -> Self {
        self.text = text
        return self
    }
    
    /// Sets the label font.
    ///
    /// - Parameter font: The font to set
    /// - Returns: Self for chaining
    func font(_ font: UIFont) -> Self {
        self.font = font
        return self
    }
    
    /// Sets the text color.
    ///
    /// - Parameter color: The color to set
    /// - Returns: Self for chaining
    func foregroundColor(_ color: UIColor) -> Self {
        self.textColor = color
        return self
    }
    
    /// Sets the text alignment.
    ///
    /// - Parameter alignment: The text alignment
    /// - Returns: Self for chaining
    func multilineTextAlignment(_ alignment: NSTextAlignment) -> Self {
        self.textAlignment = alignment
        return self
    }
    
    /// Sets the maximum number of lines.
    ///
    /// - Parameter number: Maximum lines (nil for unlimited)
    /// - Returns: Self for chaining
    func lineLimit(_ number: Int?) -> Self {
        self.numberOfLines = number ?? 0
        return self
    }
}

/// SwiftUI-style chainable modifiers for UIButton.
@available(iOS 13.0, *)
public extension UIButton {
    /// Sets the button title.
    ///
    /// - Parameters:
    ///   - title: The title text
    ///   - state: The control state (default: .normal)
    /// - Returns: Self for chaining
    func title(_ title: String, for state: UIControl.State = .normal) -> Self {
        setTitle(title, for: state)
        return self
    }
    
    /// Sets the title color.
    ///
    /// - Parameters:
    ///   - color: The title color
    ///   - state: The control state (default: .normal)
    /// - Returns: Self for chaining
    func foregroundColor(_ color: UIColor, for state: UIControl.State = .normal) -> Self {
        setTitleColor(color, for: state)
        return self
    }
    
    /// Sets the title font.
    ///
    /// - Parameter font: The font to set
    /// - Returns: Self for chaining
    func font(_ font: UIFont) -> Self {
        titleLabel?.font = font
        return self
    }
    
    /// Sets the background color.
    ///
    /// - Parameter color: The background color
    /// - Returns: Self for chaining
    func background(_ color: UIColor) -> Self {
        backgroundColor = color
        return self
    }
    
    /// Sets the corner radius.
    ///
    /// - Parameter radius: The corner radius
    /// - Returns: Self for chaining
    func cornerRadius(_ radius: CGFloat) -> Self {
        layer.cornerRadius = radius
        return self
    }
    
    /// Adds a tap gesture action.
    ///
    /// - Parameter action: The action closure
    /// - Returns: Self for chaining
    func onTapGesture(_ action: @escaping () -> Void) -> Self {
        addAction(UIAction { _ in action() }, for: .touchUpInside)
        return self
    }
}

/// SwiftUI-style chainable modifiers for UIImageView.
@available(iOS 13.0, *)
public extension UIImageView {
    /// Sets the image.
    ///
    /// - Parameter image: The image to set
    /// - Returns: Self for chaining
    func image(_ image: UIImage?) -> Self {
        self.image = image
        return self
    }
    
    /// Sets the content mode.
    ///
    /// - Parameter contentMode: The content mode
    /// - Returns: Self for chaining
    func aspectRatio(_ contentMode: UIView.ContentMode) -> Self {
        self.contentMode = contentMode
        return self
    }
    
    /// Sets whether to clip to bounds.
    ///
    /// - Parameter clips: Whether to clip (default: true)
    /// - Returns: Self for chaining
    func clipsToBounds(_ clips: Bool = true) -> Self {
        self.clipsToBounds = clips
        return self
    }
}

/// SwiftUI-style chainable modifiers for UIView.
@available(iOS 13.0, *)
public extension UIView {
    /// Sets the background color.
    ///
    /// - Parameter color: The background color
    /// - Returns: Self for chaining
    func background(_ color: UIColor) -> Self {
        backgroundColor = color
        return self
    }
    
    /// Sets the corner radius.
    ///
    /// - Parameter radius: The corner radius
    /// - Returns: Self for chaining
    func cornerRadius(_ radius: CGFloat) -> Self {
        layer.cornerRadius = radius
        return self
    }
    
    /// Adds a shadow.
    ///
    /// - Parameters:
    ///   - color: Shadow color (default: .black)
    ///   - radius: Shadow radius
    ///   - x: Horizontal offset (default: 0)
    ///   - y: Vertical offset (default: 0)
    ///   - opacity: Shadow opacity (default: 0.5)
    /// - Returns: Self for chaining
    func shadow(color: UIColor = .black, radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0, opacity: Float = 0.5) -> Self {
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOffset = CGSize(width: x, height: y)
        layer.shadowOpacity = opacity
        return self
    }
    
    /// Adds a border.
    ///
    /// - Parameters:
    ///   - color: Border color
    ///   - width: Border width (default: 1)
    /// - Returns: Self for chaining
    func border(_ color: UIColor, width: CGFloat = 1) -> Self {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
        return self
    }
    
    /// Sets the view's hidden state.
    ///
    /// - Parameter hidden: Whether the view should be hidden (default: true)
    /// - Returns: Self for chaining
    func hidden(_ hidden: Bool = true) -> Self {
        isHidden = hidden
        return self
    }
    
    /// Sets the view's opacity.
    ///
    /// - Parameter opacity: The opacity value (0.0 to 1.0)
    /// - Returns: Self for chaining
    func opacity(_ opacity: Double) -> Self {
        alpha = CGFloat(opacity)
        return self
    }
    
    /// Adds a tap gesture recognizer.
    ///
    /// - Parameter action: The action closure
    /// - Returns: Self for chaining
    func onTapGesture(_ action: @escaping () -> Void) -> Self {
        let tapGesture = UITapGestureRecognizer(target: nil, action: nil)
        tapGesture.addAction(UIAction { _ in action() })
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
        return self
    }
}