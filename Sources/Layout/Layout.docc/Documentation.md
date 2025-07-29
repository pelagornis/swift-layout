# `Layout`

A high-performance, SwiftUI-style declarative layout system that uses manual frame calculations instead of Auto Layout. Layout combines the readability of SwiftUI with the blazing speed of direct frame manipulation.

## Overview

🚀 **High Performance** - Frame-based calculations instead of Auto Layout constraints  
📱 **SwiftUI-Style API** - Familiar declarative syntax with `@LayoutBuilder`  
🔄 **Automatic View Management** - Smart view hierarchy handling  
🌉 **UIKit ↔ SwiftUI Bridge** - Seamless integration between frameworks  
📐 **Flexible Layouts** - VStack, HStack, ZStack, and custom layouts  
🎯 **Zero Dependencies** - Pure UIKit with optional SwiftUI integration  
♿ **Accessibility Ready** - Full VoiceOver and accessibility support  
📚 **DocC Documentation** - Complete API documentation  
🎨 **Overlay System** - SwiftUI-style overlay modifiers for any layout  
🔧 **Z-Index Support** - ZStack with proper layering and alignment

## Features

### **Layout Containers**

- **VStack** - Vertical stacking with spacing and alignment
- **HStack** - Horizontal stacking with spacing and alignment
- **ZStack** - Z-axis stacking with multiple alignment options
- **Custom Layouts** - Create your own layout containers

### **Modifiers**

- **`.overlay()`** - Add overlays to any layout (SwiftUI-style)
- **`.padding()`** - Add padding around layouts
- **`.size()`** - Set explicit sizes for views
- **`.background()`** - Add backgrounds to layouts
- **`.cornerRadius()`** - Apply corner radius to layouts

### **Alignment Options**

- **`.center`** - Center alignment
- **`.topLeading`** - Top-left alignment
- **`.topTrailing`** - Top-right alignment
- **`.bottomLeading`** - Bottom-left alignment
- **`.bottomTrailing`** - Bottom-right alignment

## Quick Start

```swift
import Layout

class ViewController: UIViewController, Layout {
    private let layoutContainer = LayoutContainer()

    @LayoutBuilder var body: some Layout {
        VStack(spacing: 16, alignment: .center) {
            // ZStack example (layout container)
            ZStack(alignment: .center) {
                backgroundView.layout()
                    .size(width: 200, height: 100)

                label.layout()
                    .size(width: 120, height: 30)
            }

            // Overlay example (modifier)
            button.layout()
                .size(width: 120, height: 40)
                .overlay {
                    badge.layout()
                        .size(width: 20, height: 20)
                }

            // Nested overlays
            titleLabel.layout()
                .overlay {
                    backgroundView.layout()
                        .size(width: 30, height: 15)
                }
                .overlay {
                    badge.layout()
                        .size(width: 20, height: 10)
                }
        }
        .padding(16)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(layoutContainer)
        layoutContainer.frame = view.bounds
        layoutContainer.setBody { self.body }
    }
}
```

## Architecture

### **Core Components**

- **`Layout` Protocol** - Base protocol for all layouts
- **`LayoutBuilder`** - Result builder for declarative syntax
- **`LayoutContainer`** - UIView subclass that manages layout hierarchy
- **`LayoutResult`** - Contains calculated frames and total size

### **Stack Components**

- **`VStack`** - Vertical stacking implementation
- **`HStack`** - Horizontal stacking implementation
- **`ZStack`** - Z-axis stacking with alignment support

### **Modifier System**

- **`OverlayLayout`** - Generic overlay implementation
- **`PaddingModifier`** - Padding modifier
- **`SizeModifier`** - Size modifier
- **`BackgroundModifier`** - Background modifier

## Performance

- **Frame-based calculations** instead of Auto Layout constraints
- **Single-pass layout** calculation
- **Minimal memory allocation** during layout updates
- **Efficient view hierarchy** management
- **Background thread support** for complex layouts

## SwiftUI Compatibility

The Layout system provides SwiftUI-style APIs while maintaining UIKit performance:

```swift
// SwiftUI-style syntax
VStack(spacing: 12, alignment: .center) {
    Text("Hello")
    Button("World") { }
}
.overlay {
    Image(systemName: "star")
}
.padding(16)
```

## Topics
