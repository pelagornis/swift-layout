import UIKit
import Layout

/// Demonstrates the advanced features of the Layout library
final class AdvancedFeaturesViewController: BaseViewController, Layout {
    
    // MARK: - Properties
    
    private var isAnimating = false
    private var animatedOffset: CGFloat = 0
    
    // Layout Tree Test Properties
    private enum LayoutTreeConstants {
        static let cardCount = 6
        static let cardWidth: CGFloat = 165
        static let cardHeight: CGFloat = 140
        static let cardPadding: CGFloat = 12
        static let cardSpacing: CGFloat = 12
        static let cardLabelYOffset: CGFloat = 20
        
        static let colors: [UIColor] = [
            .systemRed, .systemBlue, .systemGreen,
            .systemOrange, .systemPurple, .systemTeal
        ]
    }
    
    private var cardCounts = Array(repeating: 0, count: LayoutTreeConstants.cardCount)
    private var recalculationCount = 0
    
    // Layout Tree Test UI Components
    private let statsLabel: UILabel = {
        let label = UILabel()
        label.text = "재계산 통계: 0개 노드"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemBlue
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "상태: 대기 중"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let statsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .tertiarySystemFill
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let cards: [UIView] = {
        return LayoutTreeConstants.colors.map { color in
            let view = UIView()
            view.backgroundColor = color.withAlphaComponent(0.15)
            view.layer.cornerRadius = 12
            view.layer.borderWidth = 2
            view.layer.borderColor = color.cgColor
            return view
        }
    }()
    
    private let cardLabels: [UILabel] = {
        return LayoutTreeConstants.colors.enumerated().map { index, color in
            let label = UILabel()
            label.text = "Card \(index + 1)"
            label.font = .systemFont(ofSize: 18, weight: .semibold)
            label.textColor = color
            label.textAlignment = .center
            return label
        }
    }()
    
    private let cardCounterLabels: [UILabel] = {
        return LayoutTreeConstants.colors.map { color in
            let label = UILabel()
            label.text = "Count: 0"
            label.font = .systemFont(ofSize: 14, weight: .regular)
            label.textColor = color
            label.textAlignment = .center
            return label
        }
    }()
    
    private let cardTimeLabels: [UILabel] = {
        return (0..<LayoutTreeConstants.cardCount).map { _ in
            let label = UILabel()
            label.text = "Time: -"
            label.font = .systemFont(ofSize: 10, weight: .regular)
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            return label
        }
    }()    
    
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
        
        layoutContainer.useIncrementalLayout = true
        setupActions()
        setupLayoutTreeTest()
        startMonitoring()
        updateEnvironmentLabel()
    }
    
