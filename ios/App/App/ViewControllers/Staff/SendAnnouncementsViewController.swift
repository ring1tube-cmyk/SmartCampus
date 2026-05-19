import UIKit

class SendAnnouncementsViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Announcement Title"
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 16, weight: .semibold)
        return tf
    }()
    
    private let targetAudienceLabel: UILabel = {
        let label = UILabel()
        label.text = "Target Audience"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let targetSegmented: UISegmentedControl = {
        let items = ["All Students", "Specific Course"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private let coursePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = .systemGray6
        picker.layer.cornerRadius = 8
        picker.isHidden = true
        return picker
    }()
    
    private let messageTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = 8
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return tv
    }()
    
    private let importantSwitch: UISwitch = {
        let sw = UISwitch()
        return sw
    }()
    
    private let importantLabel: UILabel = {
        let label = UILabel()
        label.text = "Mark as Important"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send Announcement", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 12
        return button
    }()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Properties
    var staffId: String?
    var staffName: String?
    var staffCourses: [Course] = []
    private var selectedCourseIndex = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        loadCourses()
        hideKeyboardWhenTappedAround()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Send Announcement"
        
        [scrollView, activityIndicator].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        [titleField, targetAudienceLabel, targetSegmented, coursePicker,
         messageTextView, importantSwitch, importantLabel, sendButton].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        coursePicker.delegate = self
        coursePicker.dataSource = self
        
        messageTextView.delegate = self
        messageTextView.text = "Message content..."
        messageTextView.textColor = .placeholderText
        
        activityIndicator.hidesWhenStopped = true
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
            
            titleField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleField.heightAnchor.constraint(equalToConstant: 50),
            
            targetAudienceLabel.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 20),
            targetAudienceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            targetSegmented.topAnchor.constraint(equalTo: targetAudienceLabel.bottomAnchor, constant: 8),
            targetSegmented.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            targetSegmented.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            coursePicker.topAnchor.constraint(equalTo: targetSegmented.bottomAnchor, constant: 8),
            coursePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            coursePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            coursePicker.heightAnchor.constraint(equalToConstant: 120),
            
            messageTextView.topAnchor.constraint(equalTo: coursePicker.bottomAnchor, constant: 16),
            messageTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            messageTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            messageTextView.heightAnchor.constraint(equalToConstant: 150),
            
            importantSwitch.topAnchor.constraint(equalTo: messageTextView.bottomAnchor, constant: 20),
            importantSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            importantLabel.centerYAnchor.constraint(equalTo: importantSwitch.centerYAnchor),
            importantLabel.trailingAnchor.constraint(equalTo: importantSwitch.leadingAnchor, constant: -12),
            
            sendButton.topAnchor.constraint(equalTo: importantSwitch.bottomAnchor, constant: 30),
            sendButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sendButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            sendButton.heightAnchor.constraint(equalToConstant: 50),
            sendButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        targetSegmented.addTarget(self, action: #selector(targetChanged), for: .valueChanged)
        sendButton.addTarget(self, action: #selector(sendAnnouncement), for: .touchUpInside)
    }
    
    @objc private func targetChanged() {
        let isSpecificCourse = targetSegmented.selectedSegmentIndex == 1
        coursePicker.isHidden = !isSpecificCourse
    }
    
    private func loadCourses() {
        guard let staffId = staffId else { return }
        
        FirebaseService.shared.db.collection("courses")
            .whereField("instructorId", isEqualTo: staffId)
            .getDocuments { [weak self] snapshot, _ in
                self?.staffCourses = snapshot?.documents.compactMap { Course(document: $0) } ?? []
                self?.coursePicker.reloadAllComponents()
            }
    }
    
    @objc private func sendAnnouncement() {
        guard let title = titleField.text?.trimmingCharacters(in: .whitespaces), !title.isEmpty else {
            showAlert(message: "Please enter a title")
            return
        }
        
        let message = messageTextView.text == "Message content..." ? "" : messageTextView.text ?? ""
        guard !message.isEmpty else {
            showAlert(message: "Please enter a message")
            return
        }
        
        guard let staffId = staffId, let staffName = staffName else {
            showAlert(message: "Staff information not found")
            return
        }
        
        let targetRole: String?
        let courseId: String?
        let courseName: String?
        
        if targetSegmented.selectedSegmentIndex == 0 {
            targetRole = "student"
            courseId = nil
            courseName = nil
        } else {
            guard staffCourses.indices.contains(selectedCourseIndex) else {
                showAlert(message: "Please select a course")
                return
            }
            targetRole = nil
            courseId = staffCourses[selectedCourseIndex].id
            courseName = staffCourses[selectedCourseIndex].name
        }
        
        let announcement = Announcement(
            title: title,
            message: message,
            senderId: staffId,
            senderName: staffName,
            senderRole: "academic_staff",
            targetRole: targetRole,
            courseId: courseId,
            courseName: courseName,
            isImportant: importantSwitch.isOn
        )
        
        activityIndicator.startAnimating()
        sendButton.isEnabled = false
        
        FirebaseService.shared.sendAnnouncement(announcement) { [weak self] error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.sendButton.isEnabled = true
                
                if let error = error {
                    self?.showAlert(message: "Failed to send: \(error.localizedDescription)")
                } else {
                    self?.showAlertAndClear(message: "Announcement sent successfully!")
                }
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showAlertAndClear(message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.clearForm()
        })
        present(alert, animated: true)
    }
    
    private func clearForm() {
        titleField.text = ""
        messageTextView.text = "Message content..."
        messageTextView.textColor = .placeholderText
        importantSwitch.isOn = false
        targetSegmented.selectedSegmentIndex = 0
        coursePicker.isHidden = true
        selectedCourseIndex = 0
    }
}

// MARK: - UIPickerView Delegate
extension SendAnnouncementsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
    }
}

// MARK: - UITextView Delegate
extension SendAnnouncementsViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Message content..." && textView.textColor == .placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Message content..."
            textView.textColor = .placeholderText
        }
    }
}