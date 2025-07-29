import UIKit

/// A wrapper that provides layout functionality for UIViews with chainable modifiers.
///
/// ``ViewLayout`` wraps a UIView and provides a fluent interface for applying
/// layout modifiers. It calculates the final frame by applying all modifiers
/// in sequence to the view's intrinsic content size.
///
/// ## Example Usage
///
/// ```swift
/// titleLabel.layout()
///     .size(width: 200, height: 44)
///     .centerX()
///     .offset(y: 20)
/// ```
@preconcurrency
public struct ViewLayout: Layout {
    public typealias Body = Never
    
    public var body: Never {
        neverLayout("ViewLayout")
    }
    
    /// The wrapped UIView
    public let view: UIView
    
    /// Array of modifiers to apply during layout calculation
    public var modifiers: [LayoutModifier] = []
    
    /// Creates a view layout wrapper.
    ///
    /// - Parameter view: The UIView to wrap
    public init(_ view: UIView) {
        self.view = view
    }
    
    @MainActor public func calculateLayout(in bounds: CGRect) -> LayoutResult {
        let intrinsicSize = view.intrinsicContentSize
        
        // 더 정확한 기본 크기 계산
        var defaultSize: CGSize
        
        if intrinsicSize.width == UIView.noIntrinsicMetric || intrinsicSize.height == UIView.noIntrinsicMetric {
            // intrinsicContentSize가 설정되지 않은 경우
            if let label = view as? UILabel {
                // UILabel의 경우 text 크기를 기반으로 계산
                let textSize = label.text?.size(withAttributes: [.font: label.font ?? UIFont.systemFont(ofSize: 17)]) ?? .zero
                defaultSize = CGSize(
                    width: max(textSize.width + 20, 100), // 최소 너비 보장
                    height: max(textSize.height + 10, 30) // 최소 높이 보장
                )
            } else if let button = view as? UIButton {
                // UIButton의 경우 title 크기를 기반으로 계산
                let titleSize = button.title(for: .normal)?.size(withAttributes: [.font: button.titleLabel?.font ?? UIFont.systemFont(ofSize: 17)]) ?? .zero
                defaultSize = CGSize(
                    width: max(titleSize.width + 40, 120), // 최소 너비 보장
                    height: max(titleSize.height + 20, 44) // 최소 높이 보장
                )
            } else {
                // 기타 UIView의 경우 기본값 사용
                defaultSize = CGSize(width: 100, height: 30)
            }
        } else {
            // intrinsicContentSize가 설정된 경우 그대로 사용
            defaultSize = intrinsicSize
        }
        
        // size 모디파이어가 있는지 확인
        var hasSizeModifier = false
        var explicitWidth: CGFloat?
        var explicitHeight: CGFloat?
        
        for modifier in modifiers {
            if let sizeModifier = modifier as? SizeModifier {
                hasSizeModifier = true
                explicitWidth = sizeModifier.width
                explicitHeight = sizeModifier.height
                break
            }
        }
        
        // size 모디파이어가 있으면 해당 크기 사용
        if hasSizeModifier {
            defaultSize = CGSize(
                width: explicitWidth ?? defaultSize.width,
                height: explicitHeight ?? defaultSize.height
            )
        }
        
        // bounds.origin을 기준으로 한 상대 좌표로 시작
        var frame = CGRect(origin: .zero, size: defaultSize)
        
        // Apply modifiers in sequence (bounds를 기준으로)
        for modifier in modifiers {
            frame = modifier.apply(to: frame, in: bounds)
            
            // BackgroundModifier 처리
            if let backgroundModifier = modifier as? BackgroundModifier {
                view.backgroundColor = backgroundModifier.color
            }
        }
        
        // 최종 프레임을 bounds.origin을 기준으로 한 상대 좌표로 변환
        let finalFrame = CGRect(
            x: bounds.origin.x + frame.origin.x,
            y: bounds.origin.y + frame.origin.y,
            width: frame.width,
            height: frame.height
        )
        
        print("🔧 ViewLayout - view: \(type(of: view)), defaultSize: \(defaultSize), final frame: \(finalFrame)")
        
        return LayoutResult(frames: [view: finalFrame], totalSize: frame.size)
    }
    
    public func extractViews() -> [UIView] {
        return [view]
    }
    
    // MARK: - Size Modifiers
    
    /// Sets the width and/or height of the view.
    ///
    /// - Parameters:
    ///   - width: Optional width to set
    ///   - height: Optional height to set
    /// - Returns: A new ``ViewLayout`` with the size modifier applied
    public func size(width: CGFloat? = nil, height: CGFloat? = nil) -> ViewLayout {
        var copy = self
        copy.modifiers.append(SizeModifier(width: width, height: height))
        return copy
    }
    
