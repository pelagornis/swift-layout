import UIKit
import Layout

final class HomeViewController: BaseViewController, Layout {
    
    // MARK: - UI Components
    private let profileImageView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemIndigo
        view.layer.cornerRadius = 50
        view.layer.masksToBounds = true
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "@Pelagornis"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "This app is Layout Example"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Get Started", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemIndigo
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.systemIndigo.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .systemBackground
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        
        // Enable layout debugging
        enableLayoutDebugging = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Print performance summary after layout is complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.printLayoutPerformanceSummary()
        }
    }
    
    override func setLayout() {
        layoutContainer.setBodyAndUpdate {
            self.body
        }
    }
    
    // MARK: - Layout
    
    @LayoutBuilder
    var body: some Layout {
        ScrollView {
            VStack(alignment: .center, spacing: 24) {
                profileSection
                statisticsCard
                horizontalScrollSection  // HStack ScrollView 예시
                zStackSection  // ZStack 예시
                featureCardsSection
                benefitsSection
                spacerTestSection  // Spacer 테스트 섹션
                actionButtonView
                Spacer(minLength: 50)
            }
        }
    }
    
    private var profileSection: some Layout {
        VStack(alignment: .center, spacing: 16) {
            profileImageView.layout()
                .size(width: 100, height: 100)
            
            nameLabel.layout()
                .size(width: 320, height: 44)
            
            descriptionLabel.layout()
                .size(width: 300, height: 50)
        }
        .padding(UIEdgeInsets(top: 40, left: 20, bottom: 20, right: 20))
    }
    
    private var statisticsCard: some Layout {
        createStatisticsCard()
            .layout()
            .size(width: 350, height: 100)
    }
    
    private var featureCardsSection: some Layout {
        VStack(alignment: .center, spacing: 16) {
            createSectionTitle(text: "Key Features")
                .layout()
                .size(width: 350, height: 30)
            
            HStack(alignment: .center, spacing: 12) {
                createFeatureCard(icon: "🎨", title: "Design", color: .systemPink)
                    .layout()
                    .size(width: 110, height: 140)
                    .cornerRadius(16)
                
                createFeatureCard(icon: "⚡️", title: "Performance", color: .systemOrange)
                    .layout()
                    .size(width: 110, height: 140)
                    .cornerRadius(16)
                
                createFeatureCard(icon: "🚀", title: "Simplicity", color: .systemBlue)
                    .layout()
                    .size(width: 110, height: 140)
                    .cornerRadius(16)
            }
            .padding(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        }
    }
    
    private var horizontalScrollSection: some Layout {
        VStack(alignment: .center, spacing: 12) {
            createSectionTitle(text: "Horizontal Scroll (HStack)")
                .layout()
                .size(width: 350, height: 30)
            
            // HStack with horizontal scrolling
            ScrollView(.horizontal) {
                HStack(alignment: .center, spacing: 16) {
                    Spacer(minLength: 20)  // Left padding spacer
                    
                    createScrollCard(title: "Card 1", color: .systemRed)
                        .layout()
                        .size(width: 150, height: 100)
                    
                    createScrollCard(title: "Card 2", color: .systemGreen)
                        .layout()
                        .size(width: 150, height: 100)
                    
                    createScrollCard(title: "Card 3", color: .systemBlue)
                        .layout()
                        .size(width: 150, height: 100)
                    
                    createScrollCard(title: "Card 4", color: .systemPurple)
                        .layout()
                        .size(width: 150, height: 100)
                    
                    createScrollCard(title: "Card 5", color: .systemTeal)
                        .layout()
                        .size(width: 150, height: 100)
                    
                    Spacer(minLength: 20)  // Right padding spacer
                }
            }
            .layout()
            .size(width: 390, height: 120)  // Full width for horizontal scroll
        }
    }
    
    private var zStackSection: some Layout {
        VStack(alignment: .center, spacing: 16) {
            createSectionTitle(text: "ZStack Examples")
                .layout()
                .size(width: 350, height: 30)
            
            // Example 1: Card with badge overlay
            ZStack(alignment: .topTrailing) {
                createZStackCard(backgroundColor: .systemIndigo, title: "Card with Badge")
                    .layout()
                    .size(width: 300, height: 120)
                
                createBadgeView(text: "NEW", color: .systemRed)
                    .layout()
                    .size(width: 50, height: 24)
                    .offset(x: -10, y: 10)
            }
            .layout()
            .size(width: 300, height: 120)
            
            // Example 2: Image with text overlay (center)
            ZStack(alignment: .center) {
                createZStackCard(backgroundColor: .systemTeal, title: "")
                    .layout()
                    .size(width: 300, height: 150)
                
                createOverlayText(text: "Overlay Text", color: .white)
                    .layout()
                    .size(width: 200, height: 40)
            }
            .layout()
            .size(width: 300, height: 150)
            
            // Example 3: Multiple layers with different alignments
            ZStack(alignment: .bottomLeading) {
                createZStackCard(backgroundColor: .systemOrange, title: "")
                    .layout()
                    .size(width: 300, height: 100)
                
                createOverlayText(text: "Bottom Left", color: .white)
                    .layout()
                    .size(width: 200, height: 40)
                    .offset(x: 10, y: -10)
            }
            .layout()
            .size(width: 300, height: 100)
        }
        .padding(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    }
    
    private var benefitsSection: some Layout {
        VStack(alignment: .center, spacing: 16) {
            createSectionTitle(text: "Benefits")
                .layout()
                .size(width: 350, height: 30)
            
            VStack(alignment: .leading, spacing: 12) {
                createBenefitRow(icon: "✓", text: "SwiftUI-like declarative syntax")
                    .layout()
                    .size(width: 350, height: 40)
                
                createBenefitRow(icon: "✓", text: "Fast layout performance")
                    .layout()
                    .size(width: 350, height: 40)
                
                createBenefitRow(icon: "✓", text: "Easy customization")
                    .layout()
                    .size(width: 350, height: 40)
            }
        }
        .padding(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    }
    
    private var spacerTestSection: some Layout {
        VStack(alignment: .center, spacing: 12) {
            createSectionTitle(text: "Spacer Test")
                .layout()
                .size(width: 350, height: 30)
            
            // VStack with Spacer minLength test
            VStack(alignment: .center, spacing: 0) {
                createSpacerTestLabel(text: "Top", color: .systemRed)
                    .layout()
                    .size(width: 100, height: 40)
                
                Spacer(minLength: 60)  // Should have at least 60pt height
                
                createSpacerTestLabel(text: "Middle", color: .systemGreen)
                    .layout()
                    .size(width: 100, height: 40)
                
                Spacer(minLength: 60)  // Should have at least 60pt height
                
                createSpacerTestLabel(text: "Bottom", color: .systemBlue)
                    .layout()
                    .size(width: 100, height: 40)
            }
            .layout()
            .size(width: 350, height: 240)
            .background(.tertiarySystemFill)
            .cornerRadius(16)
            
            // HStack with Spacer minLength test
            HStack(alignment: .center, spacing: 0) {
                createSpacerTestLabel(text: "L", color: .systemOrange)
                    .layout()
                    .size(width: 50, height: 50)
                
                Spacer(minLength: 40)  // Should have at least 40pt width
                
                createSpacerTestLabel(text: "C", color: .systemPink)
                    .layout()
                    .size(width: 50, height: 50)
                
                Spacer(minLength: 40)  // Should have at least 40pt width
                
                createSpacerTestLabel(text: "R", color: .systemCyan)
                    .layout()
                    .size(width: 50, height: 50)
            }
            .layout()
            .size(width: 350, height: 70)
            .background(.tertiarySystemFill)
            .cornerRadius(16)
        }
        .padding(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    }
    
    private var actionButtonView: some Layout {
        actionButton.layout()
            .size(width: 280, height: 56)
            .offset(y: 10)
    }
    
    // MARK: - Helper Methods
    
    private func createFeatureCard(icon: String, title: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = color.withAlphaComponent(0.1)
        container.layer.masksToBounds = true
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 40)
        iconLabel.textAlignment = .center
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        
        let vStack = VStack(alignment: .center, spacing: 8) {
            iconLabel.layout()
                .size(width: 60, height: 60)
            titleLabel.layout()
                .size(width: 100, height: 40)
        }
        .padding(16)
        
        container.addSubview(vStack)
        vStack.frame = CGRect(x: 0, y: 0, width: 110, height: 140)
        
        return container
    }
    
    private func createStatisticsCard() -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 16
        container.layer.masksToBounds = true
        
        let leftVStack = VStack(alignment: .center, spacing: 4) {
            createLabel(text: "Manual", fontSize: 24, weight: .bold, color: .systemIndigo)
                .layout()
                .size(width: 140, height: 30)
            
            createLabel(text: "Layout", fontSize: 13, weight: .regular, color: .secondaryLabel)
                .layout()
                .size(width: 140, height: 20)
        }
        .padding(UIEdgeInsets(top: 15, left: 5, bottom: 15, right: 5))
        
        let rightVStack = VStack(alignment: .center, spacing: 4) {
            createLabel(text: "4.9", fontSize: 24, weight: .bold, color: .systemIndigo)
                .layout()
                .size(width: 140, height: 30)
            
            createLabel(text: "Rating", fontSize: 13, weight: .regular, color: .secondaryLabel)
                .layout()
                .size(width: 140, height: 20)
        }
        .padding(UIEdgeInsets(top: 15, left: 5, bottom: 15, right: 5))
        
        let hStack = HStack(alignment: .center, spacing: 10) {
            leftVStack
                .layout()
                .size(width: 150, height: 80)
            
            UIView()
                .layout()
                .size(width: 1, height: 60)
                .background(.separator)
            
            rightVStack
                .layout()
                .size(width: 150, height: 80)
        }
        
        container.addSubview(hStack)
        hStack.frame = CGRect(x: 0, y: 0, width: 350, height: 100)
        
        return container
    }
    
    private func createLabel(text: String, fontSize: CGFloat, weight: UIFont.Weight, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: fontSize, weight: weight)
        label.textColor = color
        label.textAlignment = .center
        return label
    }
    
    private func createSectionTitle(text: String) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.textAlignment = .left
        return label
    }
    
    private func createBenefitRow(icon: String, text: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .tertiarySystemBackground
        container.layer.cornerRadius = 12
        container.layer.masksToBounds = true
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 18, weight: .bold)
        iconLabel.textColor = .systemGreen
        iconLabel.textAlignment = .center
        
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = .systemFont(ofSize: 15, weight: .medium)
        textLabel.textColor = .label
        
        let hStack = HStack(alignment: .center, spacing: 12) {
            iconLabel.layout().size(width: 30, height: 30)
            textLabel.layout().size(width: 280, height: 30)
        }
        .padding(UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
        
        container.addSubview(hStack)
        hStack.frame = CGRect(x: 0, y: 0, width: 350, height: 40)
        return container
    }
    
    private func createScrollCard(title: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = color.withAlphaComponent(0.15)
        container.layer.cornerRadius = 16
        container.layer.masksToBounds = true
        container.layer.borderWidth = 2
        container.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = color
        titleLabel.textAlignment = .center
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Scroll →"
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        subtitleLabel.textColor = color.withAlphaComponent(0.7)
        subtitleLabel.textAlignment = .center
        
        let vStack = VStack(alignment: .center, spacing: 8) {
            titleLabel.layout().size(width: 130, height: 30)
            subtitleLabel.layout().size(width: 130, height: 20)
        }
        .padding(16)
        
        container.addSubview(vStack)
        vStack.frame = CGRect(x: 0, y: 0, width: 150, height: 100)
        
        return container
    }
    
    private func createSpacerTestLabel(text: String, color: UIColor) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = color
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        return label
    }
    
    private func createZStackCard(backgroundColor: UIColor, title: String) -> UIView {
        let container = UIView()
        container.backgroundColor = backgroundColor.withAlphaComponent(0.2)
        container.layer.cornerRadius = 16
        container.layer.masksToBounds = true
        container.layer.borderWidth = 2
        container.layer.borderColor = backgroundColor.withAlphaComponent(0.4).cgColor
        
        if !title.isEmpty {
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
            titleLabel.textColor = backgroundColor
            titleLabel.textAlignment = .center
            
            container.addSubview(titleLabel)
            titleLabel.frame = CGRect(x: 0, y: 20, width: 300, height: 30)
        }
        
        return container
    }
    
    private func createBadgeView(text: String, color: UIColor) -> UIView {
        let badge = UIView()
        badge.backgroundColor = color
        badge.layer.cornerRadius = 12
        badge.layer.masksToBounds = true
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        
        badge.addSubview(label)
        label.frame = CGRect(x: 0, y: 0, width: 50, height: 24)
        
        return badge
    }
    
    private func createOverlayText(text: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        container.layer.cornerRadius = 8
        container.layer.masksToBounds = true
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = color
        label.textAlignment = .center
        
        container.addSubview(label)
        label.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        
        return container
    }
    
    // MARK: - Actions
    
    @objc private func actionButtonTapped() {
        let alert = UIAlertController(title: "Welcome! 🎉", message: "Thank you for using the Layout library.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
