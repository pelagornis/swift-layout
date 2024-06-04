# Swift Layout
![Official](https://img.shields.io/badge/project-official-green.svg?colorA=303033&colorB=226af6&label=Pelagornis)
![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
[![License](https://img.shields.io/github/license/pelagornis/swift-layout)](https://github.com/pelagornis/swift-layout/blob/main/LICENSE)
![Platform](https://img.shields.io/badge/platforms-iOS%2013.0%7C%20tvOS%2013.0%7C%20macOS%2010.13-red.svg)

`swift-layout` is a DSL to make Auto Layout easy on both iOS and macOS.

## Requirements
- iOS 13.0+ / macOS 10.13+ / tvOS 13.0+
- Xcode 15.0+
- Swift 5.0+

## Installation
swift-layout was deployed as Swift Package Manager. Package to install in a project. Add as a dependent item within the swift manifest.
```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/pelagornis/swift-layout.git", from: "1.0.0")
    ],
    ...
)
```
And then adding the product to any target that needs access to the library:

```swift
.product(name: "Layout", package: "swift-layout"),
```

Then import the Builder from thr location you want to use.
```swift
import Layout
```

## Usage

DSL by @resultBuilder make easy allow relation of superview and subviews and autolayout constraints declaratively.

```swift
let root: UIView
let headerView: UIView
let titleLabel: UILabel
let descriptionLabel: UILabel

// root.addSubview(titleLabel)
root {
  titleLabel
}

// root.addSubview(titleLabel)
// root.addSubview(descriptionLabel)
root {
  titleLabel
  descriptionLabel
}

// root.addSubview(headerView)
// headerView.addSubview(titleLabel)
// headerView.addSubview(descriptionLabel)
root {
  headerView {
    titleLabel
    descriptionLabel
  }
}
```

## Using in SwiftUI
```swift
class RootUIView: UIView, Layout {
  var body: some ViewLayout { 
    ...
  }
}

...

struct RootView: View {
  var body: some View {
    VStack {
      ...
	    RootUIView().swiftUI
      ...
    }
  }
}

struct RootUIView_Previews: PreviewProvider {
  static var previews: some Previews {
    RootUIView().swiftUI
  }
}
```

## Using Macro
```swift
@Layout
class RootUIView: UIView {
  var body: some ViewLayout { 
    ...
  }
}
```
## Other libraries

The Layout was built on a foundation of ideas started by other libraries, in particular [Snapkit](https://github.com/SnapKit/SnapKit.git) and [SwiftLayout](https://github.com/ioskrew/SwiftLayout).

## License
**swift-layout** is under MIT license. See the [LICENSE](LICENSE) file for more info.