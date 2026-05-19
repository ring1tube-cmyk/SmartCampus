import UIKit
import FirebaseAuth   // ← ADD THIS LINE

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // Check if user is already logged in
        if let currentUser = Auth.auth().currentUser {
            // Fetch user role and navigate to appropriate dashboard
            FirebaseService.shared.fetchUserRole(userId: currentUser.uid) { role in
                DispatchQueue.main.async {
                    let dashboard = self.getDashboardForRole(role)
                    self.window?.rootViewController = UINavigationController(rootViewController: dashboard)
                    self.window?.makeKeyAndVisible()
                }
            }
        } else {
            let loginVC = LoginViewController()
            window?.rootViewController = UINavigationController(rootViewController: loginVC)
            window?.makeKeyAndVisible()
        }
    }
    
    private func getDashboardForRole(_ role: String) -> UIViewController {
        switch role {
        case "student":
            return StudentDashboardViewController()
        case "academic_staff":
            return StaffDashboardViewController()
        case "admin":
            return AdminDashboardViewController()
        default:
            return LoginViewController()
        }
    }
}