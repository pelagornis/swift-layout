# Layout

![Official](https://badge.pelagornis.com/official.svg)
[![Swift Version](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![iOS Version](https://img.shields.io/badge/iOS-13.0+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![CodeCov](https://img.shields.io/codecov/c/github/pelagornis/swift-layout)](https://codecov.io/gh/pelagornis/swift-layout)
[![Swift Package Manager](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager)

A high-performance, SwiftUI-style declarative layout system that uses manual frame calculations instead of Auto Layout. Layout combines the readability of SwiftUI with the blazing speed of direct frame manipulation.

## ✨ Features

🚀 **High Performance** - Frame-based calculations instead of Auto Layout constraints  
📱 **SwiftUI-Style API** - Familiar declarative syntax with `@LayoutBuilder`  
🔄 **Automatic View Management** - Smart view hierarchy handling  
🌉 **UIKit ↔ SwiftUI Bridge** - Seamless integration between frameworks  
📐 **Flexible Layouts** - VStack, HStack, ZStack, and custom layouts  
🎯 **Zero Dependencies** - Pure UIKit with optional SwiftUI integration  
♿ **Accessibility Ready** - Full VoiceOver and accessibility support  
📚 **DocC Documentation** - Complete API documentation

## 📦 Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/pelagornis/swift-layout.git", from: "1.0.0")
]
```

## 🚀 Quick Start

### SwiftUI-Style Usage

```swift
import Layout

class MyViewController: UIViewController, Layout {
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

        // SwiftUI-style: Content is automatically centered!
        layoutContainer.setBody { self.body }
    }

    @LayoutBuilder var body: some Layout {
        // Content is automatically centered like SwiftUI
        titleLabel.layout()
            .frame(height: 30)

        actionButton.layout()
            .size(width: 240, height: 50)
    }
}
```

### Manual Layout (Advanced)

```swift
@LayoutBuilder var body: some Layout {
    VStack(spacing: 24, alignment: .center) {
        Spacer(minLength: 60)

        titleLabel.layout()
            .frame(height: 30)

        actionButton.layout()
            .size(width: 240, height: 50)

        Spacer()
    }
    .padding(20)
}
```

## 🎨 Layout Components

### Stack Layouts

```swift
// Vertical Stack (like VStack)
VStack(spacing: 16, alignment: .center) {
    titleLabel.layout()
    subtitleLabel.layout()
    actionButton.layout()
}

// Horizontal Stack (like HStack)
HStack(spacing: 12, alignment: .center) {
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

## 🏗️ Advanced Examples

### Complex Card Layout

```swift
@LayoutBuilder var cardLayout: some Layout {
    ZStack(alignment: .topLeading) {
        // Background card
        cardBackgroundView.layout()
            .size(width: 320, height: 140)
            .cornerRadius(12)

        // Content overlay
        VStack(spacing: 12, alignment: .leading) {
            // Header
            HStack(spacing: 12, alignment: .center) {
                avatarImageView.layout()
                    .size(width: 40, height: 40)

                VStack(spacing: 4, alignment: .leading) {
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
            HStack(spacing: 24, alignment: .center) {
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
@LayoutBuilder var responsiveLayout: some Layout {
    let isCompact = view.bounds.width < 400
    let isTablet = view.bounds.width > 768

    if isTablet {
        // Tablet: Side-by-side layout
        HStack(spacing: 40, alignment: .top) {
            VStack(spacing: 20) {
                titleLabel.layout()
                profileSection.layout()
            }

            VStack(spacing: 20) {
                contentView.layout()
                actionsSection.layout()
            }
        }
        .padding(40)
    } else {
        // Phone: Stacked layout
        VStack(spacing: isCompact ? 12 : 24) {
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

## Debugging System

### LayoutDebugger Configuration

```swift
// Disable all debugging by default
LayoutDebugger.shared.disableAll()

// Selective activation
LayoutDebugger.shared.enableBasic()        // Basic debugging
LayoutDebugger.shared.enableSpacerOnly()   // Spacer-related only
LayoutDebugger.shared.enableAll()          // All debugging

// Individual settings
LayoutDebugger.shared.isEnabled = true
LayoutDebugger.shared.enableViewHierarchy = true
LayoutDebugger.shared.enableSpacerCalculation = true
```

### Debug Categories

- 🔧 **Layout**: Layout calculation process
- 🏗️ **Hierarchy**: View hierarchy structure
- 📐 **Frame**: Frame setting
- 🔲 **Spacer**: Spacer calculation
- ⚡ **Performance**: Performance monitoring

### Tree-style View Analysis

```swift
// Analyze view hierarchy in tree format
LayoutDebugger.shared.analyzeViewHierarchy(
    layoutContainer,
    title: "LAYOUT ANALYSIS"
)
```

**Output Example:**

```
🔍 ===== LAYOUT ANALYSIS =====
🔍 LayoutContainer
├─ Frame: (39.3, 170.4, 314.4, 511.2)
├─ Background: systemYellowColor
├─ Hidden: false
└─ Alpha: 1.0
  └─ Child 0: VStack
    ├─ Frame: (40.0, 40.0, 234.4, 431.2)
    ├─ Background: nil
    ├─ Hidden: false
    └─ Alpha: 1.0
      └─ Child 0: UILabel
        ├─ Frame: (56.0, 40.0, 82.7, 21.7)
        ├─ Background: systemBlueColor
        ├─ Hidden: false
        ├─ Alpha: 1.0
        └─ Text: "Welcome"
```

## Performance Monitoring

### Using LayoutPerformanceMonitor

```swift
// Start performance measurement
LayoutPerformanceMonitor.shared.startMeasuring("layout_calculation")

// Perform layout calculation
let result = layout.calculateLayout(in: bounds)

// End performance measurement
LayoutPerformanceMonitor.shared.endMeasuring("layout_calculation")

// Print performance report
LayoutPerformanceMonitor.shared.printPerformanceReport()
```


## 📚 Documentation

## 🛠️ Requirements

- iOS 13.0+ / macOS 10.15+
- Xcode 16.0+
- Swift 6.0+

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