    /// Sets the size of the view using a CGSize.
    ///
    /// - Parameter size: The size to set
    /// - Returns: A new ``ViewLayout`` with the size modifier applied
    public func size(_ size: CGSize) -> ViewLayout {
        return self.size(width: size.width, height: size.height)
    }
    
    /// Sets the frame dimensions of the view.
    ///
    /// - Parameters:
    ///   - width: Optional width to set
    ///   - height: Optional height to set
    /// - Returns: A new ``ViewLayout`` with the frame modifier applied
    public func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> ViewLayout {
        var copy = self
        copy.modifiers.append(SizeModifier(width: width, height: height))
        return copy
    }
    
    // MARK: - Position Modifiers
    
    /// Centers the view horizontally within its bounds.
    ///
    /// - Returns: A new ``ViewLayout`` with the center modifier applied
    public func centerX() -> ViewLayout {
        var copy = self
        copy.modifiers.append(CenterModifier(horizontal: true, vertical: false))
        return copy
    }
    
    /// Centers the view vertically within its bounds.
    ///
    /// - Returns: A new ``ViewLayout`` with the center modifier applied
    public func centerY() -> ViewLayout {
        var copy = self
        copy.modifiers.append(CenterModifier(horizontal: false, vertical: true))
        return copy
    }
    
    /// Centers the view both horizontally and vertically within its bounds.
    ///
    /// - Returns: A new ``ViewLayout`` with the center modifier applied
    public func center() -> ViewLayout {
        var copy = self
        copy.modifiers.append(CenterModifier(horizontal: true, vertical: true))
        return copy
    }
    
    /// Sets the position of the view.
    ///
    /// - Parameters:
    ///   - x: X coordinate
    ///   - y: Y coordinate
    /// - Returns: A new ``ViewLayout`` with the position modifier applied
    public func position(x: CGFloat, y: CGFloat) -> ViewLayout {
        var copy = self
        copy.modifiers.append(PositionModifier(x: x, y: y))
        return copy
    }
    
    /// Offsets the view by the specified amount.
    ///
    /// - Parameters:
    ///   - x: X offset
    ///   - y: Y offset
    /// - Returns: A new ``ViewLayout`` with the offset modifier applied
    public func offset(x: CGFloat = 0, y: CGFloat = 0) -> ViewLayout {
        var copy = self
        copy.modifiers.append(OffsetModifier(x: x, y: y))
        return copy
    }
    
    // MARK: - Aspect Ratio Modifier
    
    /// Sets the aspect ratio of the view.
    ///
    /// - Parameter ratio: The aspect ratio (width / height)
    /// - Returns: A new ``ViewLayout`` with the aspect ratio modifier applied
    public func aspectRatio(_ ratio: CGFloat) -> ViewLayout {
        var copy = self
        copy.modifiers.append(AspectRatioModifier(ratio: ratio, contentMode: .fit))
        return copy
    }
    
    // MARK: - Corner Radius Modifier
    
    /// Sets the corner radius of the view.
    ///
    /// - Parameter radius: The corner radius
    /// - Returns: A new ``ViewLayout`` with the corner radius modifier applied
    public func cornerRadius(_ radius: CGFloat) -> ViewLayout {
        var copy = self
        copy.modifiers.append(CornerRadiusModifier(radius: radius))
        
        // Corner radius를 layer에 즉시 적용
        view.layer.cornerRadius = radius
        view.layer.masksToBounds = true
        
        return copy
    }
    
    // MARK: - Background Modifier
    
    /// Sets the background color of the view.
    ///
    /// - Parameter color: The background color
    /// - Returns: A new ``ViewLayout`` with the background modifier applied
    public func background(_ color: UIColor) -> ViewLayout {
        var copy = self
        copy.modifiers.append(BackgroundModifier(color: color))
        return copy
    }
    
    // MARK: - Padding Modifier
    
    /// Adds padding around the view.
    ///
    /// - Parameter insets: The padding insets
    /// - Returns: A new ``ViewLayout`` with the padding modifier applied
    public func padding(_ insets: UIEdgeInsets) -> ViewLayout {
        var copy = self
        copy.modifiers.append(PaddingModifier(insets: insets))
        return copy
    }
    
    /// Adds padding around the view.
    ///
    /// - Parameter value: The padding value for all sides
    /// - Returns: A new ``ViewLayout`` with the padding modifier applied
    public func padding(_ value: CGFloat) -> ViewLayout {
        return padding(UIEdgeInsets(top: value, left: value, bottom: value, right: value))
    }
}
