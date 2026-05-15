import UIKit

class ViewGradesViewController: UIViewController {
    
    // MARK: - UI Components
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No grades available yet.\nGrades will appear here once instructors publish them."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        label.isHidden = true
        return label
    }()
    
    private let summaryCard: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private let gpaLabel: UILabel = {
        let label = UILabel()
        label.text = "Cumulative GPA"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.8)
        return label
    }()
    
    private let gpaValueLabel: UILabel = {
        let label = UILabel()
        label.text = "0.00"
        label.font = .systemFont(ofSize: 40, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let totalCreditsLabel: UILabel = {
        let label = UILabel()
        label.text = "0 credits"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.8)
        return label
    }()
    
    private let semesterLabel: UILabel = {
        let label = UILabel()
        label.text = "Current Semester"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    // MARK: - Properties
    private var grades: [Grade] = []
    private var groupedBySemester: [String: [Grade]] = [:]
    private var semesters: [String] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupActions()
        loadGrades()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "My Grades"
        
        [summaryCard, semesterLabel, tableView, activityIndicator, emptyStateLabel].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [gpaLabel, gpaValueLabel, totalCreditsLabel].forEach {
            summaryCard.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        activityIndicator.hidesWhenStopped = true
        
        NSLayoutConstraint.activate([
            summaryCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            summaryCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            summaryCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            summaryCard.heightAnchor.constraint(equalToConstant: 100),
            
            gpaLabel.topAnchor.constraint(equalTo: summaryCard.topAnchor, constant: 16),
            gpaLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 20),
            
            gpaValueLabel.topAnchor.constraint(equalTo: gpaLabel.bottomAnchor, constant: 4),
            gpaValueLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 20),
            
            totalCreditsLabel.centerYAnchor.constraint(equalTo: summaryCard.centerYAnchor),
            totalCreditsLabel.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -20),
            
            semesterLabel.topAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: 24),
            semesterLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            tableView.topAnchor.constraint(equalTo: semesterLabel.bottomAnchor, constant: 8),
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
        tableView.register(GradeCell.self, forCellReuseIdentifier: "GradeCell")
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "SectionHeader")
        tableView.separatorStyle = .none
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupActions() {
        // Any additional actions
    }
    
    // MARK: - Data Loading
    private func loadGrades() {
        guard let studentId = FirebaseService.shared.getCurrentUserId() else { return }
        
        activityIndicator.startAnimating()
        
        FirebaseService.shared.fetchMyGrades(studentId: studentId) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.refreshControl.endRefreshing()
                
                switch result {
                case .success(let grades):
                    self?.grades = grades
                    self?.groupGradesBySemester()
                    self?.updateSummary()
                    self?.tableView.reloadData()
                    self?.emptyStateLabel.isHidden = !grades.isEmpty
                case .failure(let error):
                    self?.showAlert(message: "Failed to load grades: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func refreshData() {
        loadGrades()
    }
    
    private func groupGradesBySemester() {
        // This is a simplified grouping. In a real app, you'd have semester info in your data
        groupedBySemester = ["Current Semester": grades]
        semesters = ["Current Semester"]
        
        // Add previous semesters if you have that data structure
        // For now, just show all grades in one section
    }
    
    private func updateSummary() {
        let gpa = FirebaseService.shared.calculateGPA(grades: grades)
        gpaValueLabel.text = String(format: "%.2f", gpa)
        
        let totalCredits = grades.reduce(0) { $0 + $1.credits }
        totalCreditsLabel.text = "\(totalCredits) total credits"
        
        // Update GPA color
        switch gpa {
        case 3.5...4.0:
            summaryCard.backgroundColor = .systemGreen
        case 3.0..<3.5:
            summaryCard.backgroundColor = .systemBlue
        case 2.0..<3.0:
            summaryCard.backgroundColor = .systemOrange
        default:
            summaryCard.backgroundColor = .systemRed
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showGradeDetail(_ grade: Grade) {
        let detailVC = GradeDetailViewController(grade: grade)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - TableView Delegates
extension ViewGradesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return semesters.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let semester = semesters[section]
        return groupedBySemester[semester]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GradeCell", for: indexPath) as! GradeCell
        
        let semester = semesters[indexPath.section]
        if let grade = groupedBySemester[semester]?[indexPath.row] {
            cell.configure(with: grade)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeader")
        var config = header?.defaultContentConfiguration()
        config?.text = semesters[section]
        config?.textProperties.font = .systemFont(ofSize: 16, weight: .bold)
        config?.textProperties.color = .label
        header?.contentConfiguration = config
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let semester = semesters[indexPath.section]
        if let grade = groupedBySemester[semester]?[indexPath.row] {
            showGradeDetail(grade)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

// MARK: - Grade Cell
class GradeCell: UITableViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let courseCodeLabel: UILabel = {
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
    
    private let instructorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let gradeContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 25
        return view
    }()
    
    private let letterGradeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
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
        
        [courseCodeLabel, courseNameLabel, instructorLabel, gradeContainer].forEach {
            containerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        gradeContainer.addSubview(letterGradeLabel)
        gradeContainer.addSubview(scoreLabel)
        letterGradeLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            courseCodeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            courseCodeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            courseNameLabel.topAnchor.constraint(equalTo: courseCodeLabel.bottomAnchor, constant: 4),
            courseNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            courseNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: gradeContainer.leadingAnchor, constant: -12),
            
            instructorLabel.topAnchor.constraint(equalTo: courseNameLabel.bottomAnchor, constant: 4),
            instructorLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            instructorLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            gradeContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            gradeContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            gradeContainer.widthAnchor.constraint(equalToConstant: 50),
            gradeContainer.heightAnchor.constraint(equalToConstant: 50),
            
            letterGradeLabel.centerXAnchor.constraint(equalTo: gradeContainer.centerXAnchor),
            letterGradeLabel.topAnchor.constraint(equalTo: gradeContainer.topAnchor, constant: 8),
            
            scoreLabel.centerXAnchor.constraint(equalTo: gradeContainer.centerXAnchor),
            scoreLabel.bottomAnchor.constraint(equalTo: gradeContainer.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with grade: Grade) {
        courseCodeLabel.text = grade.courseCode
        courseNameLabel.text = grade.courseName
        instructorLabel.text = "👨‍🏫 \(grade.instructor)"
        letterGradeLabel.text = grade.letterGrade
        scoreLabel.text = "\(Int(grade.score))%"
        
        // Set color based on grade
        switch grade.letterGrade {
        case "A":
            gradeContainer.backgroundColor = .systemGreen
        case "B":
            gradeContainer.backgroundColor = .systemBlue
        case "C":
            gradeContainer.backgroundColor = .systemOrange
        case "D":
            gradeContainer.backgroundColor = .systemYellow
        default:
            gradeContainer.backgroundColor = .systemRed
        }
    }
}