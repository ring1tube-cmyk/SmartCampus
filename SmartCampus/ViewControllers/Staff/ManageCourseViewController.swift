import UIKit

class ManageCourseViewController: UIViewController {
    
    // MARK: - UI Components
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No courses found.\nTap + to create your first course."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        label.isHidden = true
        return label
    }()
    
    private let addButton: UIBarButtonItem!
    
    // MARK: - Properties
    var staffId: String?
    private var courses: [Course] = []
    
    // MARK: - Initializer
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        self.addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupActions()
        loadCourses()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "My Courses"
        
        navigationItem.rightBarButtonItem = addButton
        
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
        tableView.register(CourseManagementCell.self, forCellReuseIdentifier: "CourseCell")
        tableView.separatorStyle = .none
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupActions() {
        addButton.target = self
        addButton.action = #selector(addCourseTapped)
    }
    
    // MARK: - Data Loading
    private func loadCourses() {
        guard let staffId = staffId else { return }
        
        activityIndicator.startAnimating()
        
        FirebaseService.shared.db.collection("courses")
            .whereField("instructorId", isEqualTo: staffId)
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.refreshControl.endRefreshing()
                    
                    if let error = error {
                        self?.showAlert(message: "Failed to load courses: \(error.localizedDescription)")
                        return
                    }
                    
                    self?.courses = snapshot?.documents.compactMap { Course(document: $0) } ?? []
                    self?.tableView.reloadData()
                    self?.emptyStateLabel.isHidden = !(self?.courses.isEmpty ?? true)
                }
            }
    }
    
    @objc private func refreshData() {
        loadCourses()
    }
    
    // MARK: - Actions
    @objc private func addCourseTapped() {
        showCourseForm()
    }
    
    private func showCourseForm(course: Course? = nil) {
        let alert = UIAlertController(title: course == nil ? "Add Course" : "Edit Course", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Course Name"
            textField.text = course?.name
        }
        alert.addTextField { textField in
            textField.placeholder = "Course Code"
            textField.text = course?.code
        }
        alert.addTextField { textField in
            textField.placeholder = "Credits"
            textField.keyboardType = .numberPad
            textField.text = course.map { "\($0.credits)" }
        }
        alert.addTextField { textField in
            textField.placeholder = "Department"
            textField.text = course?.department
        }
        alert.addTextField { textField in
            textField.placeholder = "Schedule (e.g., Monday 10:00 AM - 12:00 PM)"
            textField.text = course?.schedule
        }
        alert.addTextField { textField in
            textField.placeholder = "Room"
            textField.text = course?.room
        }
        alert.addTextField { textField in
            textField.placeholder = "Description (optional)"
            textField.text = course?.description
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let name = alert.textFields?[0].text, !name.isEmpty,
                  let code = alert.textFields?[1].text, !code.isEmpty,
                  let creditsText = alert.textFields?[2].text,
                  let credits = Int(creditsText),
                  let department = alert.textFields?[3].text,
                  let schedule = alert.textFields?[4].text,
                  let room = alert.textFields?[5].text,
                  let description = alert.textFields?[6].text,
                  let staffId = self?.staffId,
                  let staffName = self?.getStaffName() else {
                self?.showAlert(message: "Please fill in all required fields")
                return
            }
            
            let newCourse = Course(
                id: course?.id ?? UUID().uuidString,
                name: name,
                code: code,
                instructor: staffName,
                instructorId: staffId,
                credits: credits,
                description: description.isEmpty ? nil : description,
                department: department,
                schedule: schedule.isEmpty ? nil : schedule,
                room: room.isEmpty ? nil : room
            )
            
            if let existingCourse = course {
                self?.updateCourse(existingCourse.id, with: newCourse)
            } else {
                self?.saveCourse(newCourse)
            }
        }
        
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func getStaffName() -> String? {
        // Get from current user
        return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?
            .window?.rootViewController?.navigationController?.viewControllers.first?.title
    }
    
    private func saveCourse(_ course: Course) {
        activityIndicator.startAnimating()
        
        FirebaseService.shared.addCourse(course) { [weak self] error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                if let error = error {
                    self?.showAlert(message: "Failed to save course: \(error.localizedDescription)")
                } else {
                    self?.loadCourses()
                }
            }
        }
    }
    
    private func updateCourse(_ courseId: String, with course: Course) {
        activityIndicator.startAnimating()
        
        FirebaseService.shared.updateCourse(courseId: courseId, data: course.toDictionary()) { [weak self] error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                if let error = error {
                    self?.showAlert(message: "Failed to update course: \(error.localizedDescription)")
                } else {
                    self?.loadCourses()
                }
            }
        }
    }
    
    private func deleteCourse(_ course: Course) {
        let alert = UIAlertController(title: "Delete Course", message: "Are you sure you want to delete \"\(course.name)\"? This action cannot be undone.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.performDelete(course)
        })
        present(alert, animated: true)
    }
    
    private func performDelete(_ course: Course) {
        activityIndicator.startAnimating()
        
        FirebaseService.shared.deleteCourse(courseId: course.id) { [weak self] error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                if let error = error {
                    self?.showAlert(message: "Failed to delete course: \(error.localizedDescription)")
                } else {
                    self?.loadCourses()
                }
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - TableView Delegates
extension ManageCourseViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) as! CourseManagementCell
        let course = courses[indexPath.row]
        cell.configure(with: course)
        cell.onEdit = { [weak self] in
            self?.showCourseForm(course: course)
        }
        cell.onDelete = { [weak self] in
            self?.deleteCourse(course)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

// MARK: - Course Management Cell
class CourseManagementCell: UITableViewCell {
    
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?
    
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
    
    private let detailsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        return button
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        [codeLabel, nameLabel, detailsLabel, editButton, deleteButton].forEach {
            containerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            codeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            codeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            nameLabel.topAnchor.constraint(equalTo: codeLabel.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: editButton.leadingAnchor, constant: -8),
            
            detailsLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            detailsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            detailsLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            editButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -12),
            editButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            editButton.widthAnchor.constraint(equalToConstant: 50),
            
            deleteButton.topAnchor.constraint(equalTo: editButton.bottomAnchor, constant: 8),
            deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            deleteButton.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupActions() {
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }
    
    @objc private func editTapped() {
        onEdit?()
    }
    
    @objc private func deleteTapped() {
        onDelete?()
    }
    
    func configure(with course: Course) {
        codeLabel.text = course.code
        nameLabel.text = course.name
        detailsLabel.text = "\(course.credits) credits • \(course.department)"
    }
}