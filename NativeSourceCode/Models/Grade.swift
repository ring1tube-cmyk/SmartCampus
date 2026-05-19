import Foundation

struct Grade {
    let courseId: String
    let courseName: String
    let courseCode: String
    let instructor: String      // ← ADD THIS (used in GradeDetailViewController)
    let score: Double
    let letterGrade: String
    let credits: Int
    
    init(courseId: String, courseName: String, courseCode: String, instructor: String = "", score: Double, credits: Int = 3) {
        self.courseId = courseId
        self.courseName = courseName
        self.courseCode = courseCode
        self.instructor = instructor   // ← ADD THIS
        self.score = score
        self.credits = credits
        self.letterGrade = Grade.calculateLetterGrade(from: score)
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
    
    var gradePoints: Double {
        switch letterGrade {
        case "A": return 4.0
        case "B": return 3.0
        case "C": return 2.0
        case "D": return 1.0
        default: return 0.0
        }
    }
    
    var isPassing: Bool {     // ← ADD THIS (used in GradeDetailViewController)
        return score >= 60
    }
}