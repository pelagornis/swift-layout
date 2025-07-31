# Layout System

A SwiftUI-inspired declarative layout framework for UIKit.

## Overview

The Layout System provides a declarative, SwiftUI-like approach to building user interfaces with UIKit. It enables developers to compose complex layouts using familiar syntax while maintaining the flexibility and performance of UIKit.

### Key Components

The framework consists of several core components:

- **Layout Protocol**: The foundation that all layout components conform to
- **Stack Layouts**: `VStack`, `HStack`, and `ZStack` for arranging views
- **Spacer**: Flexible space component for dynamic spacing
- **Layout Container**: The hosting view that manages the layout hierarchy
- **Modifiers**: Chainable methods for customizing layout behavior

## Getting Started

### Basic Setup

1. Create a `LayoutContainer` instance
2. Add it to your view hierarchy
3. Use `LayoutContainer/setBody(_:)` to define your layout

```swift
class ViewController: UIViewController {
    private let layoutContainer = LayoutContainer()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(layoutContainer)
        layoutContainer.frame = view.bounds

        layoutContainer.setBody {
            VStack(spacing: 20) {
                titleLabel.layout()
                    .size(width: 300, height: 50)
                    .background(.systemBlue)

                HStack(spacing: 10) {
                    leftButton.layout()
                    Spacer()
                    rightButton.layout()
                }
                .padding(20)
            }
        }
    }
}
```

### Creating Views

Transform any UIView into a layout component using the `.layout()` method:

```swift
let label = UILabel()
label.text = "Hello, World!"

layoutContainer.setBody {
    VStack {
        label.layout()
            .size(width: 200, height: 30)
            .background(.systemBlue)
            .cornerRadius(8)
    }
}
```

## Stack Layouts

### VStack - Vertical Stack

Arranges child views vertically with customizable spacing and alignment.

```swift
VStack(spacing: 15, alignment: .center) {
    headerLabel.layout()
    contentLabel.layout()
    footerButton.layout()
}
```

**Parameters:**

- `spacing`: The distance between adjacent child views (default: 0)
- `alignment`: How to align child views horizontally (`.leading`, `.center`, `.trailing`)

### HStack - Horizontal Stack

Arranges child views horizontally with customizable spacing and alignment.

```swift
HStack(spacing: 10, alignment: .center) {
    iconView.layout()
    titleLabel.layout()
    Spacer()
    actionButton.layout()
}
```

**Parameters:**

- `spacing`: The distance between adjacent child views (default: 0)
- `alignment`: How to align child views vertically (`.top`, `.center`, `.bottom`)

### ZStack - Overlay Stack

Overlays child views on top of each other with customizable alignment.

```swift
ZStack(alignment: .topTrailing) {
    backgroundImage.layout()
    overlayView.layout()
    closeButton.layout()
        .size(width: 30, height: 30)
}
```

**Parameters:**

- `alignment`: How to align child views within the stack bounds

## Spacer

`Spacer` creates flexible space that expands to fill available space in stack layouts.

### Basic Usage

```swift
HStack {
    leftButton.layout()
    Spacer()  // Expands to push buttons apart
    rightButton.layout()
}
```

### Minimum Length

Specify a minimum length to prevent the spacer from shrinking below a certain size:

```swift
VStack {
    topContent.layout()
    Spacer(minLength: 50)  // At least 50 points
    bottomContent.layout()
}
```

## Layout Modifiers

Modifiers are chainable methods that customize layout behavior:

### Size Control

```swift
view.layout()
    .size(width: 100, height: 50)
    .size(CGSize(width: 100, height: 50))
```

### Spacing and Padding

```swift
view.layout()
    .padding(20)                    // All sides
    .padding(.horizontal, 15)       // Left and right
    .padding(.vertical, 10)         // Top and bottom
```

### Visual Styling

```swift
view.layout()
    .background(.systemBlue)
    .cornerRadius(8)
    .overlay(
        badgeView.layout()
            .size(width: 20, height: 20)
    )
```

### Position and Alignment

```swift
view.layout()
    .center()                       // Center in parent
    .offset(x: 10, y: 5)           // Position offset
    .aspectRatio(16.0/9.0, contentMode: .fit)
```

## Debugging

The framework includes comprehensive debugging tools via `LayoutDebugger`.

### Enable Debugging

```swift
// Enable all debugging
LayoutDebugger.shared.enableAll()

// Enable specific categories
LayoutDebugger.shared.isEnabled = true
LayoutDebugger.shared.enableViewHierarchy = true
LayoutDebugger.shared.enableSpacerCalculation = true
```

### Debug Categories

- **Layout**: Layout calculation processes
- **Hierarchy**: View hierarchy structure
- **Frame**: Frame setting operations
- **Spacer**: Spacer calculations
- **Performance**: Performance monitoring

### View Hierarchy Analysis

Get detailed tree-style output of your layout structure:

```swift
LayoutDebugger.shared.analyzeViewHierarchy(
    layoutContainer,
    title: "My Layout Analysis"
)
```

## Performance

### Best Practices

1. **Minimize Layout Calculations**: Avoid unnecessary layout updates
2. **Use Appropriate Sizes**: Specify reasonable sizes for views
3. **Disable Debug Logs**: Turn off debugging in production builds
4. **Reuse Views**: Create views once and reuse them when possible

### Performance Monitoring

Monitor layout performance using `LayoutPerformanceMonitor`:

```swift
LayoutPerformanceMonitor.shared.startMeasuring("my_layout")
// Perform layout operations
LayoutPerformanceMonitor.shared.endMeasuring("my_layout")
LayoutPerformanceMonitor.shared.printPerformanceReport()
```

## Common Patterns

### Navigation Headers

```swift
HStack(spacing: 15) {
    backButton.layout()
        .size(width: 44, height: 44)

    titleLabel.layout()
        .size(height: 44)

    Spacer()

    actionButton.layout()
        .size(width: 44, height: 44)
}
.padding(.horizontal, 16)
```

### Card Layouts

```swift
VStack(spacing: 0) {
    // Header
    HStack(spacing: 12) {
        avatarView.layout()
            .size(width: 40, height: 40)

        VStack(spacing: 4, alignment: .leading) {
            nameLabel.layout()
            subtitleLabel.layout()
        }

        Spacer()

        menuButton.layout()
            .size(width: 24, height: 24)
    }
    .padding(16)

    // Content
    contentView.layout()
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
}
.background(.systemBackground)
.cornerRadius(12)
```

### Form Layouts

```swift
VStack(spacing: 20) {
    ForEach(fields) { field in
        VStack(spacing: 8, alignment: .leading) {
            field.titleLabel.layout()
                .size(height: 20)

            field.textField.layout()
                .size(height: 44)
                .background(.systemGray6)
                .cornerRadius(8)
        }
    }

    Spacer(minLength: 20)

    submitButton.layout()
        .size(height: 50)
        .background(.systemBlue)
        .cornerRadius(25)
}
.padding(20)
```

## Topics

### Layout Components

- `Layout`
- `VStack`
- `HStack`
- `ZStack`
- `Spacer`
- `LayoutContainer`

### Layout Modifiers

- `ViewLayout`
- Size modifiers
- Padding modifiers
- Background modifiers
- Position modifiers

### Debugging and Performance

- `LayoutDebugger`
- `LayoutPerformanceMonitor`
- Debug categories
- Performance monitoring

### Advanced Features

- Custom layout components
- Layout builders
- Conditional layouts
- Array layouts
