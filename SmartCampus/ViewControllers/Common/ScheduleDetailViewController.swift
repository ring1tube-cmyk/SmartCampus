import UIKit

class ScheduleDetailViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let courseCard: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 20
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
    
    private let detailsCard: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let dayLabel = createDetailLabel(icon: "📅", title: "Day")
    private let timeLabel = createDetailLabel(icon: "⏰", title: "Time")
    private let roomLabel = createDetailLabel(icon: "📍", title: "Room")
    private let instructorLabel = createDetailLabel(icon: "👨‍🏫", title: "Instructor")
    private let durationLabel = createDetailLabel(icon: "⌛", title: "Duration")
    
    // MARK: - Properties
    private let scheduleItem: ScheduleItem
    
    // MARK: - Initializer
    init(scheduleItem: ScheduleItem) {
        self.scheduleItem = scheduleItem
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
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Class Details"
        
        [scrollView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        [courseCard, detailsCard].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [courseCodeLabel, courseNameLabel].forEach {
            courseCard.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [dayLabel, timeLabel, roomLabel, instructorLabel, durationLabel].forEach {
            detailsCard.addSubview($0)
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
            
            courseCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            courseCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            courseCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            courseCodeLabel.topAnchor.constraint(equalTo: courseCard.topAnchor, constant: 20),
            courseCodeLabel.leadingAnchor.constraint(equalTo: courseCard.leadingAnchor, constant: 20),
            
            courseNameLabel.topAnchor.constraint(equalTo: courseCodeLabel.bottomAnchor, constant: 8),
            courseNameLabel.leadingAnchor.constraint(equalTo: courseCard.leadingAnchor, constant: 20),
            courseNameLabel.trailingAnchor.constraint(equalTo: courseCard.trailingAnchor, constant: -20),
            courseNameLabel.bottomAnchor.constraint(equalTo: courseCard.bottomAnchor, constant: -20),
            
            detailsCard.topAnchor.constraint(equalTo: courseCard.bottomAnchor, constant: 20),
            detailsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            detailsCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            dayLabel.topAnchor.constraint(equalTo: detailsCard.topAnchor, constant: 20),
            dayLabel.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 16),
            dayLabel.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor, constant: -16),
            
            timeLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 16),
            timeLabel.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 16),
            timeLabel.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor, constant: -16),
            
            roomLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 16),
            roomLabel.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 16),
            roomLabel.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor, constant: -16),
            
            instructorLabel.topAnchor.constraint(equalTo: roomLabel.bottomAnchor, constant: 16),
            instructorLabel.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 16),
            instructorLabel.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor, constant: -16),
            
            durationLabel.topAnchor.constraint(equalTo: instructorLabel.bottomAnchor, constant: 16),
            durationLabel.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 16),
            durationLabel.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor, constant: -16),
            durationLabel.bottomAnchor.constraint(equalTo: detailsCard.bottomAnchor, constant: -20)
        ])
    }
    
    private func populateData() {
        courseCodeLabel.text = scheduleItem.courseCode
        courseNameLabel.text = scheduleItem.courseName
        dayLabel.valueLabel.text = scheduleItem.day.rawValue
        timeLabel.valueLabel.text = scheduleItem.timeRange
        roomLabel.valueLabel.text = scheduleItem.room
        instructorLabel.valueLabel.text = scheduleItem.instructor
        
        let hours = Int(scheduleItem.duration / 3600)
        let minutes = Int((scheduleItem.duration.truncatingRemainder(dividingBy: 3600)) / 60)
        durationLabel.valueLabel.text = "\(hours) hour\(hours != 1 ? "s" : "") \(minutes) minute\(minutes != 1 ? "s" : "")"
    }
    
    private static func createDetailLabel(icon: String, title: String) -> DetailLabelView {
        let view = DetailLabelView()
        view.iconLabel.text = icon
        view.titleLabel.text = title
        return view
    }
}