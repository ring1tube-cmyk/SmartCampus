import Foundation

struct ScheduleItem {
    let id: String
    let courseId: String
    let courseName: String
    let courseCode: String
    let day: Weekday
    let startTime: Date
    let endTime: Date
    let room: String
    let instructor: String
    
    enum Weekday: String, CaseIterable {
        case monday = "Monday"
        case tuesday = "Tuesday"
        case wednesday = "Wednesday"
        case thursday = "Thursday"
        case friday = "Friday"
        case saturday = "Saturday"
        case sunday = "Sunday"
    }
    
    var timeRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
    
    var duration: TimeInterval {
        return endTime.timeIntervalSince(startTime)
    }
}