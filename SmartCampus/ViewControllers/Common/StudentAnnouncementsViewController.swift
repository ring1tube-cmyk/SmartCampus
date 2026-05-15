import UIKit

class StudentAnnouncementsViewController: UIViewController {
    
    // MARK: - UI Components
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No announcements yet.\nCheck back later for updates from your instructors and administration."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        label.isHidden = true
        return label
    }()
    
    // MARK: - Properties
    private var announcements: [Announcement] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadAnnouncements()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Announcements"
        
        [tableView, activityIndicator, emptyStateLabel].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        activityIndicator.hidesWhenStopped = true
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AnnouncementCell.self, forCellReuseIdentifier: "AnnouncementCell")
        tableView.separatorStyle = .none
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    // MARK: - Data Loading
    private func loadAnnouncements() {
        activityIndicator.startAnimating()
        
        FirebaseService.shared.fetchStudentAnnouncements { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.refreshControl.endRefreshing()
                
                switch result {
                case .success(let announcements):
                    self?.announcements = announcements
                    self?.tableView.reloadData()
                    self?.emptyStateLabel.isHidden = !announcements.isEmpty
                case .failure(let error):
                    self?.showAlert(message: "Failed to load announcements: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func refreshData() {
        loadAnnouncements()
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showAnnouncementDetail(_ announcement: Announcement) {
        let detailVC = AnnouncementDetailViewController(announcement: announcement)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - TableView Delegates
extension StudentAnnouncementsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return announcements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnnouncementCell", for: indexPath) as! AnnouncementCell
        let announcement = announcements[indexPath.row]
        cell.configure(with: announcement)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let announcement = announcements[indexPath.row]
        showAnnouncementDetail(announcement)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

// MARK: - Announcement Cell
class AnnouncementCell: UITableViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 2
        return label
    }()
    
    private let senderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemBlue
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .regular)
        label.textColor = .tertiaryLabel
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
        label.text = "IMPORTANT"
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = .systemRed
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        [titleLabel, senderLabel, messageLabel, dateLabel, importantBadge, importantLabel].forEach {
            containerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: importantBadge.leadingAnchor, constant: -8),
            
            importantBadge.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            importantBadge.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            importantBadge.widthAnchor.constraint(equalToConstant: 8),
            importantBadge.heightAnchor.constraint(equalToConstant: 8),
            
            importantLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            importantLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            senderLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            senderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            messageLabel.topAnchor.constraint(equalTo: senderLabel.bottomAnchor, constant: 6),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            dateLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with announcement: Announcement) {
        titleLabel.text = announcement.title
        senderLabel.text = "📢 \(announcement.senderName) • \(announcement.senderRole.replacingOccurrences(of: "_", with: " ").capitalized)"
        messageLabel.text = announcement.message
        dateLabel.text = announcement.formattedDate
        
        if announcement.isImportant {
            importantBadge.isHidden = false
            importantLabel.isHidden = false
        } else {
            importantBadge.isHidden = true
            importantLabel.isHidden = true
        }
        
        // Highlight important announcements
        if announcement.isImportant {
            containerView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
            titleLabel.textColor = .systemRed
        } else {
            containerView.backgroundColor = .systemGray6
            titleLabel.textColor = .label
        }
    }
}