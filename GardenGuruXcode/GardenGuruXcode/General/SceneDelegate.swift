//
//  SceneDelegate.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 10/01/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let dataController = DataControllerGG.shared
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        // Set up session observers
        setupSessionObservers()
        
        // Check for stored session first
        Task {
            await checkAndHandleSession()
        }
        
        window?.makeKeyAndVisible()
    }
    
    private func checkAndHandleSession() async {
        print("\n=== Checking Session State ===")
        
        // Check if user is logged in
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        let userEmail = UserDefaults.standard.string(forKey: "userEmail")
        
        print("📊 Login state: \(isLoggedIn)")
        print("📧 User email: \(userEmail ?? "none")")
        
        if isLoggedIn, let email = userEmail, !email.isEmpty {
            print("✅ User is logged in")
            
            do {
                // Verify the user exists in our database
                if let user = try await dataController.initializeUser(email: email) {
                    print("✅ User exists in database: \(user.userName)")
                    
                    // User is valid, show main interface
                    DispatchQueue.main.async {
                        if !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
                            self.showOnboarding()
                        } else {
                            self.showMainInterface()
                        }
                    }
                } else {
                    print("❌ User not found in database")
                    handleInvalidSession()
                }
            } catch {
                print("❌ Error checking user: \(error)")
                handleInvalidSession()
            }
        } else {
            print("⚠️ User not logged in")
            handleInvalidSession()
        }
    }
    
    private func handleInvalidSession() {
        // Clear any stored session data
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        
        DispatchQueue.main.async {
            if !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
                self.showOnboarding()
            } else {
                self.showLoginScreen()
            }
        }
    }
    
    func showOnboarding() {
        print("Showing onboarding screen")
        let onboardingVC = OnboardingViewController()
        window?.rootViewController = onboardingVC
    }
    
    func showLoginScreen() {
        print("Showing login screen")
        let loginVC = LoginViewController()
        let navigationController = UINavigationController(rootViewController: loginVC)
        navigationController.modalPresentationStyle = .fullScreen
        window?.rootViewController = navigationController
    }
    
    func showMainInterface() {
        print("Showing main interface")
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarController = mainStoryboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
            window?.rootViewController = tabBarController
        }
    }
    
    // Add notification observer for session state changes
    func setupSessionObservers() {
        NotificationCenter.default.addObserver(forName: Notification.Name("UserSignedOut"), object: nil, queue: .main) { [weak self] _ in
            self?.handleInvalidSession()
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name("UserSignedIn"), object: nil, queue: .main) { [weak self] _ in
            self?.showMainInterface()
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called when the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
