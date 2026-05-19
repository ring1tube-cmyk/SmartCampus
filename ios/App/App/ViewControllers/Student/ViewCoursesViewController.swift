import UIKit

class ViewCoursesViewController: UIViewController {
    
    // MARK: - UI Components
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "You are not enrolled in any courses yet.\nBrowse available courses below!"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        label.isHidden = true
        return label
    }()
    
    private let availableCoursesLabel: UILabel = {
        let label = UILabel()
        label.text = "Available Courses"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private let availableTableView = UITableView()
    
    // MARK: - Properties
    private var myCourses: [Course] = []
    private var availableCourses: [Course] = []
    private var myCourseIds: Set<String> = []
    private var enrollments: [String: String] = [:] // courseId -> enrollmentId
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableViews()
        setupActions()
        loadData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "My Courses"
        
        [tableView, availableCoursesLabel, availableTableView, activityIndicator, emptyStateLabel].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        activityIndicator.hidesWhenStopped = true
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 250),
            
            availableCoursesLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            availableCoursesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            availableTableView.topAnchor.constraint(equalTo: availableCoursesLabel.bottomAnchor, constant: 8),
            availableTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            availableTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            availableTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func setupTableViews() {
        // My Courses TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CourseCell.self, forCellReuseIdentifier: "MyCourseCell")
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "Header")
        
        // Available Courses TableView
        availableTableView.delegate = self
        availableTableView.dataSource = self
        availableTableView.register(CourseCell.self, forCellReuseIdentifier: "AvailableCourseCell")
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        availableTableView.refreshControl = refreshControl
    }
    
    private func setupActions() {
        // Add any button actions here
    }
    
    // MARK: - Data Loading
    private func loadData() {
        guard let studentId = FirebaseService.shared.getCurrentUserId() else { return }
        
        activityIndicator.startAnimating()
        
        let group = DispatchGroup()
        
        // Load enrolled courses
        group.enter()
        FirebaseService.shared.fetchMyEnrolledCourses(studentId: studentId) { [weak self] result in
            defer { group.leave() }
            switch result {
            case .success(let courses):
                self?.myCourses = courses
                self?.myCourseIds = Set(courses.map { $0.id })
            case .failure(let error):
                print("Error loading enrolled courses: \(error.localizedDescription)")
            }
        }
        
        // Load enrollments to get IDs
        group.enter()
        FirebaseService.shared.db.collection("enrollments")
            .whereField("studentId", isEqualTo: studentId)
            .whereField("status", isEqualTo: "active")
            .getDocuments { [weak self] snapshot, _ in
                defer { group.leave() }
                self?.enrollments = [:]
                snapshot?.documents.forEach { doc in
                    if let courseId = doc.data()["courseId"] as? String {
                        self?.enrollments[courseId] = doc.documentID
                    }
                }
            }
        
        // Load available courses
        group.enter()
        FirebaseService.shared.fetchAllAvailableCourses { [weak self] result in
            defer { group.leave() }
            switch result {
            case .success(let courses):
                self?.availableCourses = courses.filter { !(self?.myCourseIds.contains($0.id) ?? false) }
            case .failure(let error):
                print("Error loading available courses: \(error.localizedDescription)")
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.refreshControl.endRefreshing()
            self?.tableView.reloadData()
            self?.availableTableView.reloadData()
            self?.emptyStateLabel.isHidden = !(self?.myCourses.isEmpty ?? true)
        }
    }
    
    @objc private func refreshData() {
        loadData()
    }
    
    // MARK: - Actions
    private func enrollInCourse(_ course: Course) {
        guard let studentId = FirebaseService.shared.getCurrentUserId(),
              let studentName = currentUserName() else { return }
        
        let alert = UIAlertController(title: "Enroll in \(course.name)", message: "Do you want to enroll in this course?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Enroll", style: .default) { [weak self] _ in
            self?.performEnrollment(courseId: course.id, courseName: course.name, courseCode: course.code, studentId: studentId, studentName: studentName)
        })
        present(alert, animated: true)
    }
    
    private func performEnrollment(courseId: String, courseName: String, courseCode: String, studentId: String, studentName: String) {
        activityIndicator.startAnimating()
        
        FirebaseService.shared.enrollInCourse(
            courseId: courseId,
            courseName: courseName,
            courseCode: courseCode,
            studentId: studentId,
            studentName: studentName
        ) { [weak self] error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                if let error = error {
                    self?.showAlert(message: "Enrollment failed: \(error.localizedDescription)")
                } else {
                    self?.showAlert(message: "Successfully enrolled in \(courseName)!")
                    self?.loadData() // Refresh the lists
                }
            }
        }
    }
    
    private func withdrawFromCourse(_ course: Course) {
        guard let enrollmentId = enrollments[course.id] else { return }
        
        let alert = UIAlertController(title: "Withdraw from \(course.name)", message: "Are you sure you want to withdraw? This action cannot be undone.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Withdraw", style: .destructive) { [weak self] _ in
            self?.performWithdrawal(enrollmentId: enrollmentId, courseId: course.id)
        })
        present(alert, animated: true)
    }
    
    private func performWithdrawal(enrollmentId: String, courseId: String) {
        activityIndicator.startAnimating()
        
        FirebaseService.shared.withdrawFromCourse(enrollmentId: enrollmentId, courseId: courseId) { [weak self] error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                if let error = error {
                    self?.showAlert(message: "Withdrawal failed: \(error.localizedDescription)")
                } else {
                    self?.showAlert(message: "Successfully withdrawn from course.")
                    self?.loadData()
                }
            }
        }
    }
    
    private func currentUserName() -> String? {
        return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController?.navigationController?.viewControllers.first?.title
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showCourseDetail(_ course: Course) {
        let detailVC = CourseDetailViewController(course: course, isEnrolled: myCourseIds.contains(course.id))
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - TableView Delegates
extension ViewCoursesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableView {
            return 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return myCourses.count
        } else {
            return availableCourses.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableView == self.tableView ? "MyCourseCell" : "AvailableCourseCell", for: indexPath) as! CourseCell
        
        let course = tableView == self.tableView ? myCourses[indexPath.row] : availableCourses[indexPath.row]
        cell.configure(with: course)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let course = tableView == self.tableView ? myCourses[indexPath.row] : availableCourses[indexPath.row]
        showCourseDetail(course)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if tableView == self.tableView {
            let course = myCourses[indexPath.row]
            let withdrawAction = UIContextualAction(style: .destructive, title: "Withdraw") { [weak self] _, _, completion in
                self?.withdrawFromCourse(course)
                completion(true)
            }
            withdrawAction.backgroundColor = .systemRed
            return UISwipeActionsConfiguration(actions: [withdrawAction])
        } else {
            let course = availableCourses[indexPath.row]
            let enrollAction = UIContextualAction(style: .normal, title: "Enroll") { [weak self] _, _, completion in
                self?.enrollInCourse(course)
                completion(true)
            }
            enrollAction.backgroundColor = .systemGreen
            return UISwipeActionsConfiguration(actions: [enrollAction])
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == self.tableView {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header")
            var config = header?.defaultContentConfiguration()
            config?.text = "My Enrolled Courses (\(myCourses.count))"
            config?.textProperties.font = .systemFont(ofSize: 16, weight: .semibold)
            header?.contentConfiguration = config
            return header
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.tableView {
            return 40
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - Course Cell
class CourseCell: UITableViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let codeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemBlue
        return label
    }()
    
    private let nameLabel: UILabel = {
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
    
    private let creditsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemOrange
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
        
        [codeLabel, nameLabel, instructorLabel, creditsLabel].forEach {
            containerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            codeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            codeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            creditsLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            creditsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            nameLabel.topAnchor.constraint(equalTo: codeLabel.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: creditsLabel.leadingAnchor, constant: -8),
            
            instructorLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            instructorLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            instructorLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with course: Course) {
        codeLabel.text = course.code
        nameLabel.text = course.name
        instructorLabel.text = "👨‍🏫 \(course.instructor)"
        creditsLabel.text = "\(course.credits) credits"
    }
}