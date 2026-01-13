import UIKit
import Layout

/// Demonstrates the advanced features of the Layout library
final class AdvancedFeaturesViewController: BaseViewController, Layout {
    
    // MARK: - Properties
    
    private var isAnimating = false
    private var animatedOffset: CGFloat = 0
    private var animationDemoViewOriginalX: CGFloat? // Store original x position
    
    // Layout Tree Test Properties
    private enum LayoutTreeConstants {
        static let cardCount = 6
        static let cardPadding: CGFloat = 12
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
    
    // MARK: - UI Components
    
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
        
        // Enable layout debugging
        enableLayoutDebugging = true
        
        layoutContainer.useIncrementalLayout = true
        setupActions()
        setupLayoutTreeTest()
        setupIdentityDiffTest()
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
    
    private func setupIdentityDiffTest() {
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutCardLabels()
    }
    
    private func layoutCardLabels() {
        let padding = LayoutTreeConstants.cardPadding
        let yOffset = LayoutTreeConstants.cardLabelYOffset
        
        for index in 0..<LayoutTreeConstants.cardCount {
            // Use actual card bounds instead of fixed cardWidth
            let card = cards[index]
            let cardWidth = card.bounds.width > 0 ? card.bounds.width : (view.bounds.width * 0.9 / 2 - 12 / 2)
            let width = max(0, cardWidth - padding * 2)
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
        layoutContainer.updateBody {
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
                identityDiffSection
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
        .size(width: 90%, height: 36)
        .offset(y: 16)
    }
    
    // MARK: - Animation Section
    
    private var animationSection: some Layout {
        VStack(alignment: .center, spacing: 12) {
            sectionHeader(title: "Animation Engine", subtitle: "Spring animation with Layout library")
            
            VStack(alignment: .center, spacing: 16) {
                // Don't use offset modifier - we'll animate frame directly
                animationDemoView.layout()
                    .size(width: 50, height: 50)
                
                animateButton.layout()
                    .size(width: 140, height: 44)
            }
            .padding(20)
            .layout()
            .size(width: 90%, height: 140)
            .background(.tertiarySystemBackground)
            .cornerRadius(16)
        }
    }
    
    // MARK: - Environment Section
    
    private var environmentSection: some Layout {
        VStack(alignment: .center, spacing: 12) {
            sectionHeader(title: "Environment System", subtitle: "Color scheme & layout direction")
            
            VStack(alignment: .center, spacing: 12) {
                environmentLabel.layout()
                    .size(width: 90%, height: 24)
                
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
            .size(width: 90%, height: 130)
            .background(.tertiarySystemBackground)
            .cornerRadius(16)
        }
    }
    
    // MARK: - Performance Section
    
    private var performanceSection: some Layout {
        VStack(alignment: .center, spacing: 12) {
            sectionHeader(title: "Performance Monitor", subtitle: "Real-time FPS & cache metrics")
            
            HStack(alignment: .center, spacing: 8) {
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
            .size(width: 90%, height: 105)
            .background(.tertiarySystemBackground)
            .cornerRadius(16)
            .centerX()
        }
    }
    
    // MARK: - Priority Section
    
    private var prioritySection: some Layout {
        VStack(alignment: .center, spacing: 12) {
            sectionHeader(title: "Priority System", subtitle: "Layout priority distribution")
            
            HStack(alignment: .center, spacing: 8) {
                priorityCard(label: "High\nPriority", color: .systemRed, width: 33%)
                priorityCard(label: "Medium", color: .systemOrange, width: 33%)
                priorityCard(label: "Low", color: .systemGreen, width: 33%)
            }
            .padding(12)
            .layout()
            .size(width: 90%, height: 95)
            .background(.tertiarySystemBackground)
            .cornerRadius(16)
            .centerX()
        }
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
            .size(width: 90%, height: 160)
            .background(.tertiarySystemBackground)
            .cornerRadius(16)
        }
    }
    
    // MARK: - Layout Tree Test Section
    
    private var layoutTreeSection: some Layout {
        VStack(alignment: .center, spacing: 12) {
            sectionHeader(title: "Layout Tree & Dirty Propagation", subtitle: "Incremental layout updates")
            
            ZStack(alignment: .center) {
                statsContainer.layout()
                    .size(width: 90%, height: 86)
                
                VStack(alignment: .center, spacing: 8) {
                    statsLabel.layout()
                        .size(width: 90%, height: 30)
                    
                    statusLabel.layout()
                        .size(width: 90%, height: 40)
                }
            }
            
            VStack(alignment: .center, spacing: 12) {
                HStack(alignment: .center, spacing: 12) {
                    cards[0].layout()
                        .size(width: 150, height: 140)
                    
                    cards[3].layout()
                        .size(width: 150, height: 140)
                }
                
                HStack(alignment: .center, spacing: 12) {
                    cards[1].layout()
                        .size(width: 150, height: 140)
                    
                    cards[4].layout()
                        .size(width: 150, height: 140)
                }
                
                HStack(alignment: .center, spacing: 12) {
                    cards[2].layout()
                        .size(width: 150, height: 140)
                    
                    cards[5].layout()
                        .size(width: 150, height: 140)
                }
            }
            VStack(alignment: .center, spacing: 10) {
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
                
                createLayoutTreeButton(title: "Update Cards 1-3", color: .systemIndigo) { [weak self] in
                    self?.updateLayoutTreeCards(range: 0..<3)
                }
                .layout()
                .size(width: 90%, height: 44)
                
                createLayoutTreeButton(title: "Update Cards 4-6", color: .systemPink) { [weak self] in
                    self?.updateLayoutTreeCards(range: 3..<6)
                }
                .layout()
                .size(width: 90%, height: 44)
                
                createLayoutTreeButton(title: "Update All Cards", color: .systemPurple) { [weak self] in
                    self?.updateAllLayoutTreeCards()
                }
                .layout()
                .size(width: 90%, height: 44)
                
                createLayoutTreeButton(title: "Toggle Incremental Layout", color: .systemOrange) { [weak self] in
                    self?.toggleIncrementalLayout()
                }
                .layout()
                .size(width: 90%, height: 44)
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
            ).layout().size(width: 90%, height: 20)
            
            createLabel(
                text: subtitle,
                font: .systemFont(ofSize: 11, weight: .regular),
                color: .secondaryLabel
            ).layout().size(width: 90%, height: 14)
        }
        .padding(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
        .layout()
        .size(width: 90%, height: 50)
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
                .layout().size(width: 100%, height: 28)
            
            createLabel(text: title, font: .systemFont(ofSize: 11, weight: .medium), color: .secondaryLabel)
                .layout().size(width: 100%, height: 14)
            
            createLabel(text: value, font: .systemFont(ofSize: 14, weight: .bold), color: .systemIndigo)
                .layout().size(width: 100%, height: 18)
        }
        .layout()
        .size(width: 50%, height: 70)
    }
    
    // MARK: - Helper: Performance Stat Card
    
    private func performanceStatCard(icon: String, label: UILabel, title: String) -> some Layout {
        // Ensure label properties are set correctly
        label.textAlignment = .left
        label.numberOfLines = 1
        
        return VStack(alignment: .center, spacing: 4) {
            createLabel(text: icon, font: .systemFont(ofSize: 20), color: .label)
                .layout()
                .size(width: 100%, height: 24)
            
            label
                .layout()
                .size(width: 100%, height: 22)
            
            createLabel(text: title, font: .systemFont(ofSize: 10, weight: .medium), color: .secondaryLabel)
                .layout()
                .size(width: 100%, height: 14)
        }
        .layout()
        .size(width: 30%, height: 80)
    }
    
    private func staticStatCard(icon: String, value: String, title: String) -> some Layout {
        VStack(alignment: .center, spacing: 4) {
            createLabel(text: icon, font: .systemFont(ofSize: 20), color: .label)
                .layout()
                .size(width: 100%, height: 24)
            
            createLabel(text: value, font: .monospacedSystemFont(ofSize: 14, weight: .bold), color: .systemIndigo)
                .layout()
                .size(width: 100%, height: 22)
            
            createLabel(text: title, font: .systemFont(ofSize: 10, weight: .medium), color: .secondaryLabel)
                .layout()
                .size(width: 100%, height: 14)
        }
        .layout()
        .size(width: 30%, height: 80)
    }
    
    // MARK: - Helper: Priority Card
    
    private func priorityCard(label: String, color: UIColor, width: Percent) -> some Layout {
        let textLabel = createLabel(text: label, font: .systemFont(ofSize: 13, weight: .bold), color: color)
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 2
        
        let vStack = VStack(alignment: .center, spacing: 0) {
            textLabel.layout()
                .size(width: 100%, height: 100%)
        }
        .padding(4)
        
        // Apply styling to VStack
        vStack.backgroundColor = color.withAlphaComponent(0.2)
        vStack.layer.cornerRadius = 12
        vStack.layer.borderWidth = 2
        vStack.layer.borderColor = color.cgColor
        vStack.layer.masksToBounds = true
        
        return vStack.layout()
            .size(width: width, height: 70)
    }
    
    // MARK: - Helper: Geometry Info Row
    
    private func geometryInfoRow(icon: String, text: String) -> some Layout {
        HStack(alignment: .center, spacing: 12) {
            createLabel(text: icon, font: .systemFont(ofSize: 16), color: .label)
                .layout().size(width: 24, height: 24)
            
            createLabel(text: text, font: .systemFont(ofSize: 13, weight: .medium), color: .secondaryLabel)
                .layout().size(width: 90%, height: 20)
        }
        .layout()
        .size(width: 90%, height: 28)
    }
    
    // MARK: - Actions & Updates
    
    private func setupActions() {
        animateButton.addTarget(self, action: #selector(animateButtonTapped), for: .touchUpInside)
    }
    
    @objc private func animateButtonTapped() {
        guard !isAnimating else { return }
        isAnimating = true
        
        // Save current frame before any changes
        let currentFrame = animationDemoView.frame
        
        // Store original x position on first use
        if animationDemoViewOriginalX == nil {
            animationDemoViewOriginalX = currentFrame.origin.x
        }
        
        // Toggle offset: 0 -> 100, 100 -> 0
        animatedOffset = animatedOffset == 0 ? 100 : 0
        
        // Mark animationDemoView as animating to prevent layout from overriding
        layoutContainer.startAnimating(animationDemoView)
        
        // Update layout first (other views will update immediately, animationDemoView is skipped)
        layoutContainer.updateBody { self.body }
        
        // Ensure animationDemoView starts from current position
        animationDemoView.frame = currentFrame
        
        // Calculate target frame: original position + offset
        guard let originalX = animationDemoViewOriginalX else {
            isAnimating = false
            return
        }
        let targetFrame = CGRect(
            x: originalX + animatedOffset,
            y: currentFrame.origin.y,
            width: currentFrame.width,
            height: currentFrame.height
        )
        
        // Animate only the animationDemoView using spring animation
        withAnimation(.spring(damping: 0.6, velocity: 0.5), {
            self.animationDemoView.frame = targetFrame
        }, completion: { _ in
            // Stop animating after animation completes
            self.layoutContainer.stopAnimating(self.animationDemoView)
            self.isAnimating = false
        })
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
        
        // Handle screen rotation - update original position after layout completes
        if previousTraitCollection != nil {
            // Wait for layout to complete, then update position
            DispatchQueue.main.async { [weak self] in
                self?.updateAnimationViewPositionAfterRotation()
            }
        }
    }
    
    private func updateAnimationViewPositionAfterRotation() {
        // Update original position after layout to handle screen rotation
        // This ensures the view stays centered when screen rotates
        if animatedOffset != 0, animationDemoViewOriginalX != nil {
            // Protect the view during position update
            layoutContainer.startAnimating(animationDemoView)
            
            // Recalculate original position based on current layout position and offset
            // After layout, the view should be at its centered position
            let currentX = animationDemoView.frame.origin.x
            let newOriginalX = currentX - animatedOffset
            animationDemoViewOriginalX = newOriginalX
            
            // Update frame to maintain offset from new original position
            let currentFrame = animationDemoView.frame
            animationDemoView.frame = CGRect(
                x: newOriginalX + animatedOffset,
                y: currentFrame.origin.y,
                width: currentFrame.width,
                height: currentFrame.height
            )
            
            layoutContainer.stopAnimating(animationDemoView)
        } else if animatedOffset == 0 {
            // If offset is 0, update original position to current position
            // This ensures next animation starts from the correct center position
            animationDemoViewOriginalX = animationDemoView.frame.origin.x
        }
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
    
    // MARK: - Identity & Diff Test Properties
    
    private struct IdentityItem: Hashable {
        let id: String
        let title: String
        let colorName: String
        var count: Int = 0
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: IdentityItem, rhs: IdentityItem) -> Bool {
            lhs.id == rhs.id
        }
        
        var color: UIColor {
            switch colorName {
            case "red": return .systemRed
            case "blue": return .systemBlue
            case "green": return .systemGreen
            case "orange": return .systemOrange
            case "purple": return .systemPurple
            case "teal": return .systemTeal
            case "pink": return .systemPink
            case "indigo": return .systemIndigo
            default: return .systemGray
            }
        }
    }
    
    private var identityItems: [IdentityItem] = [
        IdentityItem(id: "item-1", title: "Item 1", colorName: "red"),
        IdentityItem(id: "item-2", title: "Item 2", colorName: "blue"),
        IdentityItem(id: "item-3", title: "Item 3", colorName: "green"),
        IdentityItem(id: "item-4", title: "Item 4", colorName: "orange"),
        IdentityItem(id: "item-5", title: "Item 5", colorName: "purple")
    ]
    
    private var identityItemViews: [String: UIView] = [:]
    private var identityItemLabels: [String: UILabel] = [:]
    
    // MARK: - Identity & Diff Test Section
    
    private var identityDiffSection: some Layout {
        VStack(alignment: .center, spacing: 12) {
            sectionHeader(title: "Identity & Diff", subtitle: "Efficient view updates with identity tracking")
            
            let descriptionLabel = createLabel(
                text: "Identity를 사용하여 뷰를 추적합니다.\n같은 Identity는 재사용되고, 새로운 Identity는 추가됩니다.",
                font: .systemFont(ofSize: 12, weight: .regular),
                color: .secondaryLabel
            )
            descriptionLabel.layout()
                .size(width: 90%, height: 50)
            
            VStack(alignment: .center, spacing: 8) {
                ForEach(identityItems) { item in
                    self.createIdentityItemLayout(for: item)
                }
            }
            
            VStack(alignment: .center, spacing: 10) {
                createLayoutTreeButton(title: "Add Item", color: .systemGreen) { [weak self] in
                    self?.addIdentityItem()
                }
                .layout()
                .size(width: 90%, height: 44)
                
                createLayoutTreeButton(title: "Remove Last", color: .systemRed) { [weak self] in
                    self?.removeLastIdentityItem()
                }
                .layout()
                .size(width: 90%, height: 44)
                
                createLayoutTreeButton(title: "Shuffle Items", color: .systemBlue) { [weak self] in
                    self?.shuffleIdentityItems()
                }
                .layout()
                .size(width: 90%, height: 44)
                
                createLayoutTreeButton(title: "Update All Counts", color: .systemPurple) { [weak self] in
                    self?.updateAllIdentityItemCounts()
                }
                .layout()
                .size(width: 90%, height: 44)
            }
        }
    }
    
    // MARK: - Identity & Diff Helpers
    
    private func createIdentityItemLayout(for item: IdentityItem) -> some Layout {
        let itemView = getOrCreateItemView(for: item)
        updateItemViewLabel(for: item)
        
        return itemView.layout()
            .id(item.id)
            .size(width: 90%, height: 50)
            .centerX() // Center the item view horizontally
    }
    
    private func getOrCreateItemView(for item: IdentityItem) -> UIView {
        if let existingView = identityItemViews[item.id] {
            return existingView
        }
        let itemView = ResponsiveIdentityItemView(item: item)
        
        identityItemViews[item.id] = itemView
        identityItemLabels[item.id] = itemView.itemLabel
        
        return itemView
    }
    
    // Helper class to handle dynamic label sizing for identity items
    private class ResponsiveIdentityItemView: UIView {
        let itemLabel: UILabel
        
        init(item: IdentityItem) {
            let label = UILabel()
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.textColor = item.color
            label.textAlignment = .center
            label.text = "\(item.title) - Count: \(item.count)"
            self.itemLabel = label
            
            super.init(frame: .zero)
            
            self.backgroundColor = item.color.withAlphaComponent(0.15)
            self.layer.cornerRadius = 8
            self.layer.borderWidth = 1
            self.layer.borderColor = item.color.cgColor
            
            addSubview(label)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            let padding: CGFloat = 10
            let topPadding: CGFloat = 5
            itemLabel.frame = CGRect(
                x: padding,
                y: topPadding,
                width: max(bounds.width - padding * 2, 0),
                height: max(bounds.height - topPadding * 2, 30)
            )
        }
    }
    
    private func updateItemViewLabel(for item: IdentityItem) {
        if let itemLabel = identityItemLabels[item.id] {
            itemLabel.text = "\(item.title) - Count: \(item.count)"
        }
    }
    
    // MARK: - Identity & Diff Actions
    
    private func addIdentityItem() {
        guard identityItems.count < 10 else { return }
        
        let newId = "item-\(identityItems.count + 1)"
        let colorNames = ["red", "blue", "green", "orange", "purple", "teal", "pink", "indigo"]
        let colorName = colorNames[identityItems.count % colorNames.count]
        
        let newItem = IdentityItem(id: newId, title: "Item \(identityItems.count + 1)", colorName: colorName)
        identityItems.append(newItem)
        layoutContainer.updateBody { self.body }
    }
    
    private func removeLastIdentityItem() {
        guard !identityItems.isEmpty else { return }
        let removedItem = identityItems.removeLast()
        
        if let removedView = identityItemViews[removedItem.id] {
            removedView.removeFromSuperview()
            identityItemViews.removeValue(forKey: removedItem.id)
        }
        identityItemLabels.removeValue(forKey: removedItem.id)
        
        layoutContainer.updateBody { self.body }
    }
    
    private func shuffleIdentityItems() {
        identityItems.shuffle()

        layoutContainer.updateBody { self.body }
        layoutContainer.layoutIfNeeded()
    }
    
    private func updateAllIdentityItemCounts() {
        for index in identityItems.indices {
            identityItems[index].count += 1
        }

        layoutContainer.updateBody { self.body }
    }
}

// MARK: - Helper Extension

extension CGColor {
    var uiColor: UIColor {
        return UIColor(cgColor: self)
    }
}
