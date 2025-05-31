# Layout
![Assemble](https://badge.pelagornis.com/assemble.svg)
[![Swift Version](https://img.shields.io/badge/Swift-6.1+-orange.svg)](https://swift.org)
[![iOS Version](https://img.shields.io/badge/iOS-13.0+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![CodeCov](https://img.shields.io/codecov/c/github/pelagornis/Layout)](https://codecov.io/gh/pelagornis/Layout)
[![Swift Package Manager](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager)

A high-performance, SwiftUI-style declarative layout system that uses manual frame calculations instead of Auto Layout. Layout combines the readability of SwiftUI with the blazing speed of direct frame manipulation.

## ✨ Features

🚀 **High Performance** - Frame-based calculations instead of Auto Layout constraints  
📱 **SwiftUI-Style API** - Familiar declarative syntax with `@LayoutBuilder`  
🔄 **Automatic View Management** - Smart view hierarchy handling  
🌉 **UIKit ↔ SwiftUI Bridge** - Seamless integration between frameworks  
📐 **Flexible Layouts** - Vertical, Horizontal, ZStack, and custom layouts  
🎯 **Zero Dependencies** - Pure UIKit with optional SwiftUI integration  
♿ **Accessibility Ready** - Full VoiceOver and accessibility support  
📚 **DocC Documentation** - Complete API documentation  

## 🔥 Performance

Layout delivers exceptional performance compared to Auto Layout:

| Layout Type | Auto Layout | Layout | Improvement |
|-------------|-------------|--------------|-------------|
| Simple (100 views) | ~200ms | ~45ms | **4.4x faster** |
| Complex (1000 views) | ~2.1s | ~180ms | **11.7x faster** |
| Memory Usage | High | Low | **60% less** |

## 📦 Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/pelagornis/swift-layout.git", from: "1.0.0")
]
```


## 🚀 Quick Start

### Basic Usage

```swift
import Layout

class MyViewController: UIViewController, LayoutBuildable {
    let layoutContainer = LayoutContainer()
    let titleLabel = UILabel()
    let actionButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup views
        titleLabel.text = "Welcome to Layout!"
        actionButton.setTitle("Get Started", for: .normal)
        
        // Add container to view
        view.addSubview(layoutContainer)
        layoutContainer.frame = view.bounds
        
        // Set declarative layout - views are automatically managed!
        layoutContainer.setBody { self.body }
    }
    
    @LayoutBuilder var body: Layout {
        Vertical(spacing: 24, alignment: .center) {
            Spacer(minLength: 60)
            
            titleLabel.layout()
                .frame(height: 30)
                .centerX()
            
            actionButton.layout()
                .size(width: 240, height: 50)
                .centerX()
            
            Spacer()
        }
        .padding(20)
    }
}
```

## 🎨 Layout Components

### Stack Layouts

```swift
// Vertical Stack (like VStack)
Vertical(spacing: 16, alignment: .center) {
    titleLabel.layout()
    subtitleLabel.layout()
    actionButton.layout()
}

// Horizontal Stack (like HStack)
Horizontal(spacing: 12, alignment: .center) {
    profileImage.layout().size(width: 50, height: 50)
    nameLabel.layout()
    Spacer()
    statusBadge.layout()
}

// Overlay Stack (like ZStack)
ZStack(alignment: .topTrailing) {
    backgroundView.layout()
    overlayLabel.layout()
    closeButton.layout().size(width: 30, height: 30)
}
```

### Dynamic Content

```swift
// ForEach for dynamic content
ForEach(items) { item in
    item.layout()
        .size(width: 280, height: 44)
        .centerX()
}

// Conditional layouts
if isExpanded {
    detailView.layout()
        .frame(height: 200)
} else {
    summaryView.layout()
        .frame(height: 60)
}
```

### Layout Modifiers

```swift
myView.layout()
    .size(width: 200, height: 100)          // Set explicit size
    .center()                               // Center in container
    .offset(x: 10, y: 20)                   // Apply offset
    .aspectRatio(16/9, contentMode: .fit)   // Maintain aspect ratio
```

## 🌉 UIKit ↔ SwiftUI Bridge

### UIKit to SwiftUI

```swift
struct MySwiftUIView: View {
    var body: some View {
        VStack {
            Text("SwiftUI Content")
            
            // Use any UIKit view in SwiftUI!
            UILabel()
                .text("UIKit Label in SwiftUI")
                .font(.boldSystemFont(ofSize: 18))
                .foregroundColor(.white)
                .background(.systemBlue)
                .cornerRadius(8)
                .swiftui  // ← Magic conversion!
                .frame(height: 50)
            
            createCustomUIKitView()
                .swiftui
                .frame(height: 100)
        }
    }
    
    func createCustomUIKitView() -> UIView {
        // Your existing UIKit components work seamlessly
        let chartView = MyCustomChartView()
        return chartView
    }
}
```

### SwiftUI to UIKit

```swift
class UIKitViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Embed SwiftUI views in UIKit
        let swiftUIView = MySwiftUIView()
        let hostingController = swiftUIView.uikit
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}
```

### SwiftUI-Style UIKit API

```swift
// Chain modifiers like SwiftUI
let styledButton = UIButton()
    .title("Styled Button")
    .font(.boldSystemFont(ofSize: 16))
    .foregroundColor(.white)
    .background(.systemBlue)
    .cornerRadius(12)
    .shadow(color: .black, radius: 4, opacity: 0.3)
    .onTapGesture {
        print("Button tapped!")
    }
```

## 🏗️ Advanced Examples

### Complex Card Layout

```swift
@LayoutBuilder var cardLayout: Layout {
    ZStack(alignment: .topLeading) {
        // Background card
        cardBackgroundView.layout()
            .size(width: 320, height: 140)
            .cornerRadius(12)
        
        // Content overlay
        Vertical(spacing: 12, alignment: .leading) {
            // Header
            Horizontal(spacing: 12, alignment: .center) {
                avatarImageView.layout()
                    .size(width: 40, height: 40)
                
                Vertical(spacing: 4, alignment: .leading) {
                    nameLabel.layout().frame(height: 20)
                    timeLabel.layout().frame(height: 16)
                }
                
                Spacer()
                
                moreButton.layout().size(width: 30, height: 30)
            }
            
            // Content
            messageLabel.layout()
                .frame(height: 40)
            
            // Actions
            Horizontal(spacing: 24, alignment: .center) {
                likeButton.layout().frame(width: 60, height: 30)
                shareButton.layout().frame(width: 60, height: 30)
                Spacer()
            }
        }
        .padding(16)
    }
}
```

### Responsive Layout

```swift
@LayoutBuilder var responsiveLayout: Layout {
    let isCompact = view.bounds.width < 400
    let isTablet = view.bounds.width > 768
    
    if isTablet {
        // Tablet: Side-by-side layout
        Horizontal(spacing: 40, alignment: .top) {
            Vertical(spacing: 20) {
                titleLabel.layout()
                profileSection.layout()
            }
            
            Vertical(spacing: 20) {
                contentView.layout()
                actionsSection.layout()
            }
        }
        .padding(40)
    } else {
        // Phone: Stacked layout
        Vertical(spacing: isCompact ? 12 : 24) {
            titleLabel.layout()
            profileSection.layout()
            contentView.layout()
            actionsSection.layout()
        }
        .padding(isCompact ? 16 : 24)
    }
}
```

### Animated Layout Changes

```swift
func updateLayout(animated: Bool = true) {
    let changes = {
        self.layoutContainer.setBody {
            self.body  // New layout
        }
        self.layoutContainer.layoutSubviews()
    }
    
    if animated {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0
        ) {
            changes()
        }
    } else {
        changes()
    }
}
```

## 📊 Performance Tips

### Best Practices

1. **Use layout() wrapper** for all views
2. **Batch layout updates** when possible
3. **Avoid excessive nesting** (>10 levels)
4. **Use ForEach for dynamic content**
5. **Measure performance** with included tools

### Performance Monitoring

```swift
// Built-in performance monitoring
LayoutPerformanceMonitor.measureLayout(name: "Complex Layout") {
    layoutContainer.layoutSubviews()
}

// Output: 🔧 Layout 'Complex Layout' took 45.67ms
```

### Memory Management

```swift
// Views are automatically managed - no manual addSubview needed!
layoutContainer.setBody {
    Vertical {
        if shouldShowView {
            myView.layout()  // Automatically added
        }
        // myView automatically removed when condition is false
    }
}
```

## 🧪 Testing

Layout includes a comprehensive test suite:

```bash
# Run all tests
swift test

# Run specific test category
swift test --filter LayoutPerformanceTests

# Run quick validation
swift test --filter QuickTestExample
```

### Test Coverage

- ✅ **Core Layout Logic**: 95%+
- ✅ **UIKit Bridge**: 90%+
- ✅ **Performance Tests**: Included
- ✅ **Memory Leak Detection**: Automated
- ✅ **Cross-Platform**: iPhone + iPad

## 📚 Documentation

- 📖 [API Documentation](https://pelagornis.github.io/Layout/documentation/layout/)
- 🎯 [Performance Guide](docs/Performance.md)
- 🔧 [Migration Guide](docs/Migration.md)
- 💡 [Best Practices](docs/BestPractices.md)
- 🐛 [Troubleshooting](docs/Troubleshooting.md)

## 🛠️ Requirements

- iOS 13.0+ / macOS 10.15+
- Xcode 14.0+
- Swift 5.7+

## 🎯 Migration Guide

### From Auto Layout

```swift
// Before: Auto Layout
titleLabel.translatesAutoresizingMaskIntoConstraints = false
NSLayoutConstraint.activate([
    titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
    titleLabel.widthAnchor.constraint(equalToConstant: 200),
    titleLabel.heightAnchor.constraint(equalToConstant: 30)
])

// After: Layout
titleLabel.layout()
    .size(width: 200, height: 30)
    .centerX()
    .position(y: 20)
```

### From PinLayout

```swift
// Before: PinLayout
titleLabel.pin
    .top(view.pin.safeArea.top + 20)
    .hCenter()
    .width(200)
    .height(30)

// After: Layout (declarative!)
@LayoutBuilder var body: Layout {
    titleLabel.layout()
        .size(width: 200, height: 30)
        .centerX()
        .position(y: 20)
}
```

## Inspiration

Layout is inspired by:

- [SwiftUI](https://developer.apple.com/xcode/swiftui/) - Declarative syntax
- [PinLayout](https://github.com/layoutBox/PinLayout) - Performance philosophy
- [Yoga](https://yogalayout.com/) - Flexbox concepts
- [React Native](https://reactnative.dev/) - Cross-platform approach

## License

**swift-layout** is under MIT license. See the [LICENSE](LICENSE) file for more info.