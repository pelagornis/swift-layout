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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // When layout changes (e.g., screen rotation), update slideBoxOriginalX to new center position
        // and reapply current offset if it exists with smooth animation
        if currentOffset != 0 && slideBoxOriginalX != nil {
            // Layout has changed, need to update the reference position
            // First, let layout system calculate the new centered position
            layoutContainer.updateBody { self.body }
            
            // Get the new centered position and current position
            let newCenteredX = slideBox.frame.origin.x
            let currentX = slideBox.frame.origin.x
            slideBoxOriginalX = newCenteredX
            
            // Calculate target position with offset
            let currentFrame = slideBox.frame
            let targetX = newCenteredX + currentOffset
            let targetFrame = CGRect(
                x: targetX,
                y: currentFrame.origin.y,
                width: currentFrame.width,
                height: currentFrame.height
            )
            
            // Only animate if the position actually changed significantly
            if abs(currentX - targetX) > 1 {
                // Ensure slideBox starts from current position
                slideBox.frame = currentFrame
                
                // Use smooth spring animation for better feel
                layoutContainer.startAnimating(slideBox)
                withAnimation(.spring(damping: 0.7, velocity: 0.5), {
                    self.slideBox.frame = targetFrame
                }, completion: { _ in
                    self.layoutContainer.stopAnimating(self.slideBox)
                })
            } else {
                // No significant change, just set the frame without animation
                layoutContainer.startAnimating(slideBox)
                slideBox.frame = targetFrame
                layoutContainer.stopAnimating(slideBox)
            }
        } else if slideBoxOriginalX != nil {
            // Just update the reference position if no offset is applied
            layoutContainer.updateBody { self.body }
            slideBoxOriginalX = slideBox.frame.origin.x
        }
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
                .size(width: 90%, height: 40)
            
            createLabel(text: "SwiftUI-style animations with Layout", fontSize: 14, weight: .regular, color: .secondaryLabel)
                .layout()
                .size(width: 90%, height: 20)
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
    
    private lazy var chainDemoView: ResponsiveChainDemoView = {
        let view = ResponsiveChainDemoView()
        return view
    }()
    
    private var chainSection: some Layout {
        VStack(alignment: .center, spacing: 12) {
            sectionTitle("withAnimation Function")
            
            chainDemoView
                .layout()
                .size(width: 90%, height: 100)
            
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
        return label.layout().size(width: 90%, height: 24)
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
    
    // Helper class to handle dynamic layout for chain demo view
    private class ResponsiveChainDemoView: UIView {
        let box1: UIView
        let box2: UIView
        let box3: UIView
        private let label: UILabel
        
        init() {
            let b1 = UIView()
            b1.backgroundColor = .systemRed
            b1.layer.cornerRadius = 8
            b1.tag = 101
            self.box1 = b1
            
            let b2 = UIView()
            b2.backgroundColor = .systemYellow
            b2.layer.cornerRadius = 8
            b2.tag = 102
            self.box2 = b2
            
            let b3 = UIView()
            b3.backgroundColor = .systemBlue
            b3.layer.cornerRadius = 8
            b3.tag = 103
            self.box3 = b3
            
            let lbl = UILabel()
            lbl.text = "Tap button!"
            lbl.font = .systemFont(ofSize: 12, weight: .medium)
            lbl.textColor = .secondaryLabel
            lbl.textAlignment = .center
            lbl.tag = 104
            self.label = lbl
            
            super.init(frame: .zero)
            
            self.backgroundColor = .secondarySystemBackground
            self.layer.cornerRadius = 16
            
            addSubview(box1)
            addSubview(box2)
            addSubview(box3)
            addSubview(label)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            let containerWidth = bounds.width
            let containerHeight = bounds.height
            let boxSize: CGFloat = 40
            let spacing: CGFloat = 20
            let labelWidth: CGFloat = 100
            let labelHeight: CGFloat = 30
            
            // Calculate total width needed
            let totalContentWidth = boxSize * 3 + spacing * 2 + labelWidth + spacing
            let startX = max(0, (containerWidth - totalContentWidth) / 2)
            let centerY = containerHeight / 2
            
            // Layout boxes and label centered
            box1.frame = CGRect(
                x: startX,
                y: centerY - boxSize / 2,
                width: boxSize,
                height: boxSize
            )
            
            box2.frame = CGRect(
                x: startX + boxSize + spacing,
                y: centerY - boxSize / 2,
                width: boxSize,
                height: boxSize
            )
            
            box3.frame = CGRect(
                x: startX + (boxSize + spacing) * 2,
                y: centerY - boxSize / 2,
                width: boxSize,
                height: boxSize
            )
            
            label.frame = CGRect(
                x: startX + (boxSize + spacing) * 3,
                y: centerY - labelHeight / 2,
                width: labelWidth,
                height: labelHeight
            )
        }
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
        // Save current frame before any changes (this is the starting position for animation)
        let startFrame = slideBox.frame
        
        // Toggle offset: 0 -> 80, 80 -> 0
        currentOffset = currentOffset == 0 ? 80 : 0
        
        // Mark slideBox as animating to prevent layout from overriding
        layoutContainer.startAnimating(slideBox)
        
        // Update layout first (other views update immediately, slideBox is skipped)
        layoutContainer.updateBody { self.body }
        
        // After layout update, get the new centered position
        let newCenteredFrame = slideBox.frame
        
        // Update slideBoxOriginalX to the new centered position
        // This ensures we have the correct reference point after rotation
        if slideBoxOriginalX == nil || abs(slideBoxOriginalX! - newCenteredFrame.origin.x) > 10 {
            slideBoxOriginalX = newCenteredFrame.origin.x
        }
        
        // Calculate target frame: centered position + offset
        guard let originalX = slideBoxOriginalX else { return }
        let targetFrame = CGRect(
            x: originalX + currentOffset,
            y: newCenteredFrame.origin.y,
            width: newCenteredFrame.width,
            height: newCenteredFrame.height
        )
        
        // Ensure slideBox starts from its current position (before animation)
        // This is important for smooth animation from current position to target
        slideBox.frame = startFrame
        
        // Animate from current position to target position
        withAnimation(.easeOut(duration: 0.3), {
            self.slideBox.frame = targetFrame
        }, completion: { _ in
            // Stop animating after animation completes
            // Don't update layout again - it would reset the position
            self.layoutContainer.stopAnimating(self.slideBox)
        })
    }
    
    @objc private func chainTapped() {
        // Mark boxes as animating to prevent layout from overriding
        layoutContainer.startAnimating(chainDemoView.box1)
        layoutContainer.startAnimating(chainDemoView.box2)
        layoutContainer.startAnimating(chainDemoView.box3)
        
        // Reset first
        chainDemoView.box1.transform = .identity
        chainDemoView.box2.transform = .identity
        chainDemoView.box3.transform = .identity
        
        // Chain animation using Layout library's withAnimation
        withAnimation(.spring(damping: 0.6)) {
            self.chainDemoView.box1.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(damping: 0.6)) {
                self.chainDemoView.box2.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(damping: 0.6)) {
                self.chainDemoView.box3.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }
        }
        
        // Reset after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(damping: 0.7)) {
                self.chainDemoView.box1.transform = .identity
                self.chainDemoView.box2.transform = .identity
                self.chainDemoView.box3.transform = .identity
            }
            
            // Stop animating after all animations complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.layoutContainer.stopAnimating(self.chainDemoView.box1)
                self.layoutContainer.stopAnimating(self.chainDemoView.box2)
                self.layoutContainer.stopAnimating(self.chainDemoView.box3)
            }
        }
    }
}
