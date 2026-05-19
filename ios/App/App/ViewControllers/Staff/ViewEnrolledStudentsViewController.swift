import UIKit

class ViewEnrolledStudentsViewController: UIViewController {
    
    // MARK: - UI Components
    private let coursePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = .systemGray6
        picker.layer.cornerRadius = 8
        return picker
    }()
    
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No students enrolled in this course."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        label.isHidden = true
        return label
    }()
    
    // MARK: - Properties
    var staffCourses: [Course] = []
    private var selectedCourseIndex = 0
    private var enrolledStudents: [EnrolledStudent] = []
    
    struct EnrolledStudent {
        let id: String
        let name: String
        let email: String
        let enrollmentDate: Date
        var grade: Double?
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupActions()
        loadStudents()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Enrolled Students"
        
        [coursePicker, tableView, activityIndicator, emptyStateLabel].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        coursePicker.delegate = self
        coursePicker.dataSource = self
        
        activityIndicator.hidesWhenStopped = true
        
        NSLayoutConstraint.activate([
            coursePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            coursePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            coursePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            coursePicker.heightAnchor.constraint(equalToConstant: 120),
            
            tableView.topAnchor.constraint(equalTo: coursePicker.bottomAnchor, constant: 16),
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
        tableView.register(StudentCell.self, forCellReuseIdentifier: "StudentCell")
        tableView.separatorStyle = .none
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupActions() {
        coursePicker.addTarget(self, action: #selector(courseChanged), for: .valueChanged)
    }
    
    @objc private func courseChanged() {
        loadStudents()
    }
    
    @objc private func refreshData() {
        loadStudents()
    }
    
    // MARK: - Data Loading
    private func loadStudents() {
        guard staffCourses.indices.contains(selectedCourseIndex) else {
            enrolledStudents = []
            tableView.reloadData()
            return
        }
        
        let course = staffCourses[selectedCourseIndex]
        
        activityIndicator.startAnimating()
        
        FirebaseService.shared.db.collection("enrollments")
            .whereField("courseId", isEqualTo: course.id)
            .whereField("status", isEqualTo: "active")
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.refreshControl.endRefreshing()
                    
                    if let error = error {
                        self?.showAlert(message: "Failed to load students: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        self?.enrolledStudents = []
                        self?.tableView.reloadData()
                        return
                    }
                    
                    self?.enrolledStudents = documents.compactMap { doc in
                        let data = doc.data()
                        guard let studentId = data["studentId"] as? String,
                              let studentName = data["studentName"] as? String,
                              let email = data["email"] as? String else {
                            return nil
                        }
                        
                        return EnrolledStudent(
                            id: studentId,
                            name: studentName,
                            email: email,
                            enrollmentDate: (data["enrolledAt"] as? Timestamp)?.dateValue() ?? Date(),
                            grade: data["grade"] as? Double
                        )
                    }
                    
                    self?.tableView.reloadData()
                    self?.emptyStateLabel.isHidden = !(self?.enrolledStudents.isEmpty ?? true)
                }
            }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func updateGrade(for student: EnrolledStudent, at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Update Grade", message: "Enter grade for \(student.name)", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Grade (0-100)"
            textField.keyboardType = .decimalPad
            textField.text = student.grade.map { "\($0)" }
        }
        
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let gradeText = alert.textFields?.first?.text,
                  let grade = Double(gradeText), grade >= 0 && grade <= 100 else {
                self?.showAlert(message: "Please enter a valid grade between 0 and 100")
                return
            }
            
            self?.saveGrade(studentId: student.id, courseId: self?.staffCourses[self?.selectedCourseIndex ?? 0].id ?? "", grade: grade)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func saveGrade(studentId: String, courseId: String, grade: Double) {
        activityIndicator.startAnimating()
        
        FirebaseService.shared.db.collection("enrollments")
            .whereField("studentId", isEqualTo: studentId)
            .whereField("courseId", isEqualTo: courseId)
            .getDocuments { [weak self] snapshot, _ in
                guard let document = snapshot?.documents.first else {
                    DispatchQueue.main.async {
                        self?.activityIndicator.stopAnimating()
                        self?.showAlert(message: "Enrollment record not found")
                    }
                    return
                }
                
                document.reference.updateData(["grade": grade]) { error in
                    DispatchQueue.main.async {
                        self?.activityIndicator.stopAnimating()
                        
                        if let error = error {
                            self?.showAlert(message: "Failed to update grade: \(error.localizedDescription)")
                        } else {
                            self?.loadStudents() // Refresh the list
                        }
                    }
                }
            }
    }
}

// MARK: - UIPickerView Delegate
extension ViewEnrolledStudentsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return staffCourses.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return staffCourses[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCourseIndex = row
        loadStudents()
    }
}

// MARK: - TableView Delegates
extension ViewEnrolledStudentsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return enrolledStudents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath) as! StudentCell
        let student = enrolledStudents[indexPath.row]
        cell.configure(with: student)
        cell.onGradeTapped = { [weak self] in
            self?.updateGrade(for: student, at: indexPath)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - Student Cell
class StudentCell: UITableViewCell {
    
    var onGradeTapped: (() -> Void)?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let gradeButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.layer.cornerRadius = 15
        button.backgroundColor = .systemGreen
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
        
        [nameLabel, emailLabel, gradeButton].forEach {
            containerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: gradeButton.leadingAnchor, constant: -8),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            emailLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            gradeButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            gradeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            gradeButton.widthAnchor.constraint(equalToConstant: 60),
            gradeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupActions() {
        gradeButton.addTarget(self, action: #selector(gradeTapped), for: .touchUpInside)
    }
    
    @objc private func gradeTapped() {
        onGradeTapped?()
    }
    
    func configure(with student: ViewEnrolledStudentsViewController.EnrolledStudent) {
        nameLabel.text = student.name
        emailLabel.text = student.email
        
        if let grade = student.grade {
            gradeButton.setTitle("\(Int(grade))%", for: .normal)
            gradeButton.backgroundColor = .systemBlue
        } else {
            gradeButton.setTitle("Set Grade", for: .normal)
            gradeButton.backgroundColor = .systemGreen
        }
    }
}