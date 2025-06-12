import UIKit
import Layout

final class GroupView: UIView, Layout {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.text = "Hello, World!"
        return label
    }()
    
    var body: some Layout {
        VStack {
            titleLabel.layout()
        }
    }
}
