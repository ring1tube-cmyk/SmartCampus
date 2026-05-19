import UIKit

class StaffDashboardViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let welcomeCard: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome back!"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .white
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let roleBadge: UILabel = {
        let label = UILabel()
        label.text = "Academic Staff"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .systemGreen
        label.backgroundColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        return label
    }()
    
    private let statsCard: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.05
        return view
    }()
    
    private let coursesCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .systemBlue
        label.textAlignment = .center
        return label
    }()
    
    private let coursesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Courses"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let studentsCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .systemGreen
        label.textAlignment = .center
        return label
    }()
    
    private let studentsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Students"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let announcementsCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .systemOrange
        label.textAlignment = .center
        return label
    }()
    
    private let announcementsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sent"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let quickActionsLabel: UILabel = {
        let label = UILabel()
        label.text = "Quick Actions"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private let buttonsGridStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.distribution = .fillEqually
        return sv
    }()
    
    private let firstRowStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 16
        sv.distribution = .fillEqually
        return sv
    }()
    
    private let secondRowStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 16
        sv.distribution = .fillEqually
        return sv
    }()
    
    private let manageCoursesButton = createActionButton(title: "📚 Courses", subtitle: "Manage your courses", color: .systemBlue)
    private let uploadMaterialsButton = createActionButton(title: "📄 Materials", subtitle: "Upload course materials", color: .systemPurple)
    private let sendAnnouncementsButton = createActionButton(title: "📢 Announcements", subtitle: "Send to students", color: .systemOrange)
    private let viewStudentsButton = createActionButton(title: "👥 Students", subtitle: "View enrolled students", color: .systemGreen)
    private let updateProfileButton = createActionButton(title: "👤 Profile", subtitle: "Update your info", color: .systemGray)
    private let logoutButton = createActionButton(title: "🚪 Logout", subtitle: "Sign out", color: .systemRed)
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Properties
    private var currentUser: User?
    private var staffCourses: [Course] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        loadUserData()
        loadStats()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        loadStats()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        [scrollView, activityIndicator].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        [welcomeCard, statsCard, quickActionsLabel, buttonsGridStackView].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [welcomeLabel, nameLabel, roleBadge].forEach {
            welcomeCard.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let statsStack = UIStackView(arrangedSubviews: [
            createStatItem(view: coursesCountLabel, titleLabel: coursesTitleLabel),
            createStatDivider(),
            createStatItem(view: studentsCountLabel, titleLabel: studentsTitleLabel),
            createStatDivider(),
            createStatItem(view: announcementsCountLabel, titleLabel: announcementsTitleLabel)
        ])
        statsStack.axis = .horizontal
        statsStack.distribution = .fillEqually
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        statsCard.addSubview(statsStack)
        
        firstRowStack.addArrangedSubview(manageCoursesButton)
        firstRowStack.addArrangedSubview(uploadMaterialsButton)
        secondRowStack.addArrangedSubview(sendAnnouncementsButton)
        secondRowStack.addArrangedSubview(viewStudentsButton)
        
        buttonsGridStackView.addArrangedSubview(firstRowStack)
        buttonsGridStackView.addArrangedSubview(secondRowStack)
        buttonsGridStackView.addArrangedSubview(updateProfileButton)
        buttonsGridStackView.addArrangedSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            statsStack.topAnchor.constraint(equalTo: statsCard.topAnchor, constant: 16),
            statsStack.leadingAnchor.constraint(equalTo: statsCard.leadingAnchor, constant: 8),
            statsStack.trailingAnchor.constraint(equalTo: statsCard.trailingAnchor, constant: -8),
            statsStack.bottomAnchor.constraint(equalTo: statsCard.bottomAnchor, constant: -16),
            
            updateProfileButton.heightAnchor.constraint(equalToConstant: 70),
            logoutButton.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        activityIndicator.hidesWhenStopped = true
        roleBadge.text = "Academic Staff"
        
        // Add padding to role badge
        roleBadge.layoutMargins = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
    }
    
    private func createStatItem(view: UIView, titleLabel: UILabel) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [view, titleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }
    
    private func createStatDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = .separator
        divider.widthAnchor.constraint(equalToConstant: 1).isActive = true
        return divider
    }
    
    private func setupConstraints() {
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
            
            welcomeCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            welcomeCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            welcomeCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            welcomeCard.heightAnchor.constraint(equalToConstant: 120),
            
            welcomeLabel.topAnchor.constraint(equalTo: welcomeCard.topAnchor, constant: 16),
            welcomeLabel.leadingAnchor.constraint(equalTo: welcomeCard.leadingAnchor, constant: 20),
            
            nameLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: welcomeCard.leadingAnchor, constant: 20),
            
            roleBadge.topAnchor.constraint(equalTo: welcomeCard.topAnchor, constant: 16),
            roleBadge.trailingAnchor.constraint(equalTo: welcomeCard.trailingAnchor, constant: -20),
            roleBadge.widthAnchor.constraint(equalToConstant: 120),
            roleBadge.heightAnchor.constraint(equalToConstant: 28),
            
            statsCard.topAnchor.constraint(equalTo: welcomeCard.bottomAnchor, constant: 16),
            statsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            statsCard.heightAnchor.constraint(equalToConstant: 100),
            
            quickActionsLabel.topAnchor.constraint(equalTo: statsCard.bottomAnchor, constant: 24),
            quickActionsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            buttonsGridStackView.topAnchor.constraint(equalTo: quickActionsLabel.bottomAnchor, constant: 16),
            buttonsGridStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonsGridStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonsGridStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        manageCoursesButton.addTarget(self, action: #selector(showManageCourses), for: .touchUpInside)
        uploadMaterialsButton.addTarget(self, action: #selector(showUploadMaterials), for: .touchUpInside)
        sendAnnouncementsButton.addTarget(self, action: #selector(showSendAnnouncements), for: .touchUpInside)
        viewStudentsButton.addTarget(self, action: #selector(showViewStudents), for: .touchUpInside)
        updateProfileButton.addTarget(self, action: #selector(updateProfile), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
    }
    
    private static func createActionButton(title: String, subtitle: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = color
        button.layer.cornerRadius = 12
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .white
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = .white.withAlphaComponent(0.8)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        
        button.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        return button
    }
    
    // MARK: - Data Loading
    private func loadUserData() {
        guard let userId = FirebaseService.shared.getCurrentUserId() else { return }
        
        activityIndicator.startAnimating()
        
        FirebaseService.shared.fetchUser(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let user):
                    self?.currentUser = user
                    self?.nameLabel.text = user.name.components(separatedBy: " ").first ?? user.name
                case .failure(let error):
                    print("Error loading user: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func loadStats() {
        guard let staffId = FirebaseService.shared.getCurrentUserId() else { return }
        
        // Load staff courses
        FirebaseService.shared.db.collection("courses")
            .whereField("instructorId", isEqualTo: staffId)
            .getDocuments { [weak self] snapshot, _ in
                let courses = snapshot?.documents.compactMap { Course(document: $0) } ?? []
                self?.staffCourses = courses
                DispatchQueue.main.async {
                    self?.coursesCountLabel.text = "\(courses.count)"
                }
                
                // Load total students enrolled in staff's courses
                self?.loadTotalStudents()
            }
        
        // Load announcements count
        FirebaseService.shared.db.collection("announcements")
            .whereField("senderId", isEqualTo: staffId)
            .getDocuments { [weak self] snapshot, _ in
                let count = snapshot?.documents.count ?? 0
                DispatchQueue.main.async {
                    self?.announcementsCountLabel.text = "\(count)"
                }
            }
    }
    
    private func loadTotalStudents() {
        guard !staffCourses.isEmpty else { return }
        
        let courseIds = staffCourses.map { $0.id }
        
        FirebaseService.shared.db.collection("enrollments")
            .whereField("courseId", in: courseIds)
            .whereField("status", isEqualTo: "active")
            .getDocuments { [weak self] snapshot, _ in
                let uniqueStudents = Set(snapshot?.documents.compactMap { $0.data()["studentId"] as? String } ?? [])
                DispatchQueue.main.async {
                    self?.studentsCountLabel.text = "\(uniqueStudents.count)"
                }
            }
    }
    
    // MARK: - Navigation Actions
    @objc private func showManageCourses() {
        let coursesVC = ManageCourseViewController()
        coursesVC.staffId = FirebaseService.shared.getCurrentUserId()
        navigationController?.pushViewController(coursesVC, animated: true)
    }
    
    @objc private func showUploadMaterials() {
        let uploadVC = UploadMaterialsViewController()
        uploadVC.staffCourses = staffCourses
        navigationController?.pushViewController(uploadVC, animated: true)
    }
    
    @objc private func showSendAnnouncements() {
        let announcementsVC = SendAnnouncementsViewController()
        announcementsVC.staffId = FirebaseService.shared.getCurrentUserId()
        announcementsVC.staffName = currentUser?.name ?? "Staff"
        navigationController?.pushViewController(announcementsVC, animated: true)
    }
    
    @objc private func showViewStudents() {
        let studentsVC = ViewEnrolledStudentsViewController()
        studentsVC.staffCourses = staffCourses
        navigationController?.pushViewController(studentsVC, animated: true)
    }
    
    @objc private func updateProfile() {
        let profileVC = UpdateProfileViewController()
        profileVC.user = currentUser
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @objc private func handleLogout() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { _ in
            do {
                try FirebaseService.shared.logout()
                if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                    sceneDelegate.window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
                    sceneDelegate.window?.makeKeyAndVisible()
                }
            } catch {
                self.showAlert(message: "Logout failed: \(error.localizedDescription)")
            }
        })
        present(alert, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}