import UIKit
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        application.applicationIconBadgeNumber = 0
        
        NotificationManager.shared.requestPermission()
        
        return true
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
      
        application.applicationIconBadgeNumber = 0
        NotificationManager.shared.clearBadge()
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        print("App became active - badge cleared")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        let habits = DatabaseManager.shared.habits
        NotificationManager.shared.handleAppDidEnterBackground(with: habits)
        
        print("App entered background - progress warnings scheduled")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        NotificationManager.shared.handleAppWillEnterForeground()
        
        print("App entering foreground - badge cleared")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(.newData)
    }
}
