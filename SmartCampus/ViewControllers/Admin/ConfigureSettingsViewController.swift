import UIKit

class ConfigureSettingsViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // General Settings Section
    private let generalSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "General Settings"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private let appNameTextField = createSettingField(title: "App Name", placeholder: "SmartCampus")
    private let contactEmailField = createSettingField(title: "Contact Email", placeholder: "admin@smartcampus.edu")
    private let semesterSegment: UISegmentedControl = {
        let items = ["Fall", "Spring", "Summer"]
        let sc = UISegmentedControl(items: items)
        return sc
    }()
    private let semesterLabel = createSectionLabel(title: "Current Semester")
    
    // Academic Settings Section
    private let academicSectionLabel = createSectionLabel(title: "Academic Settings")
    private let gradePassingThreshold = createSettingField(title: "Passing Grade (%)", placeholder: "60", keyboardType: .numberPad)
    private let maxCreditsPerSemester = createSettingField(title: "Max Credits/Semester", placeholder: "18", keyboardType: .numberPad)
    
    // Security Settings Section
    private let securitySectionLabel = createSectionLabel(title: "Security Settings")
    private let minPasswordLength = createSettingField(title: "Min Password Length", placeholder: "6", keyboardType: .numberPad)
    private let sessionTimeoutSwitch: UISwitch = UISwitch()
    private let sessionTimeoutLabel: UILabel = {
        let label = UILabel()
        label.text = "Session Timeout (minutes)"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    private let sessionTimeoutField = createSettingField(title: "", placeholder: "30", keyboardType: .numberPad)
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Settings", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 12
        return button
    }()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        loadSettings()
        hideKeyboardWhenTappedAround()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "System Settings"
        
        [scrollView, activityIndicator].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let generalStack = UIStackView(arrangedSubviews: [
            appNameTextField, contactEmailField, semesterLabel, semesterSegment
        ])
        generalStack.axis = .vertical
        generalStack.spacing = 16
        
        let academicStack = UIStackView(arrangedSubviews: [
            gradePassingThreshold, maxCreditsPerSemester
        ])
        academicStack.axis = .vertical
        academicStack.spacing = 16
        
        let sessionRow = UIStackView(arrangedSubviews: [sessionTimeoutLabel, sessionTimeoutSwitch])
        sessionRow.axis = .horizontal
        sessionRow.distribution = .equalSpacing
        
        let securityStack = UIStackView(arrangedSubviews: [
            minPasswordLength, sessionRow, sessionTimeoutField
        ])
        securityStack.axis = .vertical
        securityStack.spacing = 16
        
        [generalSectionLabel, generalStack, academicSectionLabel, academicStack,
         securitySectionLabel, securityStack, saveButton].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        activityIndicator.hidesWhenStopped = true
        sessionTimeoutField.isHidden = true
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
            
            generalSectionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            generalSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            generalStack.topAnchor.constraint(equalTo: generalSectionLabel.bottomAnchor, constant: 16),
            generalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            generalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            academicSectionLabel.topAnchor.constraint(equalTo: generalStack.bottomAnchor, constant: 24),
            academicSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            academicStack.topAnchor.constraint(equalTo: academicSectionLabel.bottomAnchor, constant: 16),
            academicStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            academicStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            securitySectionLabel.topAnchor.constraint(equalTo: academicStack.bottomAnchor, constant: 24),
            securitySectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            securityStack.topAnchor.constraint(equalTo: securitySectionLabel.bottomAnchor, constant: 16),
            securityStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            securityStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            saveButton.topAnchor.constraint(equalTo: securityStack.bottomAnchor, constant: 32),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            appNameTextField.heightAnchor.constraint(equalToConstant: 50),
            contactEmailField.heightAnchor.constraint(equalToConstant: 50),
            gradePassingThreshold.heightAnchor.constraint(equalToConstant: 50),
            maxCreditsPerSemester.heightAnchor.constraint(equalToConstant: 50),
            minPasswordLength.heightAnchor.constraint(equalToConstant: 50),
            sessionTimeoutField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveSettings), for: .touchUpInside)
        sessionTimeoutSwitch.addTarget(self, action: #selector(sessionTimeoutToggled), for: .valueChanged)
    }
    
    @objc private func sessionTimeoutToggled() {
        sessionTimeoutField.isHidden = !sessionTimeoutSwitch.isOn
    }
    
    private static func createSettingField(title: String, placeholder: String, keyboardType: UIKeyboardType = .default) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.keyboardType = keyboardType
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, textField])
        stack.axis = .vertical
        stack.spacing = 4
        
        // Store reference to text field
        textField.tag = 100
        
        return textField
    }
    
    private static func createSectionLabel(title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }
    
    // MARK: - Data Loading
    private func loadSettings() {
        activityIndicator.startAnimating()
        
        FirebaseService.shared.db.collection("settings").document("app_settings").getDocument { [weak self] snapshot, _ in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                guard let data = snapshot?.data() else { return }
                
                self?.appNameTextField.text = data["appName"] as? String ?? "SmartCampus"
                self?.contactEmailField.text = data["contactEmail"] as? String ?? "admin@smartcampus.edu"
                
                let semester = data["currentSemester"] as? String ?? "Fall"
                let semesterIndex = semester == "Fall" ? 0 : (semester == "Spring" ? 1 : 2)
                self?.semesterSegment.selectedSegmentIndex = semesterIndex
                
                self?.gradePassingThreshold.text = data["gradePassingThreshold"].map { "\($0)" } ?? "60"
                self?.maxCreditsPerSemester.text = data["maxCreditsPerSemester"].map { "\($0)" } ?? "18"
                self?.minPasswordLength.text = data["minPasswordLength"].map { "\($0)" } ?? "6"
                
                let timeoutEnabled = data["sessionTimeoutEnabled"] as? Bool ?? false
                self?.sessionTimeoutSwitch.isOn = timeoutEnabled
                self?.sessionTimeoutField.isHidden = !timeoutEnabled
                self?.sessionTimeoutField.text = data["sessionTimeoutMinutes"].map { "\($0)" } ?? "30"
            }
        }
    }
    
    @objc private func saveSettings() {
        let semesterValue = ["Fall", "Spring", "Summer"][semesterSegment.selectedSegmentIndex]
        
        let settings: [String: Any] = [
            "appName": appNameTextField.text ?? "SmartCampus",
            "contactEmail": contactEmailField.text ?? "admin@smartcampus.edu",
            "currentSemester": semesterValue,
            "gradePassingThreshold": Int(gradePassingThreshold.text ?? "60") ?? 60,
            "maxCreditsPerSemester": Int(maxCreditsPerSemester.text ?? "18") ?? 18,
            "minPasswordLength": Int(minPasswordLength.text ?? "6") ?? 6,
            "sessionTimeoutEnabled": sessionTimeoutSwitch.isOn,
            "sessionTimeoutMinutes": Int(sessionTimeoutField.text ?? "30") ?? 30,
            "updatedAt": Timestamp(date: Date()),
            "updatedBy": FirebaseService.shared.getCurrentUserId() ?? ""
        ]
        
        activityIndicator.startAnimating()
        saveButton.isEnabled = false
        
        FirebaseService.shared.db.collection("settings").document("app_settings").setData(settings, merge: true) { [weak self] error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self