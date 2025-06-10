//
//  AppDelegate.swift
//  GardenGuruXcode
//
//  Created by Madhav Saxena on 10/01/25.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification permissions with all options
        let options: UNAuthorizationOptions = [.alert, .sound, .badge, .provisional]
        DataControllerGG.shared.requestNotificationPermission { granted in
            if granted {
                print("✅ Notification permission granted")
                // Debug: Check current notification settings
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    print("📱 Notification Settings:")
                    print("- Authorization Status: \(settings.authorizationStatus.rawValue)")
                    print("- Alert Setting: \(settings.alertSetting.rawValue)")
                    print("- Sound Setting: \(settings.soundSetting.rawValue)")
                    print("- Badge Setting: \(settings.badgeSetting.rawValue)")
                    print("- Notification Center Setting: \(settings.notificationCenterSetting.rawValue)")
                    print("- Lock Screen Setting: \(settings.lockScreenSetting.rawValue)")
                    
                    // Schedule a test notification for 30 seconds from now
                    let content = UNMutableNotificationContent()
                    content.title = "Test Notification"
                    content.body = "This is a test notification from Garden Guru"
                    content.sound = .default
                    content.badge = 1
                    
                    // Add thread identifier for grouping
                    content.threadIdentifier = "garden_guru_notifications"
                    
                    // Add category identifier
                    content.categoryIdentifier = "GARDEN_REMINDER"
                    
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
                    let request = UNNotificationRequest(identifier: "testNotification", content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("❌ Error scheduling test notification: \(error)")
                        } else {
                            print("✅ Test notification scheduled for 30 seconds from now")
                        }
                    }
                }
            } else {
                print("❌ Notification permission denied")
            }
        }
        
        // Set up notification categories and actions
        let markAsDoneAction = UNNotificationAction(
            identifier: "MARK_AS_DONE",
            title: "Mark as Done",
            options: .foreground
        )
        
        let remindLaterAction = UNNotificationAction(
            identifier: "REMIND_LATER",
            title: "Remind Later",
            options: .foreground
        )
        
        let category = UNNotificationCategory(
            identifier: "GARDEN_REMINDER",
            actions: [markAsDoneAction, remindLaterAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    // This will be called when the app is in the foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("📱 Received notification in foreground: \(notification.request.identifier)")
        
        // Show notification with all presentation options
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge, .list])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    // This will be called when user taps on the notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.notification.request.identifier
        print("📱 User tapped notification: \(identifier)")
        
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            print("Default action")
        case "MARK_AS_DONE":
            print("User marked as done")
            // Handle mark as done action
        case "REMIND_LATER":
            print("User requested reminder later")
            // Handle remind later action
        case UNNotificationDismissActionIdentifier:
            print("User dismissed notification")
        default:
            break
        }
        
        completionHandler()
    }
}

// MARK: - Remote Notifications
extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("📱 Device Token: \(token)")
        
        // TODO: Send token to your server when implemented
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register for remote notifications: \(error)")
    }
}
