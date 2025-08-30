import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func applicationDidBecomeActive(_ application: UIApplication) {
        UNUserNotificationCenter.current()
            .setBadgeCount(0, withCompletionHandler: nil)
    }
}
