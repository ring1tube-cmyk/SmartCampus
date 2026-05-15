import UIKit

class AdminDashboardViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let welcomeCard: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome back,"
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
        label.text = "Administrator"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .systemRed
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
    
    private let usersCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .systemBlue
        label.textAlignment = .center
        return label
    }()
    
    private let usersTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Total Users"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let coursesCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .systemGreen
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
    
    private let staffCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .systemOrange
        label.textAlignment = .center
        return label
    }()
    
    private let staffTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Staff"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let quickActionsLabel: UILabel = {
        let label = UILabel()
        label.text = "Administration"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private let buttonsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.distribution = .fillEqually
        return sv
    }()
    
    private let manageUsersButton = createActionButton(title: "👥 Manage Users", subtitle: "Add, edit, or delete users", color: .systemBlue)
    private let manageCoursesButton = createActionButton(title: "📚 Manage Courses", subtitle: "View all courses", color: .systemGreen)
    private let monitorActivityButton = createActionButton(title: "📊 Monitor Activity", subtitle: "View system logs", color: .systemOrange)
    private let configureSettingsButton = createActionButton(title: "⚙️ Settings", subtitle: "System configuration", color: .systemPurple)
    private let updateProfileButton = createActionButton(title: "👤 Profile", subtitle: "Update your info", color: .systemGray)
    private let logoutButton = createActionButton(title: "🚪 Logout", subtitle: "Sign out", color: .systemRed)
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Properties
    private var currentUser: User?
    
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
        
        [welcomeCard, statsCard, quickActionsLabel, buttonsStackView].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [welcomeLabel, nameLabel, roleBadge].forEach {
            welcomeCard.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let statsStack = UIStackView(arrangedSubviews: [
            createStatItem(view: usersCountLabel, titleLabel: usersTitleLabel),
            createStatDivider(),
            createStatItem(view: coursesCountLabel, titleLabel: coursesTitleLabel),
            createStatDivider(),
            createStatItem(view: staffCountLabel, titleLabel: staffTitleLabel)
        ])
        statsStack.axis = .horizontal
        statsStack.distribution = .fillEqually
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        statsCard.addSubview(statsStack)
        
        [manageUsersButton, manageCoursesButton, monitorActivityButton,
         configureSettingsButton, updateProfileButton, logoutButton].forEach {
            buttonsStackView.addArrangedSubview($0)
            $0.heightAnchor.constraint(equalToConstant: 70).isActive = true
        }
        
        NSLayoutConstraint.activate([
            statsStack.topAnchor.constraint(equalTo: statsCard.topAnchor, constant: 16),
            statsStack.leadingAnchor.constraint(equalTo: statsCard.leadingAnchor, constant: 8),
            statsStack.trailingAnchor.constraint(equalTo: statsCard.trailingAnchor, constant: -8),
            statsStack.bottomAnchor.constraint(equalTo: statsCard.bottomAnchor, constant: -16)
        ])
        
        activityIndicator.hidesWhenStopped = true
        roleBadge.text = "Admin"
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
            roleBadge.widthAnchor.constraint(equalToConstant: 110),
            roleBadge.heightAnchor.constraint(equalToConstant: 28),
            
            statsCard.topAnchor.constraint(equalTo: welcomeCard.bottomAnchor, constant: 16),
            statsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            statsCard.heightAnchor.constraint(equalToConstant: 100),
            
            quickActionsLabel.topAnchor.constraint(equalTo: statsCard.bottomAnchor, constant: 24),
            quickActionsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            buttonsStackView.topAnchor.constraint(equalTo: quickActionsLabel.bottomAnchor, constant: 16),
            buttonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        manageUsersButton.addTarget(self, action: #selector(showManageUsers), for: .touchUpInside)
        manageCoursesButton.addTarget(self, action: #selector(showManageCourses), for: .touchUpInside)
        monitorActivityButton.addTarget(self, action: #selector(showMonitorActivity), for: .touchUpInside)
        configureSettingsButton.addTarget(self, action: #selector(showConfigureSettings), for: .touchUpInside)
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
        stackView.isUserInteractionEnabled = false
        
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
        
        FirebaseService.shared.fetchUser(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
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
        let group = DispatchGroup()
        
        // Load total users
        group.enter()
        FirebaseService.shared.db.collection("users").getDocuments { snapshot, _ in
            let count = snapshot?.documents.count ?? 0
            DispatchQueue.main.async {
                self.usersCountLabel.text = "\(count)"
            }
            group.leave()
        }
        
        // Load total courses
        group.enter()
        FirebaseService.shared.db.collection("courses").getDocuments { snapshot, _ in
            let count = snapshot?.documents.count ?? 0
            DispatchQueue.main.async {
                self.coursesCountLabel.text = "\(count)"
            }
            group.leave()
        }
        
        // Load staff count
        group.enter()
        FirebaseService.shared.db.collection("users")
            .whereField("role", isEqualTo: "academic_staff")
            .getDocuments { snapshot, _ in
                let count = snapshot?.documents.count ?? 0
                DispatchQueue.main.async {
                    self.staffCountLabel.text = "\(count)"
                }
                group.leave()
            }
    }
    
    // MARK: - Navigation Actions
    @objc private func showManageUsers() {
        let usersVC = ManageUsersViewController()
        navigationController?.pushViewController(usersVC, animated: true)
    }
    
    @objc private func showManageCourses() {
        let coursesVC = AdminManageCoursesViewController()
        navigationController?.pushViewController(coursesVC, animated: true)
    }
    
    @objc private func showMonitorActivity() {
        let activityVC = MonitorActivityViewController()
        navigationController?.pushViewController(activityVC, animated: true)
    }
    
    @objc private func showConfigureSettings() {
        let settingsVC = ConfigureSettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
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