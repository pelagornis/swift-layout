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
    }
    
    override func setLayout() {
        layoutContainer.setBody {
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
                featureCardsSection
                benefitsSection
                actionButtonView
                Spacer(minLength: 40)
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
                
                createFeatureCard(icon: "⚡️", title: "Performance", color: .systemOrange)
                    .layout()
                    .size(width: 110, height: 140)
                
                createFeatureCard(icon: "🚀", title: "Simplicity", color: .systemBlue)
                    .layout()
                    .size(width: 110, height: 140)
            }
            .padding(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        }
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
    
    private var actionButtonView: some Layout {
        actionButton.layout()
            .size(width: 280, height: 56)
            .offset(y: 10)
    }
    
    // MARK: - Helper Methods
    
    private func createFeatureCard(icon: String, title: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = color.withAlphaComponent(0.1)
        container.layer.cornerRadius = 16
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
    
    // MARK: - Actions
    
    @objc private func actionButtonTapped() {
        let alert = UIAlertController(title: "Welcome! 🎉", message: "Thank you for using the Layout library.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
