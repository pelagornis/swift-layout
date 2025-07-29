import UIKit

/// A SwiftUI-style container view that automatically manages view hierarchy and centers content.
///
/// ``LayoutContainer`` provides a SwiftUI-like experience with automatic content centering
/// and declarative layout definitions. It automatically adds and removes views based on
/// the current layout definition, just like SwiftUI's body.
///
/// ## Features
///
/// - **Automatic Centering** - Content is automatically centered like SwiftUI
/// - **Automatic View Management** - Views are added/removed automatically
/// - **Conditional Layout Support** - Dynamic content handling
/// - **High-performance Frame-based Layout** - No Auto Layout constraints
/// - **SwiftUI-style API** - Familiar declarative syntax
///
/// ## Example Usage
///
/// ```swift
/// class MyViewController: UIViewController, Layout {
///     let layoutContainer = LayoutContainer()
///     let titleLabel = UILabel()
///     let actionButton = UIButton()
///     
///     override func viewDidLoad() {
///         super.viewDidLoad()
///         
///         // Setup views
///         titleLabel.text = "Welcome!"
///         actionButton.setTitle("Get Started", for: .normal)
///         
///         // Add container and set body - content is automatically centered!
///         view.addSubview(layoutContainer)
///         layoutContainer.frame = view.bounds
///         layoutContainer.setBody { self.body }
///     }
///     
///     @LayoutBuilder var body: Layout {
///         // Content is automatically centered like SwiftUI
///         titleLabel.layout()
///         actionButton.layout()
///     }
/// }
/// ```
public class LayoutContainer: UIView {
    private var _body: (() -> any Layout)?
    private var managedViews: Set<UIView> = []
    
    public var body: (any Layout)? {
        get { _body?() }
        set { _body = { newValue! } }
    }
    
    /// Sets the body with SwiftUI-style automatic centering
    public func setBody(@LayoutBuilder _ content: @escaping () -> any Layout) {
        _body = content
        updateViewHierarchy()
        setNeedsLayout()
    }
    
