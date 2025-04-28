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
        
        // Always start with onboarding
        let onboardingVC = OnboardingViewController()
        window?.rootViewController = onboardingVC
        window?.makeKeyAndVisible()
    }
    
    func showMainInterface() {
        let mainStoryboard = UIStoryboard(name: "exploreTab", bundle: nil)
        if let tabBarController = mainStoryboard.instantiateInitialViewController() {
            window?.rootViewController = tabBarController
            window?.makeKeyAndVisible()
        }
    }
    
    // Add this method to transition from onboarding to login
    func showLoginAfterOnboarding() {
        let loginVC = LoginViewController()
        let navigationController = UINavigationController(rootViewController: loginVC)
        window?.rootViewController = navigationController
        
        // Set flag that onboarding is complete
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
    
    func sceneDidDisconnect(_ scene: UIScene, willBeRemoved: Bool) {
        // Called when the scene is being removed from an active state.
        // This may occur when the scene is being closed or when the scene is being moved from an active state to an inactive state.
        // Remove this method if the scene is not being re-created after the scene is being removed.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene is being presented.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was being inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene is being being removed from an active state to an inactive state.
        // This may occur when the scene is being closed, or when the scene is being moved from an active state to an inactive state.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene when it is being re-created.
        // If any tasks are being run, they should be paused or terminated.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called when the scene is being being moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called when the scene is being being moved from an active state to an inactive state.
        // This may occur when the scene is being closed, or when the scene is being moved from an active state to an inactive state.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene when it is being re-created.
        // If any tasks are being run, they should be paused or terminated.
    }
}
