import SwiftUI

@main
struct HabifyApp: App {
    @StateObject private var databaseManager = DatabaseManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(databaseManager)
                .environmentObject(notificationManager)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    handleAppWillEnterForeground()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    handleAppDidEnterBackground()
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("NavigateToHabit"))) { notification in
                    handleHabitNavigation(notification)
                }
                .onAppear {
                    setupInitialState()
                }
        }
    }
    
    private func setupInitialState() {
        notificationManager.clearBadge()
        databaseManager.loadHabits()
    }
    
    private func handleAppWillEnterForeground() {
        print("App entering foreground")
        notificationManager.handleAppWillEnterForeground()
        
        databaseManager.loadHabits()
    }
    
    private func handleAppDidEnterBackground() {
        print("App entering background")
        notificationManager.handleAppDidEnterBackground(with: databaseManager.habits)
    }
    
    private func handleHabitNavigation(_ notification: Notification) {
        if let habitId = notification.userInfo?["habitId"] as? Int {
            print("Navigate to habit with ID: \(habitId)")
        }
    }
}
