import Foundation
import SwiftUI
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {
        requestPermission()
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
    
    func scheduleHabitReminder(for habit: Habit, at time: Date) {
        let content = UNMutableNotificationContent()
        content.title = "🎯 Habit Reminder"
        content.body = "Time to work on: \(habit.title)"
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        content.userInfo = [
            "habitId": habit.id ?? 0,
            "habitTitle": habit.title,
            "type": "habit_reminder"
        ]
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )

        let identifier = "habit_reminder_\(habit.id ?? 0)"
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled for habit: \(habit.title)")
            }
        }
    }
    
    func scheduleCompletionNotification(for habit: Habit, streak: Int) {
        let content = UNMutableNotificationContent()
        let (title, body, _) = getStreakMessage(streak: streak, habitTitle: habit.title)
        
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        content.userInfo = [
            "habitId": habit.id ?? 0,
            "streak": streak,
            "type": "completion_celebration"
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let identifier = "completion_\(habit.id ?? 0)_\(Date().timeIntervalSince1970)"
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleMissedDayNotification(for habit: Habit) {
        let content = UNMutableNotificationContent()
        content.title = "💪 Don't Give Up!"
        content.body = "You missed \(habit.title) yesterday. Get back on track today!"
        content.sound = UNNotificationSound.default
        
        content.userInfo = [
            "habitId": habit.id ?? 0,
            "type": "missed_day_motivation"
        ]
        
        var components = DateComponents()
        components.hour = 8
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )
        
        let identifier = "missed_day_\(habit.id ?? 0)_\(Date().timeIntervalSince1970)"
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotifications(for habit: Habit) {
        let identifiers = [
            "habit_reminder_\(habit.id ?? 0)",
        ]
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    private func getStreakMessage(streak: Int, habitTitle: String) -> (String, String, String) {
        switch streak {
        case 1:
            return ("🎉 Great Start!", "You completed \(habitTitle) today! Keep it up!", "🎯")
        case 3:
            return ("🔥 3 Days Strong!", "You're building momentum with \(habitTitle)!", "💪")
        case 7:
            return ("⭐ Week Champion!", "7 days of \(habitTitle)! You're on fire!", "🏆")
        case 14:
            return ("💎 Two Weeks!", "14 days of consistency with \(habitTitle)!", "🎖️")
        case 30:
            return ("🏆 Monthly Master!", "30 days of \(habitTitle)! Incredible dedication!", "👑")
        case 50:
            return ("🚀 Habit Hero!", "50 days of \(habitTitle)! You're unstoppable!", "🌟")
        case 100:
            return ("👑 Century Club!", "100 days of \(habitTitle)! Legendary!", "🎊")
        default:
            if streak % 10 == 0 {
                return ("🎯 \(streak) Days!", "Amazing consistency with \(habitTitle)!", "✨")
            } else {
                return ("✅ Well Done!", "Another day of \(habitTitle) completed!", "👏")
            }
        }
    }
    
    func checkPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
}