    /// Updates layout for orientation changes
    public func updateLayoutForOrientationChange() {
        NSLog("🔧 LayoutContainer - updateLayoutForOrientationChange called")
        print("🔧 LayoutContainer - updateLayoutForOrientationChange called")
        updateViewHierarchy()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func updateViewHierarchy() {
        guard let layout = body else { return }
        
        // bounds가 설정되지 않은 경우 기본값 사용
        let availableBounds = bounds.width > 0 ? bounds : CGRect(x: 0, y: 0, width: 375, height: 812)
        
        // 레이아웃 계산하여 모든 뷰 (배경 뷰 포함) 추출
        let result = layout.calculateLayout(in: availableBounds)
        let allViews = Set(result.frames.keys)
        
        print("🔧 updateViewHierarchy - allViews count: \(allViews.count)")
        for view in allViews {
            print("🔧 updateViewHierarchy - view: \(type(of: view)), hasBackground: \(view.backgroundColor != nil)")
        }
        
        // 모든 뷰들을 관리 (Layout 뷰들과 그 자식 뷰들)
        let allViewsToManage = allViews
        
        // Remove views that are no longer needed (Layout 뷰들 제외)
        let viewsToRemove = managedViews.subtracting(allViewsToManage)
        viewsToRemove.forEach { view in
            if !(view is ZStack || view is VStack || view is HStack) {
                view.removeFromSuperview()
            }
        }
        
        // Add new views that aren't already added (모든 뷰 추가)
        let viewsToAdd = allViewsToManage.subtracting(managedViews)
        viewsToAdd.forEach { view in
            addSubview(view)
            print("🔧 Added view to hierarchy: \(type(of: view))")
            if type(of: view) == UIView.self && view.backgroundColor != nil {
                print("🔧 Added background view to hierarchy: \(type(of: view))")
                print("🔧 Background view backgroundColor: \(view.backgroundColor!)")
                print("🔧 Background view cornerRadius: \(view.layer.cornerRadius)")
            }
        }
        
        // Update managed views (Layout 뷰들과 자식 뷰들 포함)
        managedViews = allViewsToManage
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let layout = body else { return }
        
        NSLog("🔧 LayoutContainer - layoutSubviews - bounds: \(bounds)")
        NSLog("🔧 LayoutContainer - layoutSubviews - frame: \(frame)")
        NSLog("🔧 LayoutContainer - layoutSubviews - superview bounds: \(superview?.bounds ?? .zero)")
        print("🔧 LayoutContainer - bounds: \(bounds)")
        print("🔧 LayoutContainer - safeAreaInsets: \(safeAreaInsets)")
        
        // bounds가 유효하지 않은 경우 레이아웃 건너뛰기
        guard bounds.width > 0 && bounds.height > 0 else {
            NSLog("🔧 LayoutContainer - Invalid bounds, skipping layout")
            print("🔧 LayoutContainer - Invalid bounds, skipping layout")
            return
        }
        
        // 전체 bounds 사용 (SafeArea는 중앙 정렬 후에 고려)
        let availableBounds = bounds
        
        // bounds가 유효하지 않은 경우 기본값 사용
        guard availableBounds.width > 0 && availableBounds.height > 0 else {
            NSLog("🔧 LayoutContainer - Invalid availableBounds, using default")
            print("🔧 LayoutContainer - Invalid availableBounds, using default")
            return
        }
        
        NSLog("🔧 LayoutContainer - Using availableBounds: \(availableBounds)")
        print("🔧 LayoutContainer - Using availableBounds: \(availableBounds)")
        
        // 레이아웃 계산
        let result = layout.calculateLayout(in: availableBounds)
        
        NSLog("🔧 LayoutContainer - result frames count: \(result.frames.count)")
        NSLog("🔧 LayoutContainer - result totalSize: \(result.totalSize)")
        print("🔧 LayoutContainer - result frames count: \(result.frames.count)")
        print("🔧 LayoutContainer - result totalSize: \(result.totalSize)")
        
        // 성능 모니터링과 함께 프레임 설정
        LayoutPerformanceMonitor.measureLayout(name: "LayoutContainer") {
            // 전체 화면 기준 중앙 정렬을 위한 오프셋 계산
            // 실제 내용 크기를 기준으로 중앙 정렬 (clamping 하지 않음)
            let centerX = (availableBounds.width - result.totalSize.width) / 2
            let centerY = (availableBounds.height - result.totalSize.height) / 2
            
            NSLog("🔧 LayoutContainer - availableBounds: \(availableBounds)")
            NSLog("🔧 LayoutContainer - result.totalSize: \(result.totalSize)")
            NSLog("🔧 LayoutContainer - calculated centerX: \(centerX), centerY: \(centerY)")
            print("🔧 LayoutContainer - availableBounds: \(availableBounds)")
            print("🔧 LayoutContainer - result.totalSize: \(result.totalSize)")
            print("🔧 LayoutContainer - calculated centerX: \(centerX), centerY: \(centerY)")
            
            // Layout 뷰들을 먼저 배치
            for (view, frame) in result.frames {
                // Layout 프로토콜을 구현하는 뷰들 처리
                if view is ZStack || view is VStack || view is HStack {
                                    // Layout 뷰들을 뷰 계층에 추가
                if view.superview == nil {
                    addSubview(view)
                    NSLog("🔧 Added Layout view to hierarchy: \(type(of: view))")
                    print("🔧 Added Layout view to hierarchy: \(type(of: view))")
                }
                
                // Layout 뷰들은 실제 내용 크기에 맞게 설정 (화면 안에 유지)
                let layoutWidth = min(result.totalSize.width, availableBounds.width)
                let layoutHeight = min(result.totalSize.height, availableBounds.height)
                let layoutX = max(0, min(centerX, availableBounds.width - layoutWidth))
                let layoutY = max(0, min(centerY, availableBounds.height - layoutHeight))
                
                // 화면 밖으로 나가지 않도록 추가 보장
                let finalLayoutY = max(0, layoutY)
                
                let layoutFrame = CGRect(
                    x: layoutX,
                    y: finalLayoutY,
                    width: layoutWidth,
                    height: layoutHeight
                )
                    
                    NSLog("🔧 Setting frame for Layout view \(type(of: view)): \(layoutFrame)")
                    print("🔧 Setting frame for Layout view \(type(of: view)): \(layoutFrame)")
                    view.frame = layoutFrame
                    
                    // 프레임 설정 후 약간의 지연을 두고 레이아웃 업데이트
                    DispatchQueue.main.async {
                        view.setNeedsLayout()
                        view.layoutIfNeeded()
                    }
                    
                    continue
                }
                
                // 배경 뷰는 UIView이고 배경색이 설정된 것들
                // UILabel과 UIButton이 아닌 UIView만 배경 뷰로 처리
                if type(of: view) == UIView.self && view.backgroundColor != nil {
                    let adjustedFrame = CGRect(
                        x: frame.origin.x + centerX,
                        y: frame.origin.y + centerY,
                        width: frame.width,
                        height: frame.height
                    )
                    
                    // SafeArea를 고려하지 않고 정확한 화면 중앙에 배치
                    let clampedFrame = CGRect(
                        x: adjustedFrame.origin.x,
                        y: adjustedFrame.origin.y,
                        width: adjustedFrame.width,
                        height: adjustedFrame.height
                    )
                    
                    NSLog("🔧 Setting background frame for \(type(of: view)): \(clampedFrame)")
                    print("🔧 Setting background frame for \(type(of: view)): \(clampedFrame)")
                    print("🔧 Background view backgroundColor: \(view.backgroundColor!)")
                    print("🔧 Background view cornerRadius: \(view.layer.cornerRadius)")
                    print("🔧 Background view alpha: \(view.alpha)")
                    print("🔧 Background view isHidden: \(view.isHidden)")
                    
                    // 배경 뷰가 뷰 계층에 없으면 다시 추가
                    if view.superview == nil {
                        addSubview(view)
                        NSLog("🔧 Re-added background view to hierarchy")
                        print("🔧 Re-added background view to hierarchy")
                    }
                    
                    view.frame = clampedFrame
                    continue
                }
                
                // 일반 뷰들 (UILabel, UIButton 등)
                let adjustedFrame = CGRect(
                    x: frame.origin.x + centerX,
                    y: frame.origin.y + centerY,
                    width: frame.width,
                    height: frame.height
                )
                
                NSLog("🔧 Setting frame for \(type(of: view)): \(adjustedFrame)")
                print("🔧 Setting frame for \(type(of: view)): \(adjustedFrame)")
                view.frame = adjustedFrame
            }
        }
    }
}
