import UIKit
import Layout

final class AnimationDemoViewController: BaseViewController, Layout {
    
    // MARK: - State
    private var isExpanded = false
    private var isVisible = true
    private var currentScale: CGFloat = 1.0
    private var currentOffset: CGFloat = 0
    private var slideBoxOriginalX: CGFloat? // Store original x position
    private var displayLink: CADisplayLink?
    private var shouldSkipPositionUpdate = false // Flag to skip position update after animation
    
    // MARK: - UI Components
    private let expandableBox: UIView = {
        let view = UIView()
        view.backgroundColor = .systemIndigo
        view.layer.cornerRadius = 16
        return view
    }()

    private let fadeBox: UIView = {
        let view = UIView()
        view.backgroundColor = .systemPink
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let springBox: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let slideBox: UIView = {
        let view = UIView()
        view.backgroundColor = .systemOrange
        view.layer.cornerRadius = 16
        return view
    }()
    
    // MARK: - Buttons
    private lazy var expandButton: UIButton = createButton(title: "Expand/Collapse", color: .systemIndigo)
    private lazy var fadeButton: UIButton = createButton(title: "Fade In/Out", color: .systemPink)
    private lazy var springButton: UIButton = createButton(title: "Spring Bounce", color: .systemGreen)
    private lazy var slideButton: UIButton = createButton(title: "Slide", color: .systemOrange)
    private lazy var chainButton: UIButton = createButton(title: "Chain Animation", color: .systemPurple)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Enable layout debugging
        enableLayoutDebugging = true
        title = "Animation"
        view.backgroundColor = .systemBackground
        setupActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func setLayout() {
        layoutContainer.updateBody {
            self.body
        }
    }
    
    // MARK: - Layout
    
    @LayoutBuilder
    var body: some Layout {
        ScrollView {
            VStack(alignment: .center, spacing: 24) {
                headerSection
                expandSection
                fadeSection
                springSection
                slideSection
                chainSection
                Spacer(minLength: 50)
            }
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some Layout {
        VStack(alignment: .center, spacing: 8) {
            createLabel(text: "🎬 Animation Demo", fontSize: 28, weight: .bold, color: .label)
                .layout()
                .size(width: 300, height: 40)
            
            createLabel(text: "SwiftUI-style animations with Layout", fontSize: 14, weight: .regular, color: .secondaryLabel)
                .layout()
                .size(width: 300, height: 20)
        }
        .padding(UIEdgeInsets(top: 20, left: 20, bottom: 10, right: 20))
    }
    
    private var expandSection: some Layout {
        VStack(alignment: .center, spacing: 12) {
            sectionTitle("Size Animation (.easeInOut)")

            // Use expandableBox directly with dynamic size based on isExpanded state
            expandableBox
                .layout()
                .size(
                    width: isExpanded ? 300 : 150,
                    height: isExpanded ? 120 : 60
                )

            expandButton
                .layout()
                .size(width: 200, height: 44)
        }
        .padding(UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
    }
    
    private var fadeSection: some Layout {
        VStack(alignment: .center, spacing: 12) {
            sectionTitle("Opacity Animation (.linear)")
            
            fadeBox.layout()
                .size(width: 150, height: 60)
            
            fadeButton.layout()
                .size(width: 200, height: 44)
        }
        .padding(UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
    }
    
    private var springSection: some Layout {
        VStack(alignment: .center, spacing: 12) {
            sectionTitle("Spring Animation (.spring)")
            
            springBox.layout()
                .size(width: 150, height: 60)
            
            springButton.layout()
                .size(width: 200, height: 44)
        }
        .padding(UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
    }
    
    private var slideSection: some Layout {
        VStack(alignment: .center, spacing: 12) {
            sectionTitle("Offset Animation (.easeOut)")
            
            // Don't use offset modifier - we'll animate frame directly
            slideBox.layout()
                .size(width: 150, height: 60)
            
            slideButton.layout()
                .size(width: 200, height: 44)
        }
        .padding(UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
    }
    
    private var chainSection: some Layout {
        VStack(alignment: .center, spacing: 12) {
            sectionTitle("withAnimation Function")
            
            createChainDemoView()
                .layout()
                .size(width: 320, height: 100)
            
            chainButton.layout()
                .size(width: 200, height: 44)
        }
        .padding(UIEdgeInsets(top: 10, left: 20, bottom: 20, right: 20))
    }
    
    // MARK: - Helper Methods
    
    private func sectionTitle(_ text: String) -> some Layout {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        return label.layout().size(width: 300, height: 24)
    }
    
    private func createButton(title: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }
    
    private func createLabel(text: String, fontSize: CGFloat, weight: UIFont.Weight, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: fontSize, weight: weight)
        label.textColor = color
        label.textAlignment = .center
        return label
    }
    
    private func createChainDemoView() -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 16
        
        let box1 = UIView(frame: CGRect(x: 20, y: 30, width: 40, height: 40))
        box1.backgroundColor = .systemRed
        box1.layer.cornerRadius = 8
        box1.tag = 101
        
        let box2 = UIView(frame: CGRect(x: 80, y: 30, width: 40, height: 40))
        box2.backgroundColor = .systemYellow
        box2.layer.cornerRadius = 8
        box2.tag = 102
        
        let box3 = UIView(frame: CGRect(x: 140, y: 30, width: 40, height: 40))
        box3.backgroundColor = .systemBlue
        box3.layer.cornerRadius = 8
        box3.tag = 103
        
        let label = UILabel(frame: CGRect(x: 200, y: 35, width: 100, height: 30))
        label.text = "Tap button!"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.tag = 104
        
        container.addSubview(box1)
        container.addSubview(box2)
        container.addSubview(box3)
        container.addSubview(label)
        
        return container
    }
    
    // MARK: - Actions Setup
    
    private func setupActions() {
        expandButton.addTarget(self, action: #selector(expandTapped), for: .touchUpInside)
        fadeButton.addTarget(self, action: #selector(fadeTapped), for: .touchUpInside)
        springButton.addTarget(self, action: #selector(springTapped), for: .touchUpInside)
        slideButton.addTarget(self, action: #selector(slideTapped), for: .touchUpInside)
        chainButton.addTarget(self, action: #selector(chainTapped), for: .touchUpInside)
    }
    
    // MARK: - Animation Actions
    
    @objc private func displayLinkTick() {
        let frame = expandableBox.frame
    }
    
    @objc private func expandTapped() {
        // Save current frame before any changes
        let currentFrame = expandableBox.frame
        let currentWidth = currentFrame.width > 0 ? currentFrame.width : 150
        let currentHeight = currentFrame.height > 0 ? currentFrame.height : 60
        let centerX = currentFrame.midX
        let centerY = currentFrame.midY
        
        // Save slideBox position if it has been moved
        let slideBoxCurrentFrame = slideBox.frame
        let slideBoxNeedsProtection = currentOffset != 0
        
        // Toggle state
        isExpanded.toggle()
        
        // Calculate target size
        let targetWidth: CGFloat = isExpanded ? 300 : 150
        let targetHeight: CGFloat = isExpanded ? 120 : 60
        
        // Mark expandableBox and slideBox (if moved) as animating to prevent layout from overriding
        layoutContainer.startAnimating(expandableBox)
        if slideBoxNeedsProtection {
            layoutContainer.startAnimating(slideBox)
        }
        
        // Update layout first (other views will update immediately, protected views are skipped)
        layoutContainer.updateBody { self.body }
        
        // Ensure expandableBox starts from current frame
        expandableBox.frame = CGRect(
            x: centerX - currentWidth / 2,
            y: centerY - currentHeight / 2,
            width: currentWidth,
            height: currentHeight
        )
        
        // Restore slideBox position if it was moved
        if slideBoxNeedsProtection {
            slideBox.frame = slideBoxCurrentFrame
        }
        
        // Calculate target frame maintaining center position
        let targetFrame = CGRect(
            x: centerX - targetWidth / 2,
            y: centerY - targetHeight / 2,
            width: targetWidth,
            height: targetHeight
        )
        
        // Animate only the expandableBox
        withAnimation(.easeInOut(duration: 0.3), {
            self.expandableBox.frame = targetFrame
        }, completion: { _ in
            // Stop animating after animation completes
            self.layoutContainer.stopAnimating(self.expandableBox)
            if slideBoxNeedsProtection {
                self.layoutContainer.stopAnimating(self.slideBox)
            }
            // Update layout one more time to ensure everything is in sync
            self.layoutContainer.updateBody { self.body }
            // Restore slideBox position after layout update
            if slideBoxNeedsProtection, let originalX = self.slideBoxOriginalX {
                self.slideBox.frame = CGRect(
                    x: originalX + self.currentOffset,
                    y: slideBoxCurrentFrame.origin.y,
                    width: slideBoxCurrentFrame.width,
                    height: slideBoxCurrentFrame.height
                )
            }
        })
    }
    
    @objc private func fadeTapped() {
        isVisible.toggle()
        
        // Using Layout library's withAnimation
        withAnimation(.linear(duration: 0.3)) {
            self.fadeBox.alpha = self.isVisible ? 1.0 : 0.3
        }
    }
    
    @objc private func springTapped() {
        // Spring animation using Layout library
        let scale: CGFloat = currentScale == 1.0 ? 1.3 : 1.0
        currentScale = scale
        
        withAnimation(.spring(damping: 0.5, velocity: 0.8)) {
            self.springBox.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    @objc private func slideTapped() {
        // Save current frame before any changes
        let currentFrame = slideBox.frame
        
        // Store original x position on first use
        if slideBoxOriginalX == nil {
            slideBoxOriginalX = currentFrame.origin.x
        }
        
        // Toggle offset: 0 -> 80, 80 -> 0
        currentOffset = currentOffset == 0 ? 80 : 0
        
        // Mark slideBox as animating to prevent layout from overriding
        layoutContainer.startAnimating(slideBox)
        
        // Update layout first (other views will update immediately, slideBox is skipped)
        layoutContainer.updateBody { self.body }
        
        // Ensure slideBox starts from current position
        slideBox.frame = currentFrame
        
        // Calculate target frame: original position + offset
        guard let originalX = slideBoxOriginalX else { return }
        let targetFrame = CGRect(
            x: originalX + currentOffset,
            y: currentFrame.origin.y,
            width: currentFrame.width,
            height: currentFrame.height
        )
        
        // Animate only the slideBox
        withAnimation(.easeOut(duration: 0.3), {
            self.slideBox.frame = targetFrame
        }, completion: { _ in
            // Stop animating after animation completes
            // Don't update layout again - it would reset the position
            self.layoutContainer.stopAnimating(self.slideBox)
        })
    }
    
    @objc private func chainTapped() {
        // Find the chain demo view and animate boxes sequentially
        guard let chainView = view.viewWithTag(101)?.superview else { return }
        
        let box1 = chainView.viewWithTag(101)
        let box2 = chainView.viewWithTag(102)
        let box3 = chainView.viewWithTag(103)
        
        // Reset first
        box1?.transform = .identity
        box2?.transform = .identity
        box3?.transform = .identity
        
        // Chain animation using Layout library's withAnimation
        withAnimation(.spring(damping: 0.6)) {
            box1?.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(damping: 0.6)) {
                box2?.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(damping: 0.6)) {
                box3?.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }
        }
        
        // Reset after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(damping: 0.7)) {
                box1?.transform = .identity
                box2?.transform = .identity
                box3?.transform = .identity
            }
        }
    }
}
