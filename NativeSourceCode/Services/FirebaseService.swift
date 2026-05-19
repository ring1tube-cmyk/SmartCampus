import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Helper Methods
    
    func getCurrentUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    func getCurrentUserEmail() -> String? {
        return Auth.auth().currentUser?.email
    }
    
    // MARK: - Authentication
    
    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let uid = result?.user.uid else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID not found"])))
                return
            }
            
            self?.fetchUser(userId: uid, completion: completion)
        }
    }
    
    func register(email: String, password: String, name: String, role: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            // Update display name
            let changeRequest = result?.user.createProfileChangeRequest()
            changeRequest?.displayName = name
            changeRequest?.commitChanges { _ in }
            
            let user = User(id: uid, name: name, email: email, role: role)
            
            self?.db.collection("users").document(uid).setData(user.toDictionary()) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(user))
            }
        }
    }
    
    func logout() throws {
        try Auth.auth().signOut()
    }
    
    // MARK: - User Operations
    
    func fetchUser(userId: String, completion: @escaping (Result<User, Error>) -> Void) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = User(document: snapshot) else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                return
            }
            completion(.success(user))
        }
    }
    
    func fetchUserRole(userId: String, completion: @escaping (String) -> Void) {
        db.collection("users").document(userId).getDocument { snapshot, _ in
            let role = snapshot?.data()?["role"] as? String ?? "student"
            completion(role)
        }
    }
    
    func fetchAllUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let users = snapshot?.documents.compactMap { User(document: $0) } ?? []
            completion(.success(users))
        }
    }
    
    func updateUserProfile(userId: String, data: [String: Any], completion: @escaping (Error?) -> Void) {
        db.collection("users").document(userId).updateData(data, completion: completion)
    }
    
    // MARK: - Course Operations
    
    func fetchCourses(completion: @escaping (Result<[Course], Error>) -> Void) {
        db.collection("courses").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let courses = snapshot?.documents.compactMap { Course(document: $0) } ?? []
            completion(.success(courses))
        }
    }
    
    func fetchAllAvailableCourses(completion: @escaping (Result<[Course], Error>) -> Void) {
        db.collection("courses").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            let courses = snapshot?.documents.compactMap { Course(document: $0) } ?? []
            completion(.success(courses))
        }
    }
    
    func fetchMyEnrolledCourses(studentId: String, completion: @escaping (Result<[Course], Error>) -> Void) {
        db.collection("enrollments")
            .whereField("studentId", isEqualTo: studentId)
            .whereField("status", isEqualTo: "active")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let enrollments = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                let courseIds = enrollments.compactMap { $0.data()["courseId"] as? String }
                
                guard !courseIds.isEmpty else {
                    completion(.success([]))
                    return
                }
                
                self?.fetchCoursesByIds(courseIds, completion: completion)
            }
    }
    
    func fetchCoursesByIds(_ courseIds: [String], completion: @escaping (Result<[Course], Error>) -> Void) {
        guard !courseIds.isEmpty else {
            completion(.success([]))
            return
        }
        
        db.collection("courses").whereField(FieldPath.documentID(), in: courseIds).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            let courses = snapshot?.documents.compactMap { Course(document: $0) } ?? []
            completion(.success(courses))
        }
    }
    
    func addCourse(_ course: Course, completion: @escaping (Error?) -> Void) {
        db.collection("courses").document(course.id).setData(course.toDictionary(), completion: completion)
    }
    
    func updateCourse(courseId: String, data: [String: Any], completion: @escaping (Error?) -> Void) {
        db.collection("courses").document(courseId).updateData(data, completion: completion)
    }
    
    func deleteCourse(courseId: String, completion: @escaping (Error?) -> Void) {
        db.collection("courses").document(courseId).delete(completion: completion)
    }
    
    // MARK: - Enrollment Operations
    
    func enrollInCourse(courseId: String, courseName: String, courseCode: String, studentId: String, studentName: String, completion: @escaping (Error?) -> Void) {
        let enrollment = Enrollment(
            studentId: studentId,
            studentName: studentName,
            courseId: courseId,
            courseName: courseName,
            courseCode: courseCode
        )
        
        let batch = db.batch()
        
        // Add enrollment document
        let enrollmentRef = db.collection("enrollments").document(enrollment.id)
        batch.setData(enrollment.toDictionary(), forDocument: enrollmentRef)
        
        // Update course enrolled count
        let courseRef = db.collection("courses").document(courseId)
        batch.updateData(["enrolledCount": FieldValue.increment(Int64(1))], forDocument: courseRef)
        
        batch.commit(completion: completion)
    }
    
    func withdrawFromCourse(enrollmentId: String, courseId: String, completion: @escaping (Error?) -> Void) {
        let batch = db.batch()
        
        // Update enrollment status
        let enrollmentRef = db.collection("enrollments").document(enrollmentId)
        batch.updateData(["status": "dropped"], forDocument: enrollmentRef)
        
        // Decrease course enrolled count
        let courseRef = db.collection("courses").document(courseId)
        batch.updateData(["enrolledCount": FieldValue.increment(Int64(-1))], forDocument: courseRef)
        
        batch.commit(completion: completion)
    }
    
    // MARK: - Grade Operations
    
    func fetchEnrollments(for studentId: String, completion: @escaping (Result<[Enrollment], Error>) -> Void) {
        db.collection("enrollments")
            .whereField("studentId", isEqualTo: studentId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let enrollments = snapshot?.documents.compactMap { Enrollment(document: $0) } ?? []
                completion(.success(enrollments))
            }
    }
    
    func fetchGrades(for studentId: String, completion: @escaping (Result<[Grade], Error>) -> Void) {
        fetchEnrollments(for: studentId) { [weak self] result in
            switch result {
            case .success(let enrollments):
                self?.enrichEnrollmentsWithCourseDetails(enrollments, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchMyGrades(studentId: String, completion: @escaping (Result<[Grade], Error>) -> Void) {
        fetchGrades(for: studentId, completion: completion)
    }
    
    private func enrichEnrollmentsWithCourseDetails(_ enrollments: [Enrollment], completion: @escaping (Result<[Grade], Error>) -> Void) {
        let group = DispatchGroup()
        var grades: [Grade] = []
        var fetchError: Error?
        
        for enrollment in enrollments where enrollment.grade != nil {
            group.enter()
            db.collection("courses").document(enrollment.courseId).getDocument { snapshot, error in
                if let error = error {
                    fetchError = error
                } else if let data = snapshot?.data(),
                          let name = data["name"] as? String,
                          let code = data["code"] as? String {
                    let grade = Grade(courseId: enrollment.courseId,
                                     courseName: name,
                                     courseCode: code,
                                     instructor: data["instructor"] as? String ?? "",
                                     score: enrollment.grade ?? 0,
                                     credits: data["credits"] as? Int ?? 3)
                    grades.append(grade)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if let error = fetchError {
                completion(.failure(error))
            } else {
                completion(.success(grades.sorted { $0.courseName < $1.courseName }))
            }
        }
    }
    
    func calculateGPA(grades: [Grade]) -> Double {
        guard !grades.isEmpty else { return 0.0 }
        
        var totalPoints = 0.0
        var totalCredits = 0
        
        for grade in grades {
            totalPoints += grade.gradePoints * Double(grade.credits)
            totalCredits += grade.credits
        }
        
        return totalCredits > 0 ? totalPoints / Double(totalCredits) : 0.0
    }
    
    // MARK: - Schedule Operations
    
    func fetchMySchedule(studentId: String, completion: @escaping (Result<[ScheduleItem], Error>) -> Void) {
        fetchMyEnrolledCourses(studentId: studentId) { [weak self] result in
            switch result {
            case .success(let courses):
                let scheduleItems = courses.compactMap { course -> ScheduleItem? in
                    guard let scheduleString = course.schedule else { return nil }
                    return self?.parseScheduleItem(from: course, scheduleString: scheduleString)
                }
                completion(.success(scheduleItems))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func parseScheduleItem(from course: Course, scheduleString: String) -> ScheduleItem? {
        let dayMap: [String: ScheduleItem.Weekday] = [
            "monday": .monday, "tuesday": .tuesday, "wednesday": .wednesday,
            "thursday": .thursday, "friday": .friday, "saturday": .saturday, "sunday": .sunday
        ]
        let lowercased = scheduleString.lowercased()
        var selectedDay: ScheduleItem.Weekday = .monday
        for (key, day) in dayMap {
            if lowercased.contains(key) {
                selectedDay = day
                break
            }
        }
        
        // Parse times
        let pattern = "(\\d{1,2}:\\d{2}\\s*[AP]M)\\s*-\\s*(\\d{1,2}:\\d{2}\\s*[AP]M)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: scheduleString, range: NSRange(scheduleString.startIndex..., in: scheduleString)) else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        let startRange = Range(match.range(at: 1), in: scheduleString)!
        let endRange = Range(match.range(at: 2), in: scheduleString)!
        
        guard let startTime = formatter.date(from: String(scheduleString[startRange])),
              let endTime = formatter.date(from: String(scheduleString[endRange])) else {
            return nil
        }
        
        return ScheduleItem(
            id: course.id,
            courseId: course.id,
            courseName: course.name,
            courseCode: course.code,
            day: selectedDay,
            startTime: startTime,
            endTime: endTime,
            room: course.room ?? "TBD",
            instructor: course.instructor
        )
    }
    
    // MARK: - Announcements
    
    func fetchAnnouncements(for role: String?, completion: @escaping (Result<[Announcement], Error>) -> Void) {
        var query: Query = db.collection("announcements").order(by: "createdAt", descending: true)
        
        if let role = role {
            query = query.whereFilter(Filter.orFilter([
                Filter.whereField("targetRole", isEqualTo: role),
                Filter.whereField("targetRole", isEqualTo: "")
            ]))
        }
        
        query.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let announcements = snapshot?.documents.compactMap { Announcement(document: $0) } ?? []
            completion(.success(announcements))
        }
    }
    
    func fetchStudentAnnouncements(completion: @escaping (Result<[Announcement], Error>) -> Void) {
        db.collection("announcements")
            .whereFilter(Filter.orFilter([
                Filter.whereField("targetRole", isEqualTo: "student"),
                Filter.whereField("targetRole", isEqualTo: "")
            ]))
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                let announcements = snapshot?.documents.compactMap { Announcement(document: $0) } ?? []
                completion(.success(announcements))
            }
    }
    
    func sendAnnouncement(_ announcement: Announcement, completion: @escaping (Error?) -> Void) {
        db.collection("announcements").document(announcement.id).setData(announcement.toDictionary(), completion: completion)
    }
    
    // MARK: - Password Management
    
    func updatePassword(currentPassword: String, newPassword: String, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
            return
        }
        
        // Re-authenticate
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                completion(error)
                return
            }
            
            user.updatePassword(to: newPassword, completion: completion)
        }
    }
}