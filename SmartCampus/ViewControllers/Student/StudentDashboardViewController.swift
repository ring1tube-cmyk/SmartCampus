import UIKit

class StudentDashboardViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let welcomeCard: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
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
        label.text = "Student"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .systemBlue
        label.backgroundColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        return label
    }()
    
    private let gpaCard: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.05
        return view
    }()
    
    private let gpaLabel: UILabel = {
        let label = UILabel()
        label.text = "Current GPA"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let gpaValueLabel: UILabel = {
        let label = UILabel()
        label.text = "0.00"
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.textColor = .systemGreen
        return label
    }()
    
    private let creditsLabel: UILabel = {
        let label = UILabel()
        label.text = "0 credits completed"
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let quickActionsLabel: UILabel = {
        let label = UILabel()
        label.text = "Quick Actions"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private let buttonsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 16
        return sv
    }()
    
    private let viewCoursesButton = createActionButton(title: "📚 Courses", color: .systemBlue)
    private let viewGradesButton = createActionButton(title: "📊 Grades", color: .systemGreen)
    private let viewScheduleButton = createActionButton(title: "📅 Schedule", color: .systemOrange)
    private let announcementsButton = createActionButton(title: "📢 News", color: .systemPurple)
    
    private let profileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("👤 Update Profile", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 12
        return button
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🚪 Logout", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 12
        return button
    }()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Properties
    private var currentUser: User?
    private var grades: [Grade] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        loadUserData()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        loadGPA()
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
        
        [welcomeCard, quickActionsLabel, buttonsStackView, profileButton, logoutButton].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [welcomeLabel, nameLabel, roleBadge, gpaCard].forEach {
            welcomeCard.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [gpaLabel, gpaValueLabel, creditsLabel].forEach {
            gpaCard.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [viewCoursesButton, viewGradesButton, viewScheduleButton, announcementsButton].forEach {
            buttonsStackView.addArrangedSubview($0)
        }
        
        activityIndicator.hidesWhenStopped = true
        roleBadge.text = "Student"
        
        // Add padding to role badge
        roleBadge.layoutMargins = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
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
            welcomeCard.heightAnchor.constraint(equalToConstant: 140),
            
            welcomeLabel.topAnchor.constraint(equalTo: welcomeCard.topAnchor, constant: 16),
            welcomeLabel.leadingAnchor.constraint(equalTo: welcomeCard.leadingAnchor, constant: 20),
            
            nameLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: welcomeCard.leadingAnchor, constant: 20),
            
            roleBadge.topAnchor.constraint(equalTo: welcomeCard.topAnchor, constant: 16),
            roleBadge.trailingAnchor.constraint(equalTo: welcomeCard.trailingAnchor, constant: -20),
            roleBadge.widthAnchor.constraint(equalToConstant: 70),
            roleBadge.heightAnchor.constraint(equalToConstant: 28),
            
            gpaCard.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 8),
            gpaCard.trailingAnchor.constraint(equalTo: welcomeCard.trailingAnchor, constant: -16),
            gpaCard.widthAnchor.constraint(equalToConstant: 120),
            gpaCard.heightAnchor.constraint(equalToConstant: 90),
            
            gpaLabel.topAnchor.constraint(equalTo: gpaCard.topAnchor, constant: 12),
            gpaLabel.centerXAnchor.constraint(equalTo: gpaCard.centerXAnchor),
            
            gpaValueLabel.topAnchor.constraint(equalTo: gpaLabel.bottomAnchor, constant: 4),
            gpaValueLabel.centerXAnchor.constraint(equalTo: gpaCard.centerXAnchor),
            
            creditsLabel.topAnchor.constraint(equalTo: gpaValueLabel.bottomAnchor, constant: 4),
            creditsLabel.centerXAnchor.constraint(equalTo: gpaCard.centerXAnchor),
            
            quickActionsLabel.topAnchor.constraint(equalTo: welcomeCard.bottomAnchor, constant: 24),
            quickActionsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            buttonsStackView.topAnchor.constraint(equalTo: quickActionsLabel.bottomAnchor, constant: 12),
            buttonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 80),
            
            profileButton.topAnchor.constraint(equalTo: buttonsStackView.bottomAnchor, constant: 24),
            profileButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            profileButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            profileButton.heightAnchor.constraint(equalToConstant: 50),
            
            logoutButton.topAnchor.constraint(equalTo: profileButton.bottomAnchor, constant: 12),
            logoutButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            logoutButton.heightAnchor.constraint(equalToConstant: 50),
            logoutButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        viewCoursesButton.addTarget(self, action: #selector(showCourses), for: .touchUpInside)
        viewGradesButton.addTarget(self, action: #selector(showGrades), for: .touchUpInside)
        viewScheduleButton.addTarget(self, action: #selector(showSchedule), for: .touchUpInside)
        announcementsButton.addTarget(self, action: #selector(showAnnouncements), for: .touchUpInside)
        profileButton.addTarget(self, action: #selector(updateProfile), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
    }
    
    private static func createActionButton(title: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
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
    
    private func loadGPA() {
        guard let userId = FirebaseService.shared.getCurrentUserId() else { return }
        
        FirebaseService.shared.fetchMyGrades(studentId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let grades):
                    self?.grades = grades
                    let gpa = FirebaseService.shared.calculateGPA(grades: grades)
                    self?.gpaValueLabel.text = String(format: "%.2f", gpa)
                    
                    let totalCredits = grades.reduce(0) { $0 + $1.credits }
                    self?.creditsLabel.text = "\(totalCredits) credits"
                    
                    self?.updateGPAColor(gpa: gpa)
                case .failure(let error):
                    print("Error loading grades: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateGPAColor(gpa: Double) {
        switch gpa {
        case 3.5...4.0:
            gpaValueLabel.textColor = .systemGreen
        case 3.0..<3.5:
            gpaValueLabel.textColor = .systemBlue
        case 2.0..<3.0:
            gpaValueLabel.textColor = .systemOrange
        default:
            gpaValueLabel.textColor = .systemRed
        }
    }
    
    // MARK: - Navigation Actions
    @objc private func showCourses() {
        let coursesVC = ViewCoursesViewController()
        navigationController?.pushViewController(coursesVC, animated: true)
    }
    
    @objc private func showGrades() {
        let gradesVC = ViewGradesViewController()
        navigationController?.pushViewController(gradesVC, animated: true)
    }
    
    @objc private func showSchedule() {
        let scheduleVC = ViewScheduleViewController()
        navigationController?.pushViewController(scheduleVC, animated: true)
    }
    
    @objc private func showAnnouncements() {
        let announcementsVC = StudentAnnouncementsViewController()
        navigationController?.pushViewController(announcementsVC, animated: true)
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