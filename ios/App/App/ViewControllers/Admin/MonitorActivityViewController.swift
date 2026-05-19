import UIKit

class MonitorActivityViewController: UIViewController {
    
    // MARK: - UI Components
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No activity logs available."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        label.isHidden = true
        return label
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.maximumDate = Date()
        return picker
    }()
    
    private let filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Filter", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    // MARK: - Properties
    private var activities: [ActivityLog] = []
    private var filteredActivities: [ActivityLog] = []
    
    struct ActivityLog {
        let id: String
        let userId: String
        let userName: String
        let userRole: String
        let action: String
        let details: String
        let timestamp: Date
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupActions()
        loadActivities()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "System Activity"
        
        [datePicker, filterButton, tableView, activityIndicator, emptyStateLabel].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        activityIndicator.hidesWhenStopped = true
        
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            filterButton.centerYAnchor.constraint(equalTo: datePicker.centerYAnchor),
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filterButton.widthAnchor.constraint(equalToConstant: 80),
            filterButton.heightAnchor.constraint(equalToConstant: 36),
            
            tableView.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 16),
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
        tableView.register(ActivityCell.self, forCellReuseIdentifier: "ActivityCell")
        tableView.separatorStyle = .none
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupActions() {
        filterButton.addTarget(self, action: #selector(filterActivities), for: .touchUpInside)
    }
    
    @objc private func filterActivities() {
        let selectedDate = datePicker.date
        let calendar = Calendar.current
        
        filteredActivities = activities.filter { activity in
            calendar.isDate(activity.timestamp, inSameDayAs: selectedDate)
        }
        
        tableView.reloadData()
        emptyStateLabel.isHidden = !filteredActivities.isEmpty
    }
    
    @objc private func refreshData() {
        loadActivities()
    }
    
    // MARK: - Data Loading
    private func loadActivities() {
        activityIndicator.startAnimating()
        
        // Fetch from system_logs collection
        FirebaseService.shared.db.collection("system_logs")
            .order(by: "timestamp", descending: true)
            .limit(to: 100)
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.refreshControl.endRefreshing()
                    
                    if let error = error {
                        self?.showAlert(message: "Failed to load activities: \(error.localizedDescription)")
                        return
                    }
                    
                    self?.activities = snapshot?.documents.compactMap { doc in
                        let data = doc.data()
                        guard let userId = data["userId"] as? String,
                              let userName = data["userName"] as? String,
                              let userRole = data["userRole"] as? String,
                              let action = data["action"] as? String,
                              let details = data["details"] as? String,
                              let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() else {
                            return nil
                        }
                        
                        return ActivityLog(
                            id: doc.documentID,
                            userId: userId,
                            userName: userName,
                            userRole: userRole,
                            action: action,
                            details: details,
                            timestamp: timestamp
                        )
                    } ?? []
                    
                    self?.filterActivities()
                }
            }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - TableView Delegates
extension MonitorActivityViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredActivities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as! ActivityCell
        let activity = filteredActivities[indexPath.row]
        cell.configure(with: activity)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - Activity Cell
class ActivityCell: UITableViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let userLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    private let actionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemBlue
        return label
    }()
    
    private let detailsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .regular)
        label.textColor = .tertiaryLabel
        label.textAlignment = .right
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
        
        [userLabel, actionLabel, detailsLabel, timeLabel].forEach {
            containerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            userLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            userLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            timeLabel.centerYAnchor.constraint(equalTo: userLabel.centerYAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            actionLabel.topAnchor.constraint(equalTo: userLabel.bottomAnchor, constant: 4),
            actionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            detailsLabel.topAnchor.constraint(equalTo: actionLabel.bottomAnchor, constant: 4),
            detailsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            detailsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            detailsLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with activity: MonitorActivityViewController.ActivityLog) {
        let roleIcon: String
        switch activity.userRole {
        case "student": roleIcon = "👨‍🎓"
        case "academic_staff": roleIcon = "👨‍🏫"
        case "admin": roleIcon = "👑"
        default: roleIcon = "👤"
        }
        
        userLabel.text = "\(roleIcon) \(activity.userName) (\(activity.userRole.replacingOccurrences(of: "_", with: " ").capitalized))"
        actionLabel.text = activity.action
        detailsLabel.text = activity.details
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        timeLabel.text = formatter.string(from: activity.timestamp)
    }
}