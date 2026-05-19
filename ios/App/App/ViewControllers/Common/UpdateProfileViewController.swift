import UIKit

class UpdateProfileViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let profileImageView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 50
        view.clipsToBounds = true
        return view
    }()
    
    private let profileIconLabel: UILabel = {
        let label = UILabel()
        label.text = "👤"
        label.font = .systemFont(ofSize: 40)
        label.textAlignment = .center
        return label
    }()
    
    private let nameTextField = createTextField(placeholder: "Full Name", icon: "📝")
    private let emailTextField = createTextField(placeholder: "Email", icon: "✉️", isEditable: false)
    private let phoneTextField = createTextField(placeholder: "Phone Number", icon: "📞", keyboardType: .phonePad)
    
    private let passwordSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Change Password"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private let currentPasswordTextField = createTextField(placeholder: "Current Password", icon: "🔒", isSecure: true)
    private let newPasswordTextField = createTextField(placeholder: "New Password (min 6 characters)", icon: "🔑", isSecure: true)
    private let confirmPasswordTextField = createTextField(placeholder: "Confirm New Password", icon: "✓", isSecure: true)
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Changes", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 12
        return button
    }()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Properties
    var user: User?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateData()
        setupActions()
        hideKeyboardWhenTappedAround()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Update Profile"
        
        [scrollView, activityIndicator].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        [profileImageView, nameTextField, emailTextField, phoneTextField,
         passwordSectionLabel, currentPasswordTextField, newPasswordTextField,
         confirmPasswordTextField, saveButton].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        profileImageView.addSubview(profileIconLabel)
        profileIconLabel.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.hidesWhenStopped = true
        
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
            
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            profileIconLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            profileIconLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            phoneTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            phoneTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            phoneTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            phoneTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordSectionLabel.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 24),
            passwordSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            currentPasswordTextField.topAnchor.constraint(equalTo: passwordSectionLabel.bottomAnchor, constant: 12),
            currentPasswordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            currentPasswordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            currentPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            newPasswordTextField.topAnchor.constraint(equalTo: currentPasswordTextField.bottomAnchor, constant: 12),
            newPasswordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            newPasswordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            newPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: newPasswordTextField.bottomAnchor, constant: 12),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            saveButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func populateData() {
        nameTextField.text = user?.name
        emailTextField.text = user?.email
        phoneTextField.text = user?.phone
    }
    
    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveChanges), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func saveChanges() {
        let updatedName = nameTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let updatedPhone = phoneTextField.text?.trimmingCharacters(in: .whitespaces)
        
        let currentPassword = currentPasswordTextField.text ?? ""
        let newPassword = newPasswordTextField.text ?? ""
        let confirmPassword = confirmPasswordTextField.text ?? ""
        
        // Validate name
        guard !updatedName.isEmpty else {
            showAlert(message: "Please enter your name")
            return
        }
        
        activityIndicator.startAnimating()
        saveButton.isEnabled = false
        
        let group = DispatchGroup()
        var updateError: Error?
        
        // Update profile information
        group.enter()
        var updateData: [String: Any] = ["name": updatedName]
        if let phone = updatedPhone, !phone.isEmpty {
            updateData["phone"] = phone
        }
        
        if let userId = user?.id {
            FirebaseService.shared.updateUserProfile(userId: userId, data: updateData) { error in
                if let error = error {
                    updateError = error
                }
                group.leave()
            }
        } else {
            group.leave()
        }
        
        // Update password if provided
        if !newPassword.isEmpty {
            guard newPassword.count >= 6 else {
                activityIndicator.stopAnimating()
                saveButton.isEnabled = true
                showAlert(message: "New password must be at least 6 characters")
                return
            }
            
            guard newPassword == confirmPassword else {
                activityIndicator.stopAnimating()
                saveButton.isEnabled = true
                showAlert(message: "New passwords do not match")
                return
            }
            
            guard !currentPassword.isEmpty else {
                activityIndicator.stopAnimating()
                saveButton.isEnabled = true
                showAlert(message: "Please enter your current password to change it")
                return
            }
            
            group.enter()
            FirebaseService.shared.updatePassword(currentPassword: currentPassword, newPassword: newPassword) { error in
                if let error = error {
                    updateError = error
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.saveButton.isEnabled = true
            
            if let error = updateError {
                self?.showAlert(message: "Update failed: \(error.localizedDescription)")
            } else {
                self?.showAlertAndDismiss(message: "Profile updated successfully!")
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showAlertAndDismiss(message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    private static func createTextField(placeholder: String, icon: String, isEditable: Bool = true, isSecure: Bool = false, keyboardType: UIKeyboardType = .default) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = isSecure
        textField.isUserInteractionEnabled = isEditable
        textField.keyboardType = keyboardType
        textField.autocapitalizationType = .words
        textField.autocorrectionType = .no
        
        // Add icon
        let iconView = UILabel()
        iconView.text = icon
        iconView.font = .systemFont(ofSize: 18)
        iconView.frame = CGRect(x: 0, y: 0, width: 30, height: 50)
        textField.leftView = iconView
        textField.leftViewMode = .always
        
        return textField
    }
}