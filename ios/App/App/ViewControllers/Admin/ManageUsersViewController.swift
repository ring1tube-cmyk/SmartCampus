import UIKit

class ManageUsersViewController: UIViewController {
    
    // MARK: - UI Components
    private let segmentedControl: UISegmentedControl = {
        let items = ["All Users", "Students", "Staff", "Admins"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No users found."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        label.isHidden = true
        return label
    }()
    
    private let addButton: UIBarButtonItem!
    
    // MARK: - Properties
    private var allUsers: [User] = []
    private var filteredUsers: [User] = []
    
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
        loadUsers()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Manage Users"
        
        navigationItem.rightBarButtonItem = addButton
        
        [segmentedControl, tableView, activityIndicator, emptyStateLabel].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        activityIndicator.hidesWhenStopped = true
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
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
        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
        tableView.separatorStyle = .none
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupActions() {
        addButton.target = self
        addButton.action = #selector(addUserTapped)
        segmentedControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
    }
    
    @objc private func filterChanged() {
        filterUsers()
        tableView.reloadData()
        emptyStateLabel.isHidden = !filteredUsers.isEmpty
    }
    
    private func filterUsers() {
        let selectedRole: String?
        switch segmentedControl.selectedSegmentIndex {
        case 1: selectedRole = "student"
        case 2: selectedRole = "academic_staff"
        case 3: selectedRole = "admin"
        default: selectedRole = nil
        }
        
        if let role = selectedRole {
            filteredUsers = allUsers.filter { $0.role == role }
        } else {
            filteredUsers = allUsers
        }
    }
    
    // MARK: - Data Loading
    private func loadUsers() {
        activityIndicator.startAnimating()
        
        FirebaseService.shared.fetchAllUsers { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.refreshControl.endRefreshing()
                
                switch result {
                case .success(let users):
                    self?.allUsers = users.filter { $0.id != FirebaseService.shared.getCurrentUserId() }
                    self?.filterUsers()
                    self?.tableView.reloadData()
                    self?.emptyStateLabel.isHidden = !(self?.filteredUsers.isEmpty ?? true)
                case .failure(let error):
                    self?.showAlert(message: "Failed to load users: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func refreshData() {
        loadUsers()
    }
    
    // MARK: - User Management
    @objc private func addUserTapped() {
        showUserForm()
    }
    
    private func showUserForm(user: User? = nil) {
        let alert = UIAlertController(title: user == nil ? "Add User" : "Edit User", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Full Name"
            textField.text = user?.name
        }
        alert.addTextField { textField in
            textField.placeholder = "Email"
            textField.text = user?.email
            textField.isEnabled = user == nil
            textField.autocapitalizationType = .none
        }
        alert.addTextField { textField in
            textField.placeholder = user == nil ? "Password" : "New Password (optional)"
            textField.isSecureTextEntry = true
            textField.text = ""
        }
        
        let roleSegmented = UISegmentedControl(items: ["Student", "Staff", "Admin"])
        roleSegmented.selectedSegmentIndex = user?.role == "student" ? 0 : (user?.role == "academic_staff" ? 1 : 2)
        
        alert.view.addSubview(roleSegmented)
        roleSegmented.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            roleSegmented.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 200),
            roleSegmented.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            roleSegmented.widthAnchor.constraint(equalToConstant: 250),
            roleSegmented.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let name = alert.textFields?[0].text, !name.isEmpty,
                  let email = alert.textFields?[1].text, !email.isEmpty else {
                self?.showAlert(message: "Please fill in all required fields")
                return
            }
            
            let roles = ["student", "academic_staff", "admin"]
            let selectedRole = roles[roleSegmented.selectedSegmentIndex]
            
            if let existingUser = user {
                // Update existing user
                self?.updateUser(userId: existingUser.id, name: name, role: selectedRole, password: alert.textFields?[2].text)
            } else {
                // Create new user
                guard let password = alert.textFields?[2].text, !password.isEmpty else {
                    self?.showAlert(message: "Please enter a password")
                    return
                }
                self?.createUser(name: name, email: email, password: password, role: selectedRole)
            }
        }
        
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Adjust alert height to accommodate the segmented control
        let height = NSLayoutConstraint(item: alert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 320)
        alert.view.addConstraint(height)
        
        present(alert, animated: true)
    }
    
    private func createUser(name: String, email: String, password: String, role: String) {
        activityIndicator.startAnimating()
        
        APIService.shared.createUser(name: name, email: email, password: password, role: role) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success:
                    self?.showAlertAndRefresh(message: "User created successfully!")
                case .failure(let error):
                    self?.showAlert(message: "Failed to create user: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateUser(userId: String, name: String, role: String, password: String?) {
        activityIndicator.startAnimating()
        
        let updateData: [String: Any] = ["name": name, "role": role]
        
        FirebaseService.shared.updateUserProfile(userId: userId, data: updateData) { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.showAlert(message: "Failed to update user: \(error.localizedDescription)")
                }
                return
            }
            
            if let newPassword = password, !newPassword.isEmpty {
                // Need to reset password via backend
                FirebaseService.shared.db.collection("users").document(userId).getDocument { snapshot, _ in
                    let email = snapshot?.data()?["email"] as? String ?? ""
                    APIService.shared.resetUserPassword(email: email, newPassword: newPassword) { result in
                        DispatchQueue.main.async {
                            self?.activityIndicator.stopAnimating()
                            switch result {
                            case .success:
                                self?.showAlertAndRefresh(message: "User updated successfully!")
                            case .failure(let error):
                                self?.showAlert(message: "User info updated but password reset failed: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.showAlertAndRefresh(message: "User updated successfully!")
                }
            }
        }
    }
    
    private func deleteUser(_ user: User) {
        let alert = UIAlertController(title: "Delete User", message: "Are you sure you want to delete \(user.name)? This action cannot be undone.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.performDelete(user: user)
        })
        present(alert, animated: true)
    }
    
    private func performDelete(user: User) {
        activityIndicator.startAnimating()
        
        APIService.shared.deleteUser(email: user.email) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success:
                    self?.showAlertAndRefresh(message: "User deleted successfully!")
                case .failure(let error):
                    self?.showAlert(message: "Failed to delete user: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func resetUserPassword(user: User) {
        let alert = UIAlertController(title: "Reset Password", message: "Enter new password for \(user.name)", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "New Password"
            textField.isSecureTextEntry = true
        }
        alert.addTextField { textField in
            textField.placeholder = "Confirm Password"
            textField.isSecureTextEntry = true
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .default) { [weak self] _ in
            guard let password = alert.textFields?[0].text, !password.isEmpty,
                  let confirm = alert.textFields?[1].text, password == confirm else {
                self?.showAlert(message: "Passwords do not match or are empty")
                return
            }
            
            self?.performPasswordReset(email: user.email, password: password)
        })
        present(alert, animated: true)
    }
    
    private func performPasswordReset(email: String, password: String) {
        activityIndicator.startAnimating()
        
        APIService.shared.resetUserPassword(email: email, newPassword: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success:
                    self?.showAlert(message: "Password reset successfully!")
                case .failure(let error):
                    self?.showAlert(message: "Failed to reset password: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showAlertAndRefresh(message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.loadUsers()
        })
        present(alert, animated: true)
    }
}

// MARK: - TableView Delegates
extension ManageUsersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        let user = filteredUsers[indexPath.row]
        cell.configure(with: user)
        cell.onEdit = { [weak self] in
            self?.showUserForm(user: user)
        }
        cell.onResetPassword = { [weak self] in
            self?.resetUserPassword(user: user)
        }
        cell.onDelete = { [weak self] in
            self?.deleteUser(user)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

// MARK: - User Cell
class UserCell: UITableViewCell {
    
    var onEdit: (() -> Void)?
    var onResetPassword: (() -> Void)?
    var onDelete: (() -> Void)?
    
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
    
    private let roleBadge: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        return label
    }()
    
    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        return button
    }()
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset PW", for: .normal)
        button.setTitleColor(.systemOrange, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        return button
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
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
        
        [nameLabel, emailLabel, roleBadge, editButton, resetButton, deleteButton].forEach {
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
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            roleBadge.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            roleBadge.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            roleBadge.widthAnchor.constraint(equalToConstant: 80),
            roleBadge.heightAnchor.constraint(equalToConstant: 20),
            
            editButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            editButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            editButton.widthAnchor.constraint(equalToConstant: 70),
            
            resetButton.topAnchor.constraint(equalTo: editButton.bottomAnchor, constant: 8),
            resetButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            resetButton.widthAnchor.constraint(equalToConstant: 70),
            
            deleteButton.topAnchor.constraint(equalTo: resetButton.bottomAnchor, constant: 8),
            deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            deleteButton.widthAnchor.constraint(equalToConstant: 70)
        ])
        
        // Hide role badge initially as we'll show role in name line
        roleBadge.isHidden = true
    }
    
    private func setupActions() {
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }
    
    @objc private func editTapped() {
        onEdit?()
    }
    
    @objc private func resetTapped() {
        onResetPassword?()
    }
    
    @objc private func deleteTapped() {
        onDelete?()
    }
    
    func configure(with user: User) {
        nameLabel.text = user.name
        emailLabel.text = user.email
    }
}