    private func setupLayoutTreeTest() {
        for (index, card) in cards.enumerated() {
            card.addSubview(cardLabels[index])
            card.addSubview(cardCounterLabels[index])
            card.addSubview(cardTimeLabels[index])
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutCardLabels()
    }
    
    private func layoutCardLabels() {
        let padding = LayoutTreeConstants.cardPadding
        let yOffset = LayoutTreeConstants.cardLabelYOffset
        
        for index in 0..<LayoutTreeConstants.cardCount {
            let width = LayoutTreeConstants.cardWidth - padding * 2
            cardLabels[index].frame = CGRect(x: padding, y: yOffset, width: width, height: 24)
            cardCounterLabels[index].frame = CGRect(x: padding, y: yOffset + 30, width: width, height: 20)
            cardTimeLabels[index].frame = CGRect(x: padding, y: yOffset + 55, width: width, height: 16)
        }
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
                layoutTreeSection
                
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
    
    // MARK: - Layout Tree Test Section
    
    private var layoutTreeSection: some Layout {
        VStack(alignment: .center, spacing: 12) {
            sectionHeader(title: "Layout Tree & Dirty Propagation", subtitle: "Incremental layout updates")
            
            // 통계 및 상태 표시
            ZStack(alignment: .center) {
                statsContainer.layout()
                    .size(width: 360, height: 86)
                
                VStack(alignment: .center, spacing: 8) {
                    statsLabel.layout()
                        .size(width: 340, height: 30)
                    
                    statusLabel.layout()
                        .size(width: 340, height: 40)
                }
            }
            
            // 카드 그리드 (2열 3행)
            VStack(alignment: .center, spacing: LayoutTreeConstants.cardSpacing) {
                // 첫 번째 행: Card 1, Card 4
                HStack(alignment: .center, spacing: LayoutTreeConstants.cardSpacing) {
                    cards[0].layout()
                        .size(width: LayoutTreeConstants.cardWidth, height: LayoutTreeConstants.cardHeight)
                    
                    cards[3].layout()
                        .size(width: LayoutTreeConstants.cardWidth, height: LayoutTreeConstants.cardHeight)
                }
                
                // 두 번째 행: Card 2, Card 5
                HStack(alignment: .center, spacing: LayoutTreeConstants.cardSpacing) {
                    cards[1].layout()
                        .size(width: LayoutTreeConstants.cardWidth, height: LayoutTreeConstants.cardHeight)
                    
                    cards[4].layout()
                        .size(width: LayoutTreeConstants.cardWidth, height: LayoutTreeConstants.cardHeight)
                }
                
                // 세 번째 행: Card 3, Card 6
                HStack(alignment: .center, spacing: LayoutTreeConstants.cardSpacing) {
                    cards[2].layout()
                        .size(width: LayoutTreeConstants.cardWidth, height: LayoutTreeConstants.cardHeight)
                    
                    cards[5].layout()
                        .size(width: LayoutTreeConstants.cardWidth, height: LayoutTreeConstants.cardHeight)
                }
            }
            
            // 버튼 섹션
            VStack(alignment: .center, spacing: 10) {
                // 개별 카드 버튼들
                HStack(alignment: .center, spacing: 10) {
                    createLayoutTreeButton(title: "Card 1", color: .systemRed, fontSize: 14) { [weak self] in
                        self?.updateLayoutTreeCard(at: 0)
                    }
                    .layout()
                    .size(width: 100, height: 36)
                    
                    createLayoutTreeButton(title: "Card 2", color: .systemBlue, fontSize: 14) { [weak self] in
                        self?.updateLayoutTreeCard(at: 1)
                    }
                    .layout()
                    .size(width: 100, height: 36)
                    
                    createLayoutTreeButton(title: "Card 3", color: .systemGreen, fontSize: 14) { [weak self] in
                        self?.updateLayoutTreeCard(at: 2)
                    }
                    .layout()
                    .size(width: 100, height: 36)
                }
                
                HStack(alignment: .center, spacing: 10) {
                    createLayoutTreeButton(title: "Card 4", color: .systemOrange, fontSize: 14) { [weak self] in
                        self?.updateLayoutTreeCard(at: 3)
                    }
                    .layout()
                    .size(width: 100, height: 36)
                    
                    createLayoutTreeButton(title: "Card 5", color: .systemPurple, fontSize: 14) { [weak self] in
                        self?.updateLayoutTreeCard(at: 4)
                    }
                    .layout()
                    .size(width: 100, height: 36)
                    
                    createLayoutTreeButton(title: "Card 6", color: .systemTeal, fontSize: 14) { [weak self] in
                        self?.updateLayoutTreeCard(at: 5)
                    }
                    .layout()
                    .size(width: 100, height: 36)
                }
                
                // 그룹 업데이트 버튼들
                createLayoutTreeButton(title: "Update Cards 1-3", color: .systemIndigo) { [weak self] in
                    self?.updateLayoutTreeCards(range: 0..<3)
                }
                .layout()
                .size(width: 340, height: 44)
                
                createLayoutTreeButton(title: "Update Cards 4-6", color: .systemPink) { [weak self] in
                    self?.updateLayoutTreeCards(range: 3..<6)
                }
                .layout()
                .size(width: 340, height: 44)
                
                createLayoutTreeButton(title: "Update All Cards", color: .systemPurple) { [weak self] in
                    self?.updateAllLayoutTreeCards()
                }
                .layout()
                .size(width: 340, height: 44)
                
                createLayoutTreeButton(title: "Toggle Incremental Layout", color: .systemOrange) { [weak self] in
                    self?.toggleIncrementalLayout()
                }
                .layout()
                .size(width: 340, height: 44)
            }
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
    
    // MARK: - Layout Tree Test Helpers
    
    private func createLayoutTreeButton(title: String, color: UIColor, fontSize: CGFloat = 16, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: fontSize, weight: .semibold)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return button
    }
    
    private func highlightLayoutTreeCard(_ index: Int, duration: TimeInterval = 0.3) {
        guard index >= 0 && index < LayoutTreeConstants.cardCount else { return }
        
        let card = cards[index]
        let originalColor = card.backgroundColor
        
        UIView.animate(withDuration: duration / 2, animations: {
            card.backgroundColor = card.layer.borderColor?.uiColor.withAlphaComponent(0.4)
            card.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { _ in
            UIView.animate(withDuration: duration / 2) {
                card.backgroundColor = originalColor
                card.transform = .identity
            }
        }
    }
    
    // MARK: - Layout Tree Test Actions
    
    private func updateLayoutTreeCard(at index: Int) {
        guard index >= 0 && index < LayoutTreeConstants.cardCount else { return }
        
        cardCounts[index] += 1
        cardCounterLabels[index].text = "Count: \(cardCounts[index])"
        
        let startTime = CFAbsoluteTimeGetCurrent()
        layoutContainer.markViewDirty(cardCounterLabels[index])
        let endTime = CFAbsoluteTimeGetCurrent()
        
        let elapsedTime = (endTime - startTime) * 1000
        cardTimeLabels[index].text = String(format: "Time: %.2fms", elapsedTime)
        
        recalculationCount = 1
        updateLayoutTreeStats()
        updateLayoutTreeStatus("Card \(index + 1) 업데이트 (부분 재계산)\n소요 시간: \(String(format: "%.2f", elapsedTime))ms")
        highlightLayoutTreeCard(index)
        layoutContainer.markViewDirty(cardTimeLabels[index])
    }
    
    private func updateLayoutTreeCards(range: Range<Int>) {
        let indices = Array(range)
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for index in indices {
            cardCounts[index] += 1
            cardCounterLabels[index].text = "Count: \(cardCounts[index])"
            layoutContainer.markViewDirty(cardCounterLabels[index])
            highlightLayoutTreeCard(index, duration: 0.2)
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let elapsedTime = (endTime - startTime) * 1000
        
        for index in indices {
            cardTimeLabels[index].text = String(format: "Time: %.2fms", elapsedTime / Double(indices.count))
        }
        
        recalculationCount = indices.count
        updateLayoutTreeStats()
        updateLayoutTreeStatus("Cards \(indices.first! + 1)-\(indices.last! + 1) 업데이트\n\(indices.count)개 노드 재계산, 소요 시간: \(String(format: "%.2f", elapsedTime))ms")
    }
    
    private func updateAllLayoutTreeCards() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for index in 0..<LayoutTreeConstants.cardCount {
            cardCounts[index] += 1
            cardCounterLabels[index].text = "Count: \(cardCounts[index])"
        }
        
        layoutContainer.invalidateLayoutTree()
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let elapsedTime = (endTime - startTime) * 1000
        
        for index in 0..<LayoutTreeConstants.cardCount {
            cardTimeLabels[index].text = String(format: "Time: %.2fms", elapsedTime / Double(LayoutTreeConstants.cardCount))
            highlightLayoutTreeCard(index, duration: 0.15)
        }
        
        recalculationCount = LayoutTreeConstants.cardCount
        updateLayoutTreeStats()
        updateLayoutTreeStatus("모든 카드 업데이트 (전체 재계산)\n\(LayoutTreeConstants.cardCount)개 노드 재계산, 소요 시간: \(String(format: "%.2f", elapsedTime))ms")
    }
    
    private func toggleIncrementalLayout() {
        let wasEnabled = layoutContainer.useIncrementalLayout
        layoutContainer.useIncrementalLayout = !layoutContainer.useIncrementalLayout
        let isNowEnabled = layoutContainer.useIncrementalLayout
        
        let status = isNowEnabled ? "활성화" : "비활성화"
        let color = isNowEnabled ? "🟢" : "🔴"
        
        // Rebuild layout tree without touching view hierarchy
        layoutContainer.rebuildLayoutTree()
        
        // Schedule layout update for next run loop
        layoutContainer.setNeedsLayout()
        
        if wasEnabled != isNowEnabled {
            let testStartTime = CFAbsoluteTimeGetCurrent()
            cardCounts[0] += 1
            cardCounterLabels[0].text = "Count: \(cardCounts[0])"
            
            if isNowEnabled {
                layoutContainer.markViewDirty(cardCounterLabels[0])
            } else {
                layoutContainer.setNeedsLayout()
            }
            
            let testEndTime = CFAbsoluteTimeGetCurrent()
            let testTime = (testEndTime - testStartTime) * 1000
            
            updateLayoutTreeStatus("\(color) Incremental Layout: \(status)\n테스트 업데이트: \(String(format: "%.2f", testTime))ms")
        } else {
            updateLayoutTreeStatus("\(color) Incremental Layout: \(status)\n레이아웃 트리 재구축됨")
        }
        
        updateLayoutTreeStats()
    }
    
    private func updateLayoutTreeStats() {
        statsLabel.text = "재계산 통계: \(recalculationCount)개 노드 재계산됨"
        layoutContainer.markViewDirty(statsLabel)
    }
    
    private func updateLayoutTreeStatus(_ text: String) {
        statusLabel.text = text
        layoutContainer.markViewDirty(statusLabel)
    }
}

// MARK: - Helper Extension

extension CGColor {
    var uiColor: UIColor {
        return UIColor(cgColor: self)
    }
}
