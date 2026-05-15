import UIKit

class CourseDetailViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        return view
    }()
    
    private let courseCodeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.8)
        return label
    }()
    
    private let courseNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let creditsBadge: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.layer.cornerRadius = 12
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let detailsCard: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.05
        return view
    }()
    
    private let instructorLabel = createDetailLabel(icon: "👨‍🏫", title: "Instructor")
    private let scheduleLabel = createDetailLabel(icon: "📅", title: "Schedule")
    private let roomLabel = createDetailLabel(icon: "📍", title: "Room")
    private let departmentLabel = createDetailLabel(icon: "🏛️", title: "Department")
    private let capacityLabel = createDetailLabel(icon: "👥", title: "Capacity")
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 12
        return button
    }()
    
    // MARK: - Properties
    private let course: Course
    private let isEnrolled: Bool
    
    // MARK: - Initializer
    init(course: Course, isEnrolled: Bool = false) {
        self.course = course
        self.isEnrolled = isEnrolled
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
        setupActions()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Course Details"
        
        [scrollView, headerView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        [courseCodeLabel, courseNameLabel, creditsBadge].forEach {
            headerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [detailsCard, descriptionLabel, actionButton].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [instructorLabel, scheduleLabel, roomLabel, departmentLabel, capacityLabel].forEach {
            detailsCard.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 180),
            
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            courseCodeLabel.topAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.topAnchor, constant: 16),
            courseCodeLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            
            creditsBadge.topAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.topAnchor, constant: 16),
            creditsBadge.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            creditsBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            creditsBadge.heightAnchor.constraint(equalToConstant: 28),
            
            courseNameLabel.topAnchor.constraint(equalTo: courseCodeLabel.bottomAnchor, constant: 8),
            courseNameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            courseNameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            detailsCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -20),
            detailsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            instructorLabel.topAnchor.constraint(equalTo: detailsCard.topAnchor, constant: 16),
            instructorLabel.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 16),
            instructorLabel.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor, constant: -16),
            
            scheduleLabel.topAnchor.constraint(equalTo: instructorLabel.bottomAnchor, constant: 12),
            scheduleLabel.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 16),
            scheduleLabel.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor, constant: -16),
            
            roomLabel.topAnchor.constraint(equalTo: scheduleLabel.bottomAnchor, constant: 12),
            roomLabel.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 16),
            roomLabel.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor, constant: -16),
            
            departmentLabel.topAnchor.constraint(equalTo: roomLabel.bottomAnchor, constant: 12),
            departmentLabel.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 16),
            departmentLabel.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor, constant: -16),
            
            capacityLabel.topAnchor.constraint(equalTo: departmentLabel.bottomAnchor, constant: 12),
            capacityLabel.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 16),
            capacityLabel.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor, constant: -16),
            capacityLabel.bottomAnchor.constraint(equalTo: detailsCard.bottomAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: detailsCard.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            actionButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            actionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            actionButton.heightAnchor.constraint(equalToConstant: 50),
            actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
        
        // Style action button
        actionButton.layer.cornerRadius = 12
    }
    
    private func populateData() {
        courseCodeLabel.text = course.code
        courseNameLabel.text = course.name
        creditsBadge.setTitle("\(course.credits) Credits", for: .normal)
        
        instructorLabel.valueLabel.text = course.instructor
        scheduleLabel.valueLabel.text = course.schedule ?? "TBD"
        roomLabel.valueLabel.text = course.room ?? "TBD"
        departmentLabel.valueLabel.text = course.department
        capacityLabel.valueLabel.text = "\(course.enrolledCount)/\(course.capacity) enrolled"
        descriptionLabel.text = course.description ?? "No description available."
        
        updateActionButton()
    }
    
    private func updateActionButton() {
        if isEnrolled {
            actionButton.setTitle("Withdraw from Course", for: .normal)
            actionButton.backgroundColor = .systemRed
            actionButton.setTitleColor(.white, for: .normal)
        } else {
            actionButton.setTitle("Enroll in Course", for: .normal)
            actionButton.backgroundColor = .systemGreen
            actionButton.setTitleColor(.white, for: .normal)
        }
    }
    
    private func setupActions() {
        actionButton.addTarget(self, action: #selector(handleAction), for: .touchUpInside)
    }
    
    @objc private func handleAction() {
        if isEnrolled {
            withdrawFromCourse()
        } else {
            enrollInCourse()
        }
    }
    
    private func enrollInCourse() {
        guard let studentId = FirebaseService.shared.getCurrentUserId(),
              let currentUser = Auth.auth().currentUser else { return }
        
        let alert = UIAlertController(title: "Enroll in \(course.name)", message: "Are you sure you want to enroll in this course?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Enroll", style: .default) { [weak self] _ in
            self?.performEnrollment(studentId: studentId, studentName: currentUser.displayName ?? "Student")
        })
        present(alert, animated: true)
    }
    
    private func performEnrollment(studentId: String, studentName: String) {
        showLoading(true)
        
        FirebaseService.shared.enrollInCourse(
            courseId: course.id,
            courseName: course.name,
            courseCode: course.code,
            studentId: studentId,
            studentName: studentName
        ) { [weak self] error in
            DispatchQueue.main.async {
                self?.showLoading(false)
                
                if let error = error {
                    self?.showAlert(message: "Enrollment failed: \(error.localizedDescription)")
                } else {
                    self?.showAlert(message: "Successfully enrolled in \(self?.course.name ?? "course")!")
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    private func withdrawFromCourse() {
        let alert = UIAlertController(title: "Withdraw from \(course.name)", message: "Are you sure you want to withdraw? This action cannot be undone.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Withdraw", style: .destructive) { [weak self] _ in
            self?.performWithdrawal()
        })
        present(alert, animated: true)
    }
    
    private func performWithdrawal() {
        // First, find the enrollment ID for this course
        guard let studentId = FirebaseService.shared.getCurrentUserId() else { return }
        
        showLoading(true)
        
        FirebaseService.shared.db.collection("enrollments")
            .whereField("studentId", isEqualTo: studentId)
            .whereField("courseId", isEqualTo: course.id)
            .whereField("status", isEqualTo: "active")
            .getDocuments { [weak self] snapshot, error in
                guard let doc = snapshot?.documents.first else {
                    DispatchQueue.main.async {
                        self?.showLoading(false)
                        self?.showAlert(message: "Enrollment record not found.")
                    }
                    return
                }
                
                let enrollmentId = doc.documentID
                
                FirebaseService.shared.withdrawFromCourse(enrollmentId: enrollmentId, courseId: self?.course.id ?? "") { error in
                    DispatchQueue.main.async {
                        self?.showLoading(false)
                        
                        if let error = error {
                            self?.showAlert(message: "Withdrawal failed: \(error.localizedDescription)")
                        } else {
                            self?.showAlert(message: "Successfully withdrawn from course.")
                            self?.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
    }
    
    private func showLoading(_ isLoading: Bool) {
        actionButton.isEnabled = !isLoading
        if isLoading {
            actionButton.setTitle("Processing...", for: .normal)
        } else {
            updateActionButton()
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private static func createDetailLabel(icon: String, title: String) -> DetailLabelView {
        let view = DetailLabelView()
        view.iconLabel.text = icon
        view.titleLabel.text = title
        return view
    }
}

// MARK: - Detail Label View
class DetailLabelView: UIView {
    
    let iconLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        [iconLabel, titleLabel, valueLabel].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 30),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            
            valueLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 8),
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}