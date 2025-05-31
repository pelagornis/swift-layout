import XCTest
import UIKit
import SwiftUI
@testable import Layout

/// Performance tests for layout calculations
class LayoutPerformanceTests: XCTestCase {
    
    func testSimpleLayoutPerformance() {
        let views = (0..<100).map { _ in UIView() }
        let container = LayoutContainer(frame: CGRect(x: 0, y: 0, width: 300, height: 400))
        
        container.setBody {
            Vertical(spacing: 4) {
                ForEach(views) { view in
                    view.layout().size(width: 280, height: 30)
                }
            }
        }
        
        // Measure layout performance
        measure {
            container.layoutSubviews()
        }
    }
    
    func testComplexNestedLayoutPerformance() {
        let container = LayoutContainer(frame: CGRect(x: 0, y: 0, width: 300, height: 400))
        let views = (0..<50).map { _ in
            (
                UIView(), // Container
                UILabel(), // Title
                UILabel(), // Subtitle
                UIButton() // Action
            )
        }
        
        container.setBody {
            Vertical(spacing: 8) {
                ForEach(views) { (containerView, titleLabel, subtitleLabel, actionButton) in
                    ZStack {
                        [
                            containerView.layout()
                                .size(width: 280, height: 80),
                            
                            Horizontal(spacing: 12) {
                                [
                                    Vertical(alignment: .leading) {
                                        [
                                            titleLabel.layout().size(width: 180, height: 20),
                                            subtitleLabel.layout().size(width: 180, height: 16)
                                        ]
                                    },
                                    
                                    actionButton.layout().size(width: 60, height: 32)
                                ]
                            }
                        ]
                    }
                }
            }
        }
        
        // Measure complex layout performance
        measure {
            container.layoutSubviews()
        }
    }
    
    func testLayoutBuilderPerformance() {
        let views = (0..<1000).map { _ in UIView() }
        
        // Measure layout builder creation performance
        measure {
            let _ = Vertical {
                ForEach(views) { view in
                    view.layout()
                }
            }
        }
    }
}