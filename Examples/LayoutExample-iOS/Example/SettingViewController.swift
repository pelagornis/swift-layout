import UIKit
import Layout

final class SettingViewController: BaseViewController {
    
    // MARK: - Data Models
    
    enum SettingSection: Int, CaseIterable {
        case profile
        case general
        case appearance
        case about
        
        var title: String {
            switch self {
            case .profile: return "Profile"
            case .general: return "General"
            case .appearance: return "Appearance"
            case .about: return "About"
            }
        }
    }
    
    struct SettingItem {
        let icon: String
        let title: String
        let subtitle: String?
        let accessoryType: UITableViewCell.AccessoryType
        let action: (() -> Void)?
        
        init(icon: String, title: String, subtitle: String? = nil, accessoryType: UITableViewCell.AccessoryType = .disclosureIndicator, action: (() -> Void)? = nil) {
            self.icon = icon
            self.title = title
            self.subtitle = subtitle
            self.accessoryType = accessoryType
            self.action = action
        }
    }
    
    // MARK: - Properties
    
    private var settings: [[SettingItem]] = []
    
    // MARK: - UI Components
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.delegate = self
        table.dataSource = self
        table.register(SettingCell.self, forCellReuseIdentifier: SettingCell.identifier)
        table.register(ProfileCell.self, forCellReuseIdentifier: ProfileCell.identifier)
        table.backgroundColor = .systemGroupedBackground
        return table
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemGroupedBackground
        
        // Enable layout debugging
        enableLayoutDebugging = true
        
        setupData()
        setupTableView()
    }
    
    // MARK: - Setup
    
    private func setupData() {
        settings = [
            [
                SettingItem(icon: "👤", title: "Edit Profile", subtitle: "Change name and photo") { [weak self] in
                    self?.showAlert(title: "Edit Profile", message: "Edit your profile information.")
                }
            ],
            [
                SettingItem(icon: "🔔", title: "Notifications", subtitle: "Push notification settings") { [weak self] in
                    self?.showAlert(title: "Notifications", message: "Configure notification settings.")
                },
                SettingItem(icon: "🔒", title: "Privacy", subtitle: "Security and privacy") { [weak self] in
                    self?.showAlert(title: "Privacy", message: "Manage privacy settings.")
                },
                SettingItem(icon: "💾", title: "Storage", subtitle: "32.5 GB used") { [weak self] in
                    self?.showAlert(title: "Storage", message: "Manage your storage.")
                }
            ],
            [
                SettingItem(icon: "🎨", title: "Dark Mode", subtitle: "Follow system") { [weak self] in
                    self?.showAlert(title: "Dark Mode", message: "Change dark mode settings.")
                },
                SettingItem(icon: "🔤", title: "Font Size", subtitle: "Medium") { [weak self] in
                    self?.showAlert(title: "Font Size", message: "Adjust font size.")
                },
                SettingItem(icon: "🌈", title: "Theme Color", subtitle: "Indigo") { [weak self] in
                    self?.showAlert(title: "Theme Color", message: "Change theme color.")
                }
            ],
            [
                SettingItem(icon: "ℹ️", title: "Version", subtitle: "1.0.0", accessoryType: .none),
                SettingItem(icon: "📄", title: "Licenses") { [weak self] in
                    self?.showAlert(title: "Licenses", message: "View open source licenses.")
                },
                SettingItem(icon: "📧", title: "Contact Us") { [weak self] in
                    self?.showAlert(title: "Contact Us", message: "Contact the developer.")
                }
            ]
        ]
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Helper Methods
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension SettingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.identifier, for: indexPath) as! SettingCell
        let item = settings[indexPath.section][indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let settingSection = SettingSection(rawValue: section) else { return nil }
        return settingSection.title
    }
}

// MARK: - UITableViewDelegate
extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = settings[indexPath.section][indexPath.row]
        item.action?()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - SettingCell

class SettingCell: UITableViewCell {
    static let identifier = "SettingCell"
    
    // MARK: - UI Components
    
    private let iconLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // Using Layout library components
        iconContainer.addSubview(iconLabel)
        contentView.addSubview(iconContainer)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // HStack-like horizontal positioning
        iconContainer.frame = CGRect(x: 16, y: (contentView.bounds.height - 40) / 2, width: 40, height: 40)
        iconLabel.frame = iconContainer.bounds
        
        let titleX: CGFloat = 68  // 16 + 40 + 12 (HStack spacing)
        let titleWidth = contentView.bounds.width - titleX - 40
        
        if subtitleLabel.isHidden {
            titleLabel.frame = CGRect(x: titleX, y: (contentView.bounds.height - 24) / 2, width: titleWidth, height: 24)
        } else {
            // VStack-like vertical layout with spacing: 2
            titleLabel.frame = CGRect(x: titleX, y: 12, width: titleWidth, height: 24)
            subtitleLabel.frame = CGRect(x: titleX, y: 38, width: titleWidth, height: 18)
        }
    }
    
    func configure(with item: SettingViewController.SettingItem) {
        iconLabel.text = item.icon
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        subtitleLabel.isHidden = item.subtitle == nil
        accessoryType = item.accessoryType
        setNeedsLayout()
    }
}

// MARK: - ProfileCell

class ProfileCell: UITableViewCell {
    static let identifier = "ProfileCell"
    
    // MARK: - UI Components
    
    private let profileImageView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemIndigo
        view.layer.cornerRadius = 35
        view.layer.masksToBounds = true
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // Using Layout library components concept
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // HStack-like horizontal positioning with spacing: 16
        profileImageView.frame = CGRect(x: 16, y: (contentView.bounds.height - 70) / 2, width: 70, height: 70)
        
        let labelX: CGFloat = 102  // 16 + 70 + 16 (HStack spacing)
        let labelWidth = contentView.bounds.width - labelX - 16
        
        // VStack-like vertical positioning with spacing: 4
        nameLabel.frame = CGRect(x: labelX, y: 20, width: labelWidth, height: 24)
        emailLabel.frame = CGRect(x: labelX, y: 48, width: labelWidth, height: 20)
    }
    
    func configure(name: String, email: String) {
        nameLabel.text = name
        emailLabel.text = email
        setNeedsLayout()
    }
}
