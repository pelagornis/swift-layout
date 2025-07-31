# SwiftUI-like Layout System

A custom layout library that implements SwiftUI's declarative layout system based on UIKit.

## 📋 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Basic Usage](#basic-usage)
- [Layout Components](#layout-components)
- [Layout Modifiers](#layout-modifiers)
- [Debugging System](#debugging-system)
- [Performance Monitoring](#performance-monitoring)
- [Examples](#examples)

## Overview

This layout system recreates SwiftUI's declarative syntax and behavior in UIKit, allowing iOS developers to compose complex layouts using familiar SwiftUI-style syntax.

```swift
// SwiftUI-style declarative layout
layoutContainer.setBody {
    VStack(spacing: 20) {
        titleLabel.layout()
            .size(width: 300, height: 50)
            .background(.systemBlue)

        HStack(spacing: 10) {
            leftButton.layout()
                .size(width: 100, height: 40)
            Spacer()
            rightButton.layout()
                .size(width: 100, height: 40)
        }
        .padding(20)
    }
}
```

## Key Features

### ✨ **SwiftUI Compatibility**

- Familiar SwiftUI syntax and behavior
- Declarative layout composition
- Chainable modifiers

### 🔧 **Powerful Layout System**

- Automatic size calculation
- Flexible space distribution (Spacer)
- Support for nested complex layouts

### 🐛 **Advanced Debugging**

- Selective debug logging
- Tree-style view hierarchy analysis
- Performance monitoring

### ⚡ **Performance Optimized**

- Efficient layout calculations
- Minimal view updates
- Memory optimized

## Basic Usage

### 1. LayoutContainer Setup

```swift
class ViewController: UIViewController {
    private let layoutContainer = LayoutContainer()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayoutContainer()
    }

    private func setupLayoutContainer() {
        view.addSubview(layoutContainer)
        layoutContainer.backgroundColor = .systemYellow
        // Auto Layout or manual frame setup
    }
}
```

### 2. Layout Composition

```swift
private func setupLayout() {
    let titleLabel = UILabel()
    titleLabel.text = "Welcome"
    titleLabel.textAlignment = .center

    let submitButton = UIButton(type: .system)
    submitButton.setTitle("Submit", for: .normal)

    layoutContainer.setBody {
        VStack(spacing: 15) {
            titleLabel.layout()
                .size(width: 250, height: 40)
                .background(.systemBlue)
                .cornerRadius(8)

            submitButton.layout()
                .size(width: 120, height: 40)
                .background(.systemGreen)
                .cornerRadius(8)
        }
        .padding(20)
    }
}
```

## Layout Components

### VStack - Vertical Stack

Arranges views vertically.

```swift
VStack(spacing: 10, alignment: .center) {
    topView.layout()
    middleView.layout()
    bottomView.layout()
}
```

**Parameters:**

- `spacing`: Space between views (default: 0)
- `alignment`: Alignment type (.leading, .center, .trailing)

### HStack - Horizontal Stack

Arranges views horizontally.

```swift
HStack(spacing: 15, alignment: .center) {
    leftView.layout()
    centerView.layout()
    rightView.layout()
}
```

**Parameters:**

- `spacing`: Space between views (default: 0)
- `alignment`: Alignment type (.top, .center, .bottom)

### ZStack - Overlay Stack

Arranges views in z-axis overlay.

```swift
ZStack(alignment: .center) {
    backgroundView.layout()
    overlayView.layout()
    topView.layout()
}
```

**Parameters:**

- `alignment`: Alignment type (.topLeading, .center, .bottomTrailing, etc.)

### Spacer - Flexible Space

A flexible component that automatically fills available space.

```swift
HStack {
    leftView.layout()
    Spacer()  // Automatically fills center space
    rightView.layout()
}

VStack {
    topView.layout()
    Spacer(minLength: 20)  // Minimum 20pt space
    bottomView.layout()
}
```

### Grid - Grid Layout

Provides grid layout with rows and columns.

```swift
Grid(columns: 2, spacing: 10) {
    view1.layout()
    view2.layout()
    view3.layout()
    view4.layout()
}
```

## Layout Modifiers

### Size Control

```swift
view.layout()
    .size(width: 100, height: 50)           // Fixed size
    .size(CGSize(width: 100, height: 50))   // Using CGSize
```

### Padding

```swift
view.layout()
    .padding(20)                    // 20pt on all sides
    .padding(.horizontal, 15)       // 15pt left and right only
    .padding(.vertical, 10)         // 10pt top and bottom only
    .padding(EdgeInsets(top: 5, left: 10, bottom: 5, right: 10))  // Individual specification
```

### Background Color

```swift
view.layout()
    .background(.systemBlue)        // System color
    .background(UIColor.red)        // UIColor
    .background(Color.blue)         // SwiftUI Color
```

### Corner Radius

```swift
view.layout()
    .cornerRadius(8)                // All corners
    .cornerRadius(12, corners: [.topLeft, .topRight])  // Specific corners
```

### Position Adjustment

```swift
view.layout()
    .offset(x: 10, y: 5)           // Position offset
    .position(x: 100, y: 200)      // Absolute position
```

### Center Alignment

```swift
view.layout()
    .center()                       // Center in parent view
```

### Aspect Ratio

```swift
view.layout()
    .aspectRatio(16.0/9.0, contentMode: .fit)  // Maintain 16:9 ratio
```

### Overlay

```swift
backgroundView.layout()
    .overlay(
        overlayView.layout()
            .size(width: 50, height: 50)
    )
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

## Examples

### Basic Login Screen

```swift
private func createLoginLayout() {
    let titleLabel = UILabel()
    titleLabel.text = "Login"
    titleLabel.font = .boldSystemFont(ofSize: 24)
    titleLabel.textAlignment = .center

    let emailField = UITextField()
    emailField.placeholder = "Email"
    emailField.borderStyle = .roundedRect

    let passwordField = UITextField()
    passwordField.placeholder = "Password"
    passwordField.isSecureTextEntry = true
    passwordField.borderStyle = .roundedRect

    let loginButton = UIButton(type: .system)
    loginButton.setTitle("Login", for: .normal)
    loginButton.backgroundColor = .systemBlue
    loginButton.setTitleColor(.white, for: .normal)

    layoutContainer.setBody {
        VStack(spacing: 20) {
            titleLabel.layout()
                .size(width: 200, height: 40)

            VStack(spacing: 15) {
                emailField.layout()
                    .size(width: 280, height: 40)

                passwordField.layout()
                    .size(width: 280, height: 40)
            }

            loginButton.layout()
                .size(width: 120, height: 44)
                .cornerRadius(8)
        }
        .padding(40)
    }
}
```

### Complex Card Layout

```swift
private func createCardLayout() {
    let profileImage = UIImageView()
    profileImage.backgroundColor = .systemGray4
    profileImage.layer.cornerRadius = 25

    let nameLabel = UILabel()
    nameLabel.text = "John Developer"
    nameLabel.font = .boldSystemFont(ofSize: 18)

    let roleLabel = UILabel()
    roleLabel.text = "iOS Developer"
    roleLabel.font = .systemFont(ofSize: 14)
    roleLabel.textColor = .systemGray

    let followButton = UIButton(type: .system)
    followButton.setTitle("Follow", for: .normal)
    followButton.backgroundColor = .systemBlue
    followButton.setTitleColor(.white, for: .normal)

    let descriptionLabel = UILabel()
    descriptionLabel.text = "Passionate developer who loves SwiftUI and UIKit."
    descriptionLabel.numberOfLines = 0
    descriptionLabel.font = .systemFont(ofSize: 14)

    layoutContainer.setBody {
        VStack(spacing: 0) {
            // Header section
            HStack(spacing: 15) {
                profileImage.layout()
                    .size(width: 50, height: 50)

                VStack(spacing: 4, alignment: .leading) {
                    nameLabel.layout()
                    roleLabel.layout()
                }

                Spacer()

                followButton.layout()
                    .size(width: 80, height: 32)
                    .cornerRadius(16)
            }
            .padding(20)

            // Separator
            UIView().layout()
                .size(height: 1)
                .background(.systemGray5)

            // Description section
            descriptionLabel.layout()
                .padding(20)
        }
        .background(.systemBackground)
        .cornerRadius(12)
        .padding(20)
    }
}
```

### Spacer Usage Examples

```swift
private func createSpacerExamples() {
    let topLabel = UILabel()
    topLabel.text = "Top"
    topLabel.textAlignment = .center

    let bottomLabel = UILabel()
    bottomLabel.text = "Bottom"
    bottomLabel.textAlignment = .center

    let leftButton = UIButton(type: .system)
    leftButton.setTitle("Left", for: .normal)

    let rightButton = UIButton(type: .system)
    rightButton.setTitle("Right", for: .normal)

    layoutContainer.setBody {
        VStack(spacing: 0) {
            // Vertical Spacer example
            VStack(spacing: 0) {
                topLabel.layout()
                    .size(width: 200, height: 40)
                    .background(.systemBlue)

                Spacer()  // Automatically fills center space

                bottomLabel.layout()
                    .size(width: 200, height: 40)
                    .background(.systemGreen)
            }
            .size(height: 200)
            .background(.systemGray6)

            // Horizontal Spacer example
            HStack(spacing: 0) {
                leftButton.layout()
                    .size(width: 80, height: 40)
                    .background(.systemRed)

                Spacer()  // Automatically fills center space

                rightButton.layout()
                    .size(width: 80, height: 40)
                    .background(.systemOrange)
            }
            .size(height: 60)
            .background(.systemGray5)
        }
        .padding(20)
    }
}
```

## License

This project is distributed under the MIT License.

---

For more information or questions, please use the Issues section of the project repository.
