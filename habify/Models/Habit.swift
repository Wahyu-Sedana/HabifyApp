import Foundation
import SwiftUI

// MARK: - HabitTask Model
struct HabitTask: Identifiable, Codable, Equatable {
    var id: Int?
    var title: String
    var isCompleted: Bool = false
    var createdAt: Date = Date()
    
    init(title: String, isCompleted: Bool = false) {
        self.id = nil
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = Date()
    }
    init(id: Int, title: String, isCompleted: Bool, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}

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
    
    var tasks: [HabitTask] = []
    
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
        }(),
        tasks: [HabitTask] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.reminderEnabled = reminderEnabled
        self.reminderTime = reminderTime
        self.tasks = tasks
    }
    
    // MARK: - Computed
    
    var isActive: Bool {
        let today = Date()
        return today >= startDate && today <= endDate
    }
    
    var daysRemaining: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let end = Calendar.current.startOfDay(for: endDate)
        return max(0, Calendar.current.dateComponents([.day], from: today, to: end).day ?? 0)
    }
    
    /// Progress berdasarkan checklist task, bukan hari
    var progressPercentage: Double {
        guard !tasks.isEmpty else { return 0.0 }
        let completedCount = tasks.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(tasks.count)
    }
}
