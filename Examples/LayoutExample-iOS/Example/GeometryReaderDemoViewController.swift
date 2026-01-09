import UIKit
import Layout

/// Demonstrates the powerful features of GeometryReader using Layout library
final class GeometryReaderDemoViewController: BaseViewController, Layout {
    
    // MARK: - UI Components for Live Updates
    
    private let sizeLabel = UILabel()
    private let centerLabel = UILabel()
    private let globalLabel = UILabel()
    private let safeAreaLabel = UILabel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "GeometryReader"
        view.backgroundColor = .systemBackground
        
        // Enable layout debugging
        enableLayoutDebugging = true
        
        setupLiveLabels()
    }
    
    private func setupLiveLabels() {
        [sizeLabel, centerLabel, globalLabel, safeAreaLabel].forEach {
            $0.font = .monospacedSystemFont(ofSize: 13, weight: .medium)
            $0.textColor = .systemIndigo
            $0.textAlignment = .left
        }
    }
    
    override func setLayout() {
        layoutContainer.updateBody {
            self.body
        }
    }
    
    // MARK: - Layout Body
    
    @LayoutBuilder
    var body: some Layout {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                headerSection
                
                proportionalLayoutWithGeometry
                responsiveGridWithGeometry
                liveGeometryInfo
                positionBasedEffect
                
                Spacer(minLength: 40)
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some Layout {
        VStack(alignment: .leading, spacing: 6) {
            createLabel(
                text: "GeometryReader Examples",
                font: .systemFont(ofSize: 26, weight: .bold),
                color: .label
            ).layout().size(width: 350, height: 32)
            
            createLabel(
                text: "Dynamic layouts using GeometryProxy",
                font: .systemFont(ofSize: 13, weight: .regular),
                color: .secondaryLabel
            ).layout().size(width: 350, height: 18)
        }
        .padding(UIEdgeInsets(top: 16, left: 20, bottom: 8, right: 20))
    }
    
    // MARK: - Demo 1: Proportional Layout with GeometryReader
    
    private var proportionalLayoutWithGeometry: some Layout {
        VStack(alignment: .center, spacing: 10) {
            sectionHeader(title: "1. Proportional Layout", subtitle: "Using GeometryProxy.size for dynamic sizing")
            
            createProportionalGeometryReader()
                .layout()
                .size(width: 360, height: 140)
                .background(.tertiarySystemBackground)
                .cornerRadius(16)
        }
        .padding(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    }
    
    private func createProportionalGeometryReader() -> GeometryReader {
        GeometryReader { [weak self] proxy, container in
            guard let self = self else { return }
            
            let width = proxy.size.width - 24
            let leftWidth = width * 0.4 - 4
            let rightWidth = width * 0.6 - 4
            
            // Row 1: 40% / 60%
            let leftBox = self.makeColorBox(text: "40%\n\(Int(leftWidth))px", color: .systemBlue)
            leftBox.frame = CGRect(x: 12, y: 12, width: leftWidth, height: 70)
            container.addSubview(leftBox)
            
            let rightBox = self.makeColorBox(text: "60%\n\(Int(rightWidth))px", color: .systemPurple)
            rightBox.frame = CGRect(x: 12 + leftWidth + 8, y: 12, width: rightWidth, height: 70)
            container.addSubview(rightBox)
            
            // Row 2: 100%
            let fullBox = self.makeColorBox(text: "100% width • \(Int(width))px", color: .systemGreen)
            fullBox.frame = CGRect(x: 12, y: 90, width: width, height: 36)
            container.addSubview(fullBox)
        }
    }
    
    // MARK: - Demo 2: Responsive Grid with GeometryReader
    
    private var responsiveGridWithGeometry: some Layout {
        VStack(alignment: .center, spacing: 10) {
            sectionHeader(title: "2. Responsive Grid", subtitle: "Grid items sized from GeometryProxy")
            
            createGridGeometryReader()
                .layout()
                .size(width: 360, height: 140)
                .background(.tertiarySystemBackground)
                .cornerRadius(16)
        }
        .padding(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    }
    
    private func createGridGeometryReader() -> GeometryReader {
        GeometryReader { [weak self] proxy, container in
            guard let self = self else { return }
            
            let containerWidth = proxy.size.width - 24
            let spacing: CGFloat = 8
            let columns: CGFloat = 3
            let itemWidth = (containerWidth - spacing * (columns - 1)) / columns
            let itemHeight: CGFloat = 56
            
            let colors: [UIColor] = [.systemRed, .systemOrange, .systemYellow, .systemGreen, .systemBlue, .systemIndigo]
            
            for row in 0..<2 {
                for col in 0..<3 {
                    let index = row * 3 + col
                    let x = 12 + CGFloat(col) * (itemWidth + spacing)
                    let y = 12 + CGFloat(row) * (itemHeight + spacing)
                    
                    let cell = self.makeGridCell(number: "\(index + 1)", color: colors[index])
                    cell.frame = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)
                    container.addSubview(cell)
                }
            }
        }
    }
    
    // MARK: - Demo 3: Live Geometry Information
    
    private var liveGeometryInfo: some Layout {
        VStack(alignment: .center, spacing: 10) {
            sectionHeader(title: "3. Live Geometry Info", subtitle: "Real-time GeometryProxy values")
            
            createLiveInfoGeometryReader()
                .layout()
                .size(width: 360, height: 140)
                .background(UIColor.systemIndigo.withAlphaComponent(0.1))
                .cornerRadius(16)
        }
        .padding(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    }
    
    private func createLiveInfoGeometryReader() -> GeometryReader {
        GeometryReader { [sizeLabel, centerLabel, globalLabel, safeAreaLabel] proxy, container in
            sizeLabel.text = "📐 Size: \(Int(proxy.size.width)) × \(Int(proxy.size.height))"
            centerLabel.text = "⭕ Center: (\(Int(proxy.size.width/2)), \(Int(proxy.size.height/2)))"
            globalLabel.text = "🌍 Global: x:\(Int(proxy.globalFrame.minX)) y:\(Int(proxy.globalFrame.minY))"
            safeAreaLabel.text = "🛡️ SafeArea: T:\(Int(proxy.safeAreaInsets.top)) B:\(Int(proxy.safeAreaInsets.bottom))"
            
            let padding: CGFloat = 16
            var yOffset: CGFloat = padding
            
            for label in [sizeLabel, centerLabel, globalLabel, safeAreaLabel] {
                label.frame = CGRect(x: padding, y: yOffset, width: proxy.size.width - padding * 2, height: 24)
                container.addSubview(label)
                yOffset += 28
            }
        }
    }
    
    // MARK: - Demo 4: Position-based Effect with GeometryReader
    
    private var positionBasedEffect: some Layout {
        VStack(alignment: .center, spacing: 10) {
            sectionHeader(title: "4. Position-based Effect", subtitle: "Bar heights from GeometryProxy.size")
            
            createPositionEffectGeometryReader()
                .layout()
                .size(width: 360, height: 180)
                .background(.tertiarySystemBackground)
                .cornerRadius(16)
        }
        .padding(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    }
    
    private func createPositionEffectGeometryReader() -> GeometryReader {
        GeometryReader { proxy, container in
            let maxHeight = proxy.size.height - 32
            let spacing: CGFloat = 6
            let barCount = 9
            let barWidth = (proxy.size.width - 32 - CGFloat(barCount - 1) * spacing) / CGFloat(barCount)
            
            for i in 0..<barCount {
                let progress = Double(i) / Double(barCount - 1)
                let sineValue = sin(progress * .pi)
                let height = 30 + (maxHeight - 30) * sineValue
                let hue = progress * 0.8
                
                let bar = UIView()
                bar.backgroundColor = UIColor(hue: hue, saturation: 0.7, brightness: 0.85, alpha: 1)
                bar.layer.cornerRadius = 4
                
                let x = 16 + CGFloat(i) * (barWidth + spacing)
                let y = proxy.size.height - 16 - height
                bar.frame = CGRect(x: x, y: y, width: barWidth, height: height)
                container.addSubview(bar)
            }
        }
    }
    
    // MARK: - Section Header
    
    private func sectionHeader(title: String, subtitle: String) -> some Layout {
        VStack(alignment: .leading, spacing: 2) {
            createLabel(
                text: title,
                font: .systemFont(ofSize: 16, weight: .bold),
                color: .label
            ).layout().size(width: 340, height: 20)
            
            createLabel(
                text: subtitle,
                font: .systemFont(ofSize: 11, weight: .regular),
                color: .secondaryLabel
            ).layout().size(width: 340, height: 14)
        }
        .padding(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
        .layout()
        .size(width: 360, height: 50)
        .background(.secondarySystemBackground)
        .cornerRadius(12)
    }
    
    // MARK: - Helper: Label Factory
    
    private func createLabel(text: String, font: UIFont, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.numberOfLines = 0
        return label
    }
    
    // MARK: - Helper: Color Box
    
    private func makeColorBox(text: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = color.withAlphaComponent(0.2)
        container.layer.borderWidth = 2
        container.layer.borderColor = color.cgColor
        container.layer.cornerRadius = 10
        
        let label = UILabel()
        label.text = text
        label.font = .monospacedSystemFont(ofSize: 11, weight: .bold)
        label.textColor = color
        label.textAlignment = .center
        label.numberOfLines = 2
        container.addSubview(label)
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return container
    }
    
    // MARK: - Helper: Grid Cell
    
    private func makeGridCell(number: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = color.withAlphaComponent(0.25)
        container.layer.cornerRadius = 8
        container.layer.borderWidth = 2
        container.layer.borderColor = color.cgColor
        
        let label = UILabel()
        label.text = number
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = color
        label.textAlignment = .center
        container.addSubview(label)
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return container
    }
}
