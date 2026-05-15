import Foundation
import FirebaseFirestore

struct Announcement {
    let id: String
    let title: String
    let message: String
    let senderId: String
    let senderName: String
    let senderRole: String      // "student", "academic_staff", "admin"
    let targetRole: String?     // "student", "academic_staff", "admin", or nil for all
    let courseId: String?       // Optional - if specific course
    let courseName: String?     // Optional - course name if specific course
    let createdAt: Date
    let isImportant: Bool       // Mark as important announcement
    
    init(id: String = UUID().uuidString, title: String, message: String,
         senderId: String, senderName: String, senderRole: String = "academic_staff",
         targetRole: String? = nil, courseId: String? = nil, courseName: String? = nil,
         createdAt: Date = Date(), isImportant: Bool = false) {
        self.id = id
        self.title = title
        self.message = message
        self.senderId = senderId
        self.senderName = senderName
        self.senderRole = senderRole
        self.targetRole = targetRole
        self.courseId = courseId
        self.courseName = courseName
        self.createdAt = createdAt
        self.isImportant = isImportant
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let title = data["title"] as? String,
              let message = data["message"] as? String,
              let senderId = data["senderId"] as? String,
              let senderName = data["senderName"] as? String else {
            return nil
        }
        
        self.id = document.documentID
        self.title = title
        self.message = message
        self.senderId = senderId
        self.senderName = senderName
        self.senderRole = data["senderRole"] as? String ?? "academic_staff"
        self.targetRole = data["targetRole"] as? String
        self.courseId = data["courseId"] as? String
        self.courseName = data["courseName"] as? String
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        self.isImportant = data["isImportant"] as? Bool ?? false
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "title": title,
            "message": message,
            "senderId": senderId,
            "senderName": senderName,
            "senderRole": senderRole,
            "targetRole": targetRole ?? "",
            "courseId": courseId ?? "",
            "courseName": courseName ?? "",
            "createdAt": Timestamp(date: createdAt),
            "isImportant": isImportant
        ]
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy • h:mm a"
        return formatter.string(from: createdAt)
    }
}