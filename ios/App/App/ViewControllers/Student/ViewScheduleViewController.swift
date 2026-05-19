import UIKit

class ViewScheduleViewController: UIViewController {
    
    // MARK: - UI Components
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No schedule available.\nYour class schedule will appear here once you enroll in courses."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        label.isHidden = true
        return label
    }()
    
    private let daySegmentedControl: UISegmentedControl = {
        let items = ScheduleItem.Weekday.allCases.map { $0.rawValue.prefix(3).uppercased() }
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    // MARK: - Properties
    private var allScheduleItems: [ScheduleItem] = []
    private var filteredScheduleItems: [ScheduleItem] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupActions()
        loadSchedule()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "My Schedule"
        
        [daySegmentedControl, tableView, activityIndicator, emptyStateLabel].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        activityIndicator.hidesWhenStopped = true
        
        NSLayoutConstraint.activate([
            daySegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            daySegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            daySegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: daySegmentedControl.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
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
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: "ScheduleCell")
        tableView.separatorStyle = .none
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupActions() {
        daySegmentedControl.addTarget(self, action: #selector(dayChanged), for: .valueChanged)
    }
    
    @objc private func dayChanged() {
        let selectedDay = ScheduleItem.Weekday.allCases[daySegmentedControl.selectedSegmentIndex]
        filteredScheduleItems = allScheduleItems.filter { $0.day == selectedDay }
            .sorted { $0.startTime < $1.startTime }
        tableView.reloadData()
        emptyStateLabel.isHidden = !filteredScheduleItems.isEmpty
    }
    
    // MARK: - Data Loading
    private func loadSchedule() {
        guard let studentId = FirebaseService.shared.getCurrentUserId() else { return }
        
        activityIndicator.startAnimating()
        
        FirebaseService.shared.fetchMySchedule(studentId: studentId) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.refreshControl.endRefreshing()
                
                switch result {
                case .success(let schedule):
                    self?.allScheduleItems = schedule
                    self?.dayChanged() // This will filter and display
                    self?.emptyStateLabel.isHidden = !(self?.filteredScheduleItems.isEmpty ?? true)
                case .failure(let error):
                    print("Error loading schedule: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func refreshData() {
        loadSchedule()
    }
}

// MARK: - TableView Delegates
extension ViewScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredScheduleItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! ScheduleCell
        let item = filteredScheduleItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = filteredScheduleItems[indexPath.row]
        
        let detailVC = ScheduleDetailViewController(scheduleItem: item)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - Schedule Cell
class ScheduleCell: UITableViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemBlue
        return label
    }()
    
    private let courseNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let courseCodeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let roomLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemOrange
        return label
    }()
    
    private let instructorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
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
        
        [timeLabel, courseNameLabel, courseCodeLabel, roomLabel, instructorLabel].forEach {
            containerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            timeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            timeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            courseNameLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4),
            courseNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            courseNameLabel.trailingAnchor.constraint(equalTo: roomLabel.leadingAnchor, constant: -8),
            
            roomLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4),
            roomLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            courseCodeLabel.topAnchor.constraint(equalTo: courseNameLabel.bottomAnchor, constant: 4),
            courseCodeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            instructorLabel.topAnchor.constraint(equalTo: courseCodeLabel.bottomAnchor, constant: 4),
            instructorLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            instructorLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with item: ScheduleItem) {
        timeLabel.text = item.timeRange
        courseNameLabel.text = item.courseName
        courseCodeLabel.text = item.courseCode
        roomLabel.text = "📍 \(item.room)"
        instructorLabel.text = "👨‍🏫 \(item.instructor)"
    }
}