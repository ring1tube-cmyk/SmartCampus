import Foundation
import FirebaseFirestore

struct User {
    let id: String
    var name: String
    var email: String
    var role: String  // "student", "academic_staff", "admin"
    var phone: String?
    var createdAt: Date
    
    init(id: String, name: String, email: String, role: String, phone: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.phone = phone
        self.createdAt = createdAt
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let name = data["name"] as? String,
              let email = data["email"] as? String,
              let role = data["role"] as? String else {
            return nil
        }
        
        self.id = document.documentID
        self.name = name
        self.email = email
        self.role = role
        self.phone = data["phone"] as? String
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "email": email,
            "role": role,
            "phone": phone ?? "",
            "createdAt": Timestamp(date: createdAt)
        ]
    }
}