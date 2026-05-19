import UIKit

class GradeDetailViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let gradeCard: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private let letterGradeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 64, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private let courseNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let courseCodeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let detailsCard: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let instructorLabel = createInfoLabel(icon: "👨‍🏫", title: "Instructor")
    private let creditsLabel = createInfoLabel(icon: "📚", title: "Credits")
    private let gpaLabel = createInfoLabel(icon: "⭐", title: "Grade Points")
    private let statusLabel = createInfoLabel(icon: "✅", title: "Status")
    
    private let performanceCard: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let performanceTitle: UILabel = {
        let label = UILabel()
        label.text = "Performance Analysis"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private let progressView: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .default)
        pv.progressTintColor = .systemGreen
        pv.trackTintColor = .systemGray4
        pv.layer.cornerRadius = 4
        pv.clipsToBounds = true
        return pv
    }()
    
    private let percentageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // MARK: - Properties
    private let grade: Grade
    
    // MARK: - Initializer
    init(grade: Grade) {
        self.grade = grade
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
        updateGradeColor()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Grade Details"
        
        [scrollView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        [gradeCard, detailsCard, performanceCard].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [letterGradeLabel, scoreLabel, courseNameLabel, courseCodeLabel].forEach {
            gradeCard.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [instructorLabel, creditsLabel, gpaLabel, statusLabel].forEach {
            detailsCard.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [performanceTitle, progressView, percentageLabel].forEach {
            performanceCard.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
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
            
            gradeCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            gradeCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            gradeCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            letterGradeLabel.topAnchor.constraint(equalTo: gradeCard.topAnchor, constant: 24),
            letterGradeLabel.centerXAnchor.constraint(equalTo: gradeCard.centerXAnchor),
            
            scoreLabel.topAnchor.constraint(equalTo: letterGradeLabel.bottomAnchor, constant: 4),
            scoreLabel.centerXAnchor.constraint(equalTo: gradeCard.centerXAnchor),
            
            courseNameLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 16),
            courseNameLabel.leadingAnchor.constraint(equalTo: gradeCard.leadingAnchor, constant: 16),
            courseNameLabel.trailingAnchor.constraint(equalTo: gradeCard.trailingAnchor, constant: -16),
            
            courseCodeLabel.topAnchor.constraint(equalTo: courseNameLabel.bottomAnchor, constant: 4),
            courseCodeLabel.leadingAnchor.constraint(equalTo: gradeCard.leadingAnchor, constant: 16),
            courseCodeLabel.trailingAnchor.constraint(equalTo: gradeCard.trailingAnchor, constant: -16),
            courseCodeLabel.bottomAnchor.constraint(equalTo: gradeCard.bottomAnchor, constant: -20),
            
            detailsCard.topAnchor.constraint(equalTo: gradeCard.bottomAnchor, constant: 20),
            detailsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            instructorLabel.topAnchor.constraint(equalTo: detailsCard.topAnchor, constant: 16),
            instructorLabel.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 16),
            instructorLabel.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor, constant: -16),
            
            creditsLabel.topAnchor.constraint(equalTo: instructorLabel.bottomAnchor, constant: 12),
            creditsLabel.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 16),
            creditsLabel.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor, constant: -16),
            
            gpaLabel.topAnchor.constraint(equalTo: creditsLabel.bottomAnchor, constant: 12),
            gpaLabel.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 16),
            gpaLabel.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor, constant: -16),
            
            statusLabel.topAnchor.constraint(equalTo: gpaLabel.bottomAnchor, constant: 12),
            statusLabel.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor, constant: -16),
            statusLabel.bottomAnchor.constraint(equalTo: detailsCard.bottomAnchor, constant: -16),
            
            performanceCard.topAnchor.constraint(equalTo: detailsCard.bottomAnchor, constant: 20),
            performanceCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            performanceCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            performanceCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            performanceTitle.topAnchor.constraint(equalTo: performanceCard.topAnchor, constant: 16),
            performanceTitle.leadingAnchor.constraint(equalTo: performanceCard.leadingAnchor, constant: 16),
            
            progressView.topAnchor.constraint(equalTo: performanceTitle.bottomAnchor, constant: 16),
            progressView.leadingAnchor.constraint(equalTo: performanceCard.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: performanceCard.trailingAnchor, constant: -16),
            progressView.heightAnchor.constraint(equalToConstant: 8),
            
            percentageLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8),
            percentageLabel.leadingAnchor.constraint(equalTo: performanceCard.leadingAnchor, constant: 16),
            percentageLabel.trailingAnchor.constraint(equalTo: performanceCard.trailingAnchor, constant: -16),
            percentageLabel.bottomAnchor.constraint(equalTo: performanceCard.bottomAnchor, constant: -16)
        ])
        
        progressView.progress = Float(grade.score / 100)
    }
    
    private func populateData() {
        letterGradeLabel.text = grade.letterGrade
        scoreLabel.text = "\(Int(grade.score))%"
        courseNameLabel.text = grade.courseName
        courseCodeLabel.text = grade.courseCode
        instructorLabel.valueLabel.text = grade.instructor
        creditsLabel.valueLabel.text = "\(grade.credits) credits"
        gpaLabel.valueLabel.text = String(format: "%.2f (out of 4.0)", grade.gradePoints)
        statusLabel.valueLabel.text = grade.isPassing ? "✅ Passing" : "❌ Not Passing"
        percentageLabel.text = "You scored \(Int(grade.score))% of the total available points"
        
        if grade.isPassing {
            statusLabel.valueLabel.textColor = .systemGreen
        } else {
            statusLabel.valueLabel.textColor = .systemRed
        }
    }
    
    private func updateGradeColor() {
        switch grade.letterGrade {
        case "A":
            gradeCard.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
            letterGradeLabel.textColor = .systemGreen
        case "B":
            gradeCard.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
            letterGradeLabel.textColor = .systemBlue
        case "C":
            gradeCard.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
            letterGradeLabel.textColor = .systemOrange
        case "D":
            gradeCard.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.15)
            letterGradeLabel.textColor = .systemYellow
        default:
            gradeCard.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
            letterGradeLabel.textColor = .systemRed
        }
    }
    
    private static func createInfoLabel(icon: String, title: String) -> InfoLabelView {
        let view = InfoLabelView()
        view.iconLabel.text = icon
        view.titleLabel.text = title
        return view
    }
}

// MARK: - Info Label View
class InfoLabelView: UIView {
    
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