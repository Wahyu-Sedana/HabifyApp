import Foundation
import SwiftUI

// MARK: - Habit Model
struct Habit: Identifiable, Codable, Equatable {
    var id: Int?
    var title: String
    var description: String
    var startDate: Date
    var endDate: Date
    var reminderEnabled: Bool = false
    var reminderTime: Date = {
            var components = DateComponents()
            components.hour = 9
            components.minute = 0
            return Calendar.current.date(from: components) ?? Date()
        }()
    
    init(
        id: Int?,
        title: String,
        description: String,
        startDate: Date,
        endDate: Date,
        reminderEnabled: Bool = false,
        reminderTime: Date = {
                var components = DateComponents()
                components.hour = 9
                components.minute = 0
                return Calendar.current.date(from: components) ?? Date()
            }()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.reminderEnabled = reminderEnabled
        self.reminderTime = reminderTime
    }
    
    // Computed
    var isActive: Bool {
        let today = Date()
        return today >= startDate && today <= endDate
    }
    
    var daysRemaining: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let end = Calendar.current.startOfDay(for: endDate)
        return max(0, Calendar.current.dateComponents([.day], from: today, to: end).day ?? 0)
    }
    
    var progressPercentage: Double {
        let today = Calendar.current.startOfDay(for: Date())
        let start = Calendar.current.startOfDay(for: startDate)
        let end = Calendar.current.startOfDay(for: endDate)
        
        guard today >= start else { return 0.0 }
        guard today <= end else { return 1.0 }
        
        let totalDays = Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
        let elapsedDays = Calendar.current.dateComponents([.day], from: start, to: today).day ?? 0
        return totalDays > 0 ? Double(elapsedDays) / Double(totalDays) : 0.0
    }
}
