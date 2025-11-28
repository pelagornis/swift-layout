import UIKit
import Layout

/// Demonstrates the advanced features of the Layout library
final class AdvancedFeaturesViewController: BaseViewController, Layout {
    
    // MARK: - Properties
    
    private var isAnimating = false
    private var animatedOffset: CGFloat = 0
    
    // MARK: - UI Components (필요한 참조만)
    
    private let animationDemoView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 25
        return view
    }()
    
    private let animateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Animate", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemIndigo
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let environmentLabel: UILabel = {
        let label = UILabel()
        label.text = "Environment: Light Mode"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let performanceLabel: UILabel = {
        let label = UILabel()
        label.text = "60 FPS"
        label.font = .monospacedSystemFont(ofSize: 14, weight: .bold)
        label.textColor = .systemGreen
        label.textAlignment = .center
        return label
    }()
    
    private let cacheStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "0%"
        label.font = .monospacedSystemFont(ofSize: 14, weight: .bold)
        label.textColor = .systemOrange
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Advanced"
        view.backgroundColor = .systemBackground
        
        setupActions()
        startMonitoring()
        updateEnvironmentLabel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        FrameRateMonitor.shared.stop()
    }
    
    override func setLayout() {
        layoutContainer.setBody {
            self.body
        }
    }
    
    // MARK: - Layout Body
    
    @LayoutBuilder
    var body: some Layout {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                // Header
                headerSection
                
                // Sections
                animationSection
                environmentSection
                performanceSection
                prioritySection
                geometryInfoSection
                
                Spacer(minLength: 40)
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some Layout {
        createLabel(
            text: "Advanced Features",
            font: .systemFont(ofSize: 26, weight: .bold),
            color: .label
        )
        .layout()
        .size(width: 320, height: 36)
        .offset(y: 16)
    }
    
    // MARK: - Animation Section
    
    private var animationSection: some Layout {
        VStack(alignment: .center, spacing: 12) {
            sectionHeader(title: "Animation Engine", subtitle: "Spring animation with Layout library")
            
            VStack(alignment: .center, spacing: 16) {
                animationDemoView.layout()
                    .size(width: 50, height: 50)
                    .offset(x: animatedOffset)
                
                animateButton.layout()
                    .size(width: 140, height: 44)
            }
            .padding(20)
            .layout()
            .size(width: 360, height: 140)
            .background(.tertiarySystemBackground)
            .cornerRadius(16)
        }
        .padding(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    }
    
    // MARK: - Environment Section
    
    private var environmentSection: some Layout {
        VStack(alignment: .center, spacing: 12) {
            sectionHeader(title: "Environment System", subtitle: "Color scheme & layout direction")
            
            VStack(alignment: .center, spacing: 12) {
                environmentLabel.layout()
                    .size(width: 300, height: 24)
                
                HStack(alignment: .center, spacing: 16) {
                    environmentInfoItem(
                        icon: "🌓",
                        title: "Color Scheme",
                        value: ColorScheme.current == .dark ? "Dark" : "Light"
                    )
                    
                    environmentInfoItem(
                        icon: "↔️",
                        title: "Direction",
                        value: LayoutDirection.current == .rightToLeft ? "RTL" : "LTR"
                    )
                }
            }
            .padding(16)
            .layout()
            .size(width: 360, height: 130)
            .background(.tertiarySystemBackground)
            .cornerRadius(16)
        }
        .padding(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    }
    
    // MARK: - Performance Section
    
    private var performanceSection: some Layout {
        VStack(alignment: .center, spacing: 12) {
            sectionHeader(title: "Performance Monitor", subtitle: "Real-time FPS & cache metrics")
            
            HStack(alignment: .center, spacing: 12) {
                performanceStatCard(
                    icon: "⚡️",
                    label: performanceLabel,
                    title: "FPS"
                )
                
                performanceStatCard(
                    icon: "💾",
                    label: cacheStatusLabel,
                    title: "Cache Hit"
                )
                
                staticStatCard(
                    icon: "📊",
                    value: "\(PerformanceProfiler.shared.allProfiles.count)",
                    title: "Profiles"
                )
            }
            .padding(12)
            .layout()
            .size(width: 360, height: 105)
            .background(.tertiarySystemBackground)
            .cornerRadius(16)
        }
        .padding(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    }
    
    // MARK: - Priority Section
    
    private var prioritySection: some Layout {
        VStack(alignment: .center, spacing: 12) {
            sectionHeader(title: "Priority System", subtitle: "Layout priority distribution")
            
            HStack(alignment: .center, spacing: 10) {
                priorityCard(label: "High\nPriority", color: .systemRed, width: 105)
                priorityCard(label: "Medium", color: .systemOrange, width: 105)
                priorityCard(label: "Low", color: .systemGreen, width: 105)
            }
            .padding(12)
            .layout()
            .size(width: 360, height: 95)
            .background(.tertiarySystemBackground)
            .cornerRadius(16)
        }
        .padding(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    }
    
    // MARK: - Geometry Info Section
    
    private var geometryInfoSection: some Layout {
        VStack(alignment: .center, spacing: 12) {
            sectionHeader(title: "Geometry & Preferences", subtitle: "Access container geometry")
            
            VStack(alignment: .leading, spacing: 8) {
                geometryInfoRow(icon: "📐", text: "Container size access")
                geometryInfoRow(icon: "🛡️", text: "Safe area insets")
                geometryInfoRow(icon: "🌍", text: "Global frame position")
                geometryInfoRow(icon: "🔄", text: "Coordinate space conversion")
            }
            .padding(16)
            .layout()
            .size(width: 360, height: 160)
            .background(.tertiarySystemBackground)
            .cornerRadius(16)
        }
        .padding(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
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
    
    // MARK: - Helper: Environment Info Item
    
    private func environmentInfoItem(icon: String, title: String, value: String) -> some Layout {
        VStack(alignment: .center, spacing: 4) {
            createLabel(text: icon, font: .systemFont(ofSize: 24), color: .label)
                .layout().size(width: 150, height: 28)
            
            createLabel(text: title, font: .systemFont(ofSize: 11, weight: .medium), color: .secondaryLabel)
                .layout().size(width: 150, height: 14)
            
            createLabel(text: value, font: .systemFont(ofSize: 14, weight: .bold), color: .systemIndigo)
                .layout().size(width: 150, height: 18)
        }
        .layout()
        .size(width: 150, height: 70)
    }
    
    // MARK: - Helper: Performance Stat Card
    
    private func performanceStatCard(icon: String, label: UILabel, title: String) -> some Layout {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 80))
        container.backgroundColor = .clear
        
        let iconLabel = UILabel(frame: CGRect(x: 0, y: 8, width: 100, height: 24))
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 20)
        iconLabel.textAlignment = .center
        container.addSubview(iconLabel)
        
        label.frame = CGRect(x: 0, y: 36, width: 100, height: 22)
        label.textAlignment = .center
        container.addSubview(label)
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 60, width: 100, height: 14))
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 10, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        container.addSubview(titleLabel)
        
        return container.layout().size(width: 100, height: 80)
    }
    
    private func staticStatCard(icon: String, value: String, title: String) -> some Layout {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 80))
        container.backgroundColor = .clear
        
        let iconLabel = UILabel(frame: CGRect(x: 0, y: 8, width: 100, height: 24))
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 20)
        iconLabel.textAlignment = .center
        container.addSubview(iconLabel)
        
        let valueLabel = UILabel(frame: CGRect(x: 0, y: 36, width: 100, height: 22))
        valueLabel.text = value
        valueLabel.font = .monospacedSystemFont(ofSize: 14, weight: .bold)
        valueLabel.textColor = .systemIndigo
        valueLabel.textAlignment = .center
        container.addSubview(valueLabel)
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 60, width: 100, height: 14))
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 10, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        container.addSubview(titleLabel)
        
        return container.layout().size(width: 100, height: 80)
    }
    
    // MARK: - Helper: Priority Card
    
    private func priorityCard(label: String, color: UIColor, width: CGFloat) -> some Layout {
        let height: CGFloat = 70
        let container = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        container.backgroundColor = color.withAlphaComponent(0.2)
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 2
        container.layer.borderColor = color.cgColor
        
        let textLabel = UILabel(frame: CGRect(x: 4, y: 4, width: width - 8, height: height - 8))
        textLabel.text = label
        textLabel.font = .systemFont(ofSize: 13, weight: .bold)
        textLabel.textColor = color
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 2
        textLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.addSubview(textLabel)
        
        return container.layout().size(width: width, height: height)
    }
    
    // MARK: - Helper: Geometry Info Row
    
    private func geometryInfoRow(icon: String, text: String) -> some Layout {
        HStack(alignment: .center, spacing: 12) {
            createLabel(text: icon, font: .systemFont(ofSize: 16), color: .label)
                .layout().size(width: 24, height: 24)
            
            createLabel(text: text, font: .systemFont(ofSize: 13, weight: .medium), color: .secondaryLabel)
                .layout().size(width: 280, height: 20)
        }
        .layout()
        .size(width: 320, height: 28)
    }
    
    // MARK: - Actions & Updates
    
    private func setupActions() {
        animateButton.addTarget(self, action: #selector(animateButtonTapped), for: .touchUpInside)
    }
    
    @objc private func animateButtonTapped() {
        guard !isAnimating else { return }
        isAnimating = true
        
        LayoutAnimationEngine.shared.animateSpring(
            damping: 0.6,
            initialVelocity: 0.5,
            duration: 0.6,
            animations: { [weak self] in
                guard let self = self else { return }
                let newOffset: CGFloat = self.animatedOffset == 0 ? 100 : 0
                self.animatedOffset = newOffset
                self.animationDemoView.transform = CGAffineTransform(translationX: newOffset, y: 0)
            },
            completion: { [weak self] in
                self?.isAnimating = false
            }
        )
    }
    
    private func startMonitoring() {
        FrameRateMonitor.shared.start()
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateMonitoringLabels()
        }
    }
    
    private func updateMonitoringLabels() {
        let fps = FrameRateMonitor.shared.averageFPS
        performanceLabel.text = String(format: "%.0f FPS", fps)
        performanceLabel.textColor = fps >= 55 ? .systemGreen : (fps >= 30 ? .systemOrange : .systemRed)
        
        let hitRate = LayoutCache.shared.hitRate * 100
        cacheStatusLabel.text = String(format: "%.0f%%", hitRate)
    }
    
    private func updateEnvironmentLabel() {
        let colorScheme = ColorScheme.current
        environmentLabel.text = "Environment: \(colorScheme == .dark ? "Dark" : "Light") Mode"
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateEnvironmentLabel()
        EnvironmentProvider.shared.updateSystemEnvironment()
    }
}
