

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerForPushNotifications()
        UNUserNotificationCenter.current().delegate = self
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
    
    func registerForPushNotifications() {
        
        UNUserNotificationCenter.current()
        
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                
                print("Permission granted: \(granted)")
                
                guard granted else { return }
                
                let viewAction = UNNotificationAction(identifier: Identifiers.viewAction, title: "View", options: [.foreground])
                
                let visitLinkAction = UNNotificationAction(identifier: Identifiers.visitLinkAction, title: "Visit link", options: [.foreground])
                
                let notificationCategory = UNNotificationCategory(identifier: Identifiers.notificationCategory, actions: [viewAction, visitLinkAction], intentIdentifiers: [])
                
                UNUserNotificationCenter.current().setNotificationCategories([notificationCategory])
                
                self.getNotificationSettings()
            }
    }
    
    func getNotificationSettings() {
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            if let rootVC = scene.window?.rootViewController as? UINavigationController {
                if let vc = rootVC.viewControllers.first as? ViewController {
                    vc.notificationCameWhen(.running)
                }
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let actionIdentifier = response.actionIdentifier
        
        switch actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            break
        case UNNotificationDefaultActionIdentifier:
            if let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                if let rootVC = scene.window?.rootViewController as? UINavigationController {
                    if let vc = rootVC.viewControllers.first as? ViewController {
                        vc.notificationCameWhen(.notLaunched)
                    }
                }
            }
        case Identifiers.viewAction:
            if let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                if let rootVC = scene.window?.rootViewController as? UINavigationController {
                    if let vc = rootVC.viewControllers.first as? ViewController {
                        vc.notificationCameWhen(.notLaunched)
                    }
                }
            }
        case Identifiers.visitLinkAction:
            let userInfo = response.notification.request.content.userInfo
            guard let aps = userInfo["aps"] as? [String : AnyObject] else {return}
            guard let url = URL(string: aps["link_url"] as? String ?? "") else {return}
            if let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                if let rootVC = scene.window?.rootViewController as? UINavigationController {
                    if let vc = rootVC.viewControllers.first as? ViewController {
                        vc.present(SafariViewController(url: url), animated: true)
                    }
                }
            }
        default:
            break
        }
    }
}
