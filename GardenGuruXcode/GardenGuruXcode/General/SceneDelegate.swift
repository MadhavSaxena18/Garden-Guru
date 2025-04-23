//
//  SceneDelegate.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 10/01/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        // Reset user defaults during development
        #if DEBUG
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        #endif
        
        // Determine which screen to show
        if !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
            // First time user - show onboarding
            showOnboarding()
        } else if !UserDefaults.standard.bool(forKey: "isLoggedIn") {
            // Completed onboarding but not logged in
            showLoginScreen()
        } else {
            // Logged in user - show main interface
            showMainInterface()
        }
        
        window?.makeKeyAndVisible()
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
