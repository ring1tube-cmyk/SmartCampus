import Foundation
import FirebaseFirestore

struct Enrollment {
    let id: String
    let studentId: String
    let studentName: String
    let courseId: String
    let courseName: String
    let courseCode: String
    let enrolledAt: Date
    var status: String // "active", "dropped", "completed"
    var grade: Double?
    var letterGrade: String?
    var attendance: Double?
    
    init(id: String = UUID().uuidString, studentId: String, studentName: String, courseId: String,
         courseName: String, courseCode: String, enrolledAt: Date = Date(), status: String = "active",
         grade: Double? = nil, attendance: Double? = nil) {
        self.id = id
        self.studentId = studentId
        self.studentName = studentName
        self.courseId = courseId
        self.courseName = courseName
        self.courseCode = courseCode
        self.enrolledAt = enrolledAt
        self.status = status
        self.grade = grade
        self.letterGrade = grade.map { Enrollment.calculateLetterGrade(from: $0) }
        self.attendance = attendance
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let studentId = data["studentId"] as? String,
              let studentName = data["studentName"] as? String,
              let courseId = data["courseId"] as? String,
              let courseName = data["courseName"] as? String,
              let courseCode = data["courseCode"] as? String else {
            return nil
        }
        
        self.id = document.documentID
        self.studentId = studentId
        self.studentName = studentName
        self.courseId = courseId
        self.courseName = courseName
        self.courseCode = courseCode
        self.enrolledAt = (data["enrolledAt"] as? Timestamp)?.dateValue() ?? Date()
        self.status = data["status"] as? String ?? "active"
        self.grade = data["grade"] as? Double
        self.letterGrade = grade.map { Enrollment.calculateLetterGrade(from: $0) }
        self.attendance = data["attendance"] as? Double
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "studentId": studentId,
            "studentName": studentName,
            "courseId": courseId,
            "courseName": courseName,
            "courseCode": courseCode,
            "enrolledAt": Timestamp(date: enrolledAt),
            "status": status,
            "grade": grade ?? NSNull(),
            "attendance": attendance ?? NSNull()
        ]
    }
    
    private static func calculateLetterGrade(from score: Double) -> String {
        switch score {
        case 90...100: return "A"
        case 80..<90: return "B"
        case 70..<80: return "C"
        case 60..<70: return "D"
        default: return "F"
        }
    }
}