import Foundation
import FirebaseFirestore

struct Course {
    let id: String
    var name: String
    var code: String
    var instructor: String
    var credits: Int
    var description: String?
    var department: String
    var schedule: String?
    var room: String?
    var capacity: Int
    var enrolledCount: Int
    
    init(id: String = UUID().uuidString, name: String, code: String, instructor: String, credits: Int = 3, 
         description: String? = nil, department: String = "", schedule: String? = nil, 
         room: String? = nil, capacity: Int = 30, enrolledCount: Int = 0) {
        self.id = id
        self.name = name
        self.code = code
        self.instructor = instructor
        self.credits = credits
        self.description = description
        self.department = department
        self.schedule = schedule
        self.room = room
        self.capacity = capacity
        self.enrolledCount = enrolledCount
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let name = data["name"] as? String,
              let code = data["code"] as? String,
              let instructor = data["instructor"] as? String else {
            return nil
        }
        
        self.id = document.documentID
        self.name = name
        self.code = code
        self.instructor = instructor
        self.credits = data["credits"] as? Int ?? 3
        self.description = data["description"] as? String
        self.department = data["department"] as? String ?? ""
        self.schedule = data["schedule"] as? String
        self.room = data["room"] as? String
        self.capacity = data["capacity"] as? Int ?? 30
        self.enrolledCount = data["enrolledCount"] as? Int ?? 0
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "code": code,
            "instructor": instructor,
            "credits": credits,
            "description": description ?? "",
            "department": department,
            "schedule": schedule ?? "",
            "room": room ?? "",
            "capacity": capacity,
            "enrolledCount": enrolledCount
        ]
    }
}