import XCTest
import UIKit
import SwiftUI
@testable import Layout

/// Performance tests for layout calculations
class LayoutPerformanceTests: XCTestCase {
    
    struct CardViews: Hashable {
        let container: UIView
        let title: UILabel
        let subtitle: UILabel
        let action: UIButton
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(container))
        }
        
        static func == (lhs: CardViews, rhs: CardViews) -> Bool {
            return lhs.container === rhs.container
        }
    }
    
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
            CardViews(
                container: UIView(),
                title: UILabel(),
                subtitle: UILabel(),
                action: UIButton()
            )
        }
        
        container.setBody {
            VStack(spacing: 8) {
                ForEach(views) { cardViews in
                    ZStack {
                        
                        cardViews.container.layout()
                            .size(width: 280, height: 80)
                        
                        HStack(spacing: 12) {
                            
                            VStack(alignment: .leading) {
                                
                                cardViews.title.layout().size(width: 180, height: 20)
                                cardViews.subtitle.layout().size(width: 180, height: 16)
                                
                            }
                            
                            cardViews.action.layout().size(width: 60, height: 32)
                            
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
