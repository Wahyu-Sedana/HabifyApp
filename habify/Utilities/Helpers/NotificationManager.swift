import Foundation
import SwiftUI
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {
        requestPermission()
        setupNotificationDelegate()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted")
                } else {
                    print("Notification permission denied")
                }
                
                if let error = error {
                    print("Notification permission error: \(error)")
                }
            }
        }
    }
    
    private func setupNotificationDelegate() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    
    // MARK: - Progress Tracking Notifications
    
    func scheduleProgressWarning(for habit: Habit, type: ProgressWarningType) {
        let content = UNMutableNotificationContent()
        let (title, body) = getProgressWarningMessage(for: habit, type: type)
        
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        content.userInfo = [
            "habitId": habit.id ?? 0,
            "habitTitle": habit.title,
            "type": "progress_warning",
            "warningType": type.rawValue
        ]

        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )
        
        let identifier = "progress_warning_\(habit.id ?? 0)_\(type.rawValue)_\(Date().timeIntervalSince1970)"
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling progress warning: \(error)")
            } else {
                print("Progress warning scheduled for habit: \(habit.title) - \(type.rawValue)")
            }
        }
    }
    
    func scheduleTaskCompletionNotification(for habit: Habit) {
        let allTasksCompleted = !habit.tasks.isEmpty && habit.tasks.allSatisfy { $0.isCompleted }
        
        guard allTasksCompleted else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🎉 All Tasks Completed!"
        content.body = "Congratulations! You've completed all tasks for \(habit.title) today!"
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        content.userInfo = [
            "habitId": habit.id ?? 0,
            "habitTitle": habit.title,
            "type": "task_completion"
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let identifier = "task_completion_\(habit.id ?? 0)_\(Date().timeIntervalSince1970)"
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling task completion notification: \(error)")
            } else {
                print("Task completion notification scheduled for habit: \(habit.title)")
            }
        }
    }
    
    // MARK: - Progress Monitoring
    
    func checkAndScheduleProgressWarnings(for habits: [Habit]) {
        for habit in habits {
            guard habit.isActive && !habit.tasks.isEmpty else { continue }
            
            let lastProgressDate = getLastProgressDate(for: habit)
            let daysSinceProgress = getDaysSince(lastProgressDate)
            
            if daysSinceProgress >= 30 {
                scheduleProgressWarning(for: habit, type: .monthly)
            } else if daysSinceProgress >= 7 {
                scheduleProgressWarning(for: habit, type: .weekly)
            } else if daysSinceProgress >= 1 {
                scheduleProgressWarning(for: habit, type: .daily)
            }
        }
    }
    
    private func getLastProgressDate(for habit: Habit) -> Date {
        let completedTasks = habit.tasks.filter { $0.isCompleted }
        
        if completedTasks.isEmpty {
            return habit.startDate
        }
        
        return Date()
    }
    
    private func getDaysSince(_ date: Date) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: date)
        
        return calendar.dateComponents([.day], from: targetDate, to: today).day ?? 0
    }
    
    private func getProgressWarningMessage(for habit: Habit, type: ProgressWarningType) -> (String, String) {
        switch type {
        case .daily:
            return ("📅 Daily Check-in", "No progress on \(habit.title) since yesterday. Keep your momentum going!")
            
        case .weekly:
            return ("⚠️ Weekly Reminder", "It's been a week without progress on \(habit.title). Time to get back on track!")
            
        case .monthly:
            return ("🚨 Monthly Alert", "A whole month without progress on \(habit.title). Don't let your goals slip away!")
        }
    }
    
    // MARK: - Badge Management
    
    func clearBadge() {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        
        // Also clear delivered notifications
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    func setBadgeCount(_ count: Int) {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }
    
    // MARK: - Notification Management
    
    func cancelProgressWarnings(for habit: Habit) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiersToCancel = requests.compactMap { request in
                let userInfo = request.content.userInfo
                if let habitId = userInfo["habitId"] as? Int,
                   habitId == habit.id,
                   let type = userInfo["type"] as? String,
                   type == "progress_warning" {
                    return request.identifier
                }
                return nil
            }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        clearBadge()
    }
    
    func checkPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
}

// MARK: - Supporting Types

enum ProgressWarningType: String, CaseIterable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
}

// MARK: - Notification Delegate

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    private override init() {
        super.init()
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        if let type = userInfo["type"] as? String {
            switch type {
            case "progress_warning":
                handleProgressWarningTap(userInfo: userInfo)
            case "task_completion":
                handleTaskCompletionTap(userInfo: userInfo)
            default:
                break
            }
        }
        
        NotificationManager.shared.clearBadge()
        
        completionHandler()
    }
    
    private func handleProgressWarningTap(userInfo: [AnyHashable: Any]) {
        if let habitId = userInfo["habitId"] as? Int {
            print("User tapped progress warning for habit ID: \(habitId)")
            NotificationCenter.default.post(
                name: Notification.Name("NavigateToHabit"),
                object: nil,
                userInfo: ["habitId": habitId]
            )
        }
    }
    
    private func handleTaskCompletionTap(userInfo: [AnyHashable: Any]) {
        if let habitId = userInfo["habitId"] as? Int {
            print("User tapped task completion for habit ID: \(habitId)")
        }
    }
}

// MARK: - App Lifecycle Integration

extension NotificationManager {
    func handleAppWillEnterForeground() {
        clearBadge()
    }
    
    func handleAppDidEnterBackground(with habits: [Habit]) {
        checkAndScheduleProgressWarnings(for: habits)
    }
}
