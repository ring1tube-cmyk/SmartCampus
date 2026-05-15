import UIKit

class AnnouncementDetailViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    private let senderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemBlue
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let importantBadge: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 4
        view.isHidden = true
        return view
    }()
    
    private let importantLabel: UILabel = {
        let label = UILabel()
        label.text = "IMPORTANT ANNOUNCEMENT"
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .systemRed
        label.isHidden = true
        return label
    }()
    
    // MARK: - Properties
    private let announcement: Announcement
    
    // MARK: - Initializer
    init(announcement: Announcement) {
        self.announcement = announcement
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Announcement"
        
        [scrollView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        [containerView].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [titleLabel, importantBadge, importantLabel, senderLabel, dateLabel,
         dividerView, messageLabel].forEach {
            containerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: importantBadge.leadingAnchor, constant: -12),
            
            importantBadge.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 26),
            importantBadge.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            importantBadge.widthAnchor.constraint(equalToConstant: 10),
            importantBadge.heightAnchor.constraint(equalToConstant: 10),
            
            importantLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            importantLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            senderLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            senderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            dateLabel.topAnchor.constraint(equalTo: senderLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            dividerView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            dividerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            dividerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            dividerView.heightAnchor.constraint(equalToConstant: 1),
            
            messageLabel.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            messageLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
    }
    
    private func populateData() {
        titleLabel.text = announcement.title
        senderLabel.text = "From: \(announcement.senderName) (\(announcement.senderRole.replacingOccurrences(of: "_", with: " ").capitalized))"
        dateLabel.text = announcement.formattedDate
        messageLabel.text = announcement.message
        
        if announcement.isImportant {
            importantBadge.isHidden = false
            importantLabel.isHidden = false
            containerView.layer.borderWidth = 1
            containerView.layer.borderColor = UIColor.systemRed.cgColor
        }
    }
}