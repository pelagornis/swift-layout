import XCTest
import UIKit
import SwiftUI
@testable import Layout

/// Performance tests for layout calculations
class LayoutPerformanceTests: XCTestCase {
    
    @MainActor func testSimpleLayoutPerformance() {
        let views = (0..<100).map { _ in UIView() }
        let container = LayoutContainer(frame: CGRect(x: 0, y: 0, width: 300, height: 400))
        
        container.setBody {
            VStack(spacing: 4) {
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
    
    @MainActor func testComplexNestedLayoutPerformance() {
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
            VStack(spacing: 8) {
                ForEach(views) { (containerView, titleLabel, subtitleLabel, actionButton) in
                    ZStack {
                        
                        containerView.layout()
                            .size(width: 280, height: 80)
                        
                        HStack(spacing: 12) {
                            
                            VStack(alignment: .leading) {
                                
                                titleLabel.layout().size(width: 180, height: 20)
                                subtitleLabel.layout().size(width: 180, height: 16)
                                
                            }
                            
                            actionButton.layout().size(width: 60, height: 32)
                            
                        }
                        
                    }
                }
            }
        }
        
        // Measure complex layout performance
        measure {
            container.layoutSubviews()
        }
    }
    
    @MainActor
    func testLayoutBuilderPerformance() {
        let views = (0..<1000).map { _ in UIView() }
        
        // Measure layout builder creation performance
        measure {
            let _ = VStack {
                ForEach(views) { view in
                    view.layout()
                }
            }
        }
    }
}
