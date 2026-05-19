import UIKit
import UniformTypeIdentifiers

class UploadMaterialsViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let coursePickerLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Course"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let coursePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = .systemGray6
        picker.layer.cornerRadius = 8
        return picker
    }()
    
    private let materialTitleField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Material Title"
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private let materialDescriptionTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = 8
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return tv
    }()
    
    private let fileTypeSegmented: UISegmentedControl = {
        let items = ["Document", "Link", "Video"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private let fileUrlField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "File URL or Link"
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private let selectFileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("📎 Select File", for: .normal)
        button.backgroundColor = .systemGray5
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let fileNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.isHidden = true
        return label
    }()
    
    private let uploadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Upload Material", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 12
        return button
    }()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Properties
    var staffCourses: [Course] = []
    private var selectedCourseIndex = 0
    private var selectedFileURL: URL?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        hideKeyboardWhenTappedAround()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Upload Materials"
        
        [scrollView, activityIndicator].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        [coursePickerLabel, coursePicker, materialTitleField, materialDescriptionTextView,
         fileTypeSegmented, fileUrlField, selectFileButton, fileNameLabel, uploadButton].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        coursePicker.delegate = self
        coursePicker.dataSource = self
        
        materialDescriptionTextView.delegate = self
        materialDescriptionTextView.text = "Description (optional)"
        materialDescriptionTextView.textColor = .placeholderText
        
        activityIndicator.hidesWhenStopped = true
        
        updateFileInputVisibility()
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
            
            coursePickerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            coursePickerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            coursePicker.topAnchor.constraint(equalTo: coursePickerLabel.bottomAnchor, constant: 8),
            coursePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            coursePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            coursePicker.heightAnchor.constraint(equalToConstant: 120),
            
            materialTitleField.topAnchor.constraint(equalTo: coursePicker.bottomAnchor, constant: 20),
            materialTitleField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            materialTitleField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            materialTitleField.heightAnchor.constraint(equalToConstant: 50),
            
            materialDescriptionTextView.topAnchor.constraint(equalTo: materialTitleField.bottomAnchor, constant: 16),
            materialDescriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            materialDescriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            materialDescriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            
            fileTypeSegmented.topAnchor.constraint(equalTo: materialDescriptionTextView.bottomAnchor, constant: 20),
            fileTypeSegmented.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            fileTypeSegmented.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            fileUrlField.topAnchor.constraint(equalTo: fileTypeSegmented.bottomAnchor, constant: 16),
            fileUrlField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            fileUrlField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            fileUrlField.heightAnchor.constraint(equalToConstant: 50),
            
            selectFileButton.topAnchor.constraint(equalTo: fileTypeSegmented.bottomAnchor, constant: 16),
            selectFileButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            selectFileButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            selectFileButton.heightAnchor.constraint(equalToConstant: 50),
            
            fileNameLabel.topAnchor.constraint(equalTo: selectFileButton.bottomAnchor, constant: 8),
            fileNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            uploadButton.topAnchor.constraint(equalTo: fileNameLabel.bottomAnchor, constant: 24),
            uploadButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            uploadButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            uploadButton.heightAnchor.constraint(equalToConstant: 50),
            uploadButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        fileTypeSegmented.addTarget(self, action: #selector(fileTypeChanged), for: .valueChanged)
        selectFileButton.addTarget(self, action: #selector(selectFile), for: .touchUpInside)
        uploadButton.addTarget(self, action: #selector(uploadMaterial), for: .touchUpInside)
    }
    
    @objc private func fileTypeChanged() {
        updateFileInputVisibility()
    }
    
    private func updateFileInputVisibility() {
        let isDocument = fileTypeSegmented.selectedSegmentIndex == 0
        fileUrlField.isHidden = !isDocument
        selectFileButton.isHidden = isDocument
        fileNameLabel.isHidden = isDocument
    }
    
    @objc private func selectFile() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .text, .image])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }
    
    @objc private func uploadMaterial() {
        guard staffCourses.indices.contains(selectedCourseIndex) else {
            showAlert(message: "Please select a course")
            return
        }
        
        guard let title = materialTitleField.text?.trimmingCharacters(in: .whitespaces), !title.isEmpty else {
            showAlert(message: "Please enter a title")
            return
        }
        
        let selectedCourse = staffCourses[selectedCourseIndex]
        let description = materialDescriptionTextView.text == "Description (optional)" ? "" : materialDescriptionTextView.text
        
        let fileType = getFileType()
        var fileUrl = fileUrlField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        
        if fileType == "document" && selectedFileURL != nil {
            // In a real app, you would upload the file to Firebase Storage first
            // For this demo, we'll use a placeholder URL
            fileUrl = selectedFileURL?.lastPathComponent ?? ""
        }
        
        guard !fileUrl.isEmpty else {
            showAlert(message: "Please provide a file or link")
            return
        }
        
        let materialData: [String: Any] = [
            "id": UUID().uuidString,
            "courseId": selectedCourse.id,
            "courseName": selectedCourse.name,
            "title": title,
            "description": description ?? "",
            "fileType": fileType,
            "fileUrl": fileUrl,
            "uploadedBy": FirebaseService.shared.getCurrentUserId() ?? "",
            "uploadedAt": Timestamp(date: Date()),
            "fileName": selectedFileURL?.lastPathComponent ?? ""
        ]
        
        activityIndicator.startAnimating()
        uploadButton.isEnabled = false
        
        FirebaseService.shared.db.collection("materials").addDocument(data: materialData) { [weak self] error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.uploadButton.isEnabled = true
                
                if let error = error {
                    self?.showAlert(message: "Upload failed: \(error.localizedDescription)")
                } else {
                    self?.showAlertAndClear(message: "Material uploaded successfully!")
                }
            }
        }
    }
    
    private func getFileType() -> String {
        switch fileTypeSegmented.selectedSegmentIndex {
        case 0: return "document"
        case 1: return "link"
        case 2: return "video"
        default: return "document"
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
        materialTitleField.text = ""
        materialDescriptionTextView.text = "Description (optional)"
        materialDescriptionTextView.textColor = .placeholderText
        fileUrlField.text = ""
        selectedFileURL = nil
        fileNameLabel.text = ""
        fileNameLabel.isHidden = true
        selectedCourseIndex = 0
        coursePicker.selectRow(0, inComponent: 0, animated: true)
    }
}

// MARK: - UIPickerView Delegate
extension UploadMaterialsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
extension UploadMaterialsViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Description (optional)" && textView.textColor == .placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description (optional)"
            textView.textColor = .placeholderText
        }
    }
}

// MARK: - UIDocumentPicker Delegate
extension UploadMaterialsViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        selectedFileURL = url
        fileNameLabel.text = url.lastPathComponent
        fileNameLabel.isHidden = false
        fileUrlField.text = url.path
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("File selection cancelled")
    }
}