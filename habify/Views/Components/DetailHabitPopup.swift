import Foundation
import SwiftUI

struct DetailHabitPopup: View {
    let habit: Habit
    var onClose: () -> Void
    var onEdit: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    @State private var animateContent = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header dengan gradient dan close button
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: colorScheme == .dark ? [
                                    Color.white,
                                    Color(red: 0.9, green: 0.95, blue: 1.0)
                                ] : [
                                    Color(red: 0.2, green: 0.2, blue: 0.3),
                                    Color(red: 0.4, green: 0.4, blue: 0.5)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Habit Details")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(colorScheme == .dark ?
                                      Color(red: 0.2, green: 0.2, blue: 0.25) :
                                      Color.gray.opacity(0.1)
                                )
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 20)
            
            // Content
            VStack(spacing: 20) {
                // Description card
                if !habit.description.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "text.alignleft")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.blue)
                            
                            Text("Description")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        Text(habit.description)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                            .lineSpacing(2)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                colorScheme == .dark ?
                                    Color(red: 0.15, green: 0.15, blue: 0.2) :
                                    Color.blue.opacity(0.05)
                            )
                    )
                }
                
                // Date range card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.green)
                        
                        Text("Duration")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    HStack(spacing: 16) {
                        // Start date
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Start Date")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text(habit.startDate, formatter: modernDateFormatter)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    colorScheme == .dark ?
                                        Color(red: 0.1, green: 0.2, blue: 0.15) :
                                        Color.green.opacity(0.08)
                                )
                        )
                        
                        // Arrow
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        // End date
                        VStack(alignment: .leading, spacing: 4) {
                            Text("End Date")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text(habit.endDate, formatter: modernDateFormatter)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    colorScheme == .dark ?
                                        Color(red: 0.2, green: 0.1, blue: 0.15) :
                                        Color.red.opacity(0.08)
                                )
                        )
                    }
                    
                    // Days count
                    let daysDifference = Calendar.current.dateComponents([.day], from: habit.startDate, to: habit.endDate).day ?? 0
                    
                    HStack {
                        Image(systemName: "clock.badge.checkmark")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.purple)
                        
                        Text("\(daysDifference + 1) days total")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Status indicator
                        let today = Date()
                        let status = getHabitStatus(startDate: habit.startDate, endDate: habit.endDate, currentDate: today)
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(status.color)
                                .frame(width: 8, height: 8)
                            
                            Text(status.text)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(status.color)
                        }
                    }
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            colorScheme == .dark ?
                                Color(red: 0.15, green: 0.15, blue: 0.2) :
                                Color.gray.opacity(0.05)
                        )
                )
                
                // Action buttons
                HStack(spacing: 12) {
                    Button(action: onEdit) {
                        HStack(spacing: 8) {
                            Image(systemName: "pencil")
                                .font(.system(size: 14, weight: .medium))
                            Text("Edit")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.blue.opacity(0.1))
                        )
                    }
                    
                    Button(action: onClose) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .medium))
                            Text("Done")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: colorScheme == .dark ?
                                            [Color.cyan.opacity(0.8), Color.blue.opacity(0.7)] :
                                            [Color.blue, Color.blue.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                    }
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    colorScheme == .dark ?
                        Color(red: 0.08, green: 0.08, blue: 0.12) :
                        Color(.systemBackground)
                )
                .shadow(
                    color: colorScheme == .dark ?
                        Color.black.opacity(0.3) :
                        Color.black.opacity(0.1),
                    radius: 20,
                    x: 0,
                    y: 8
                )
        )
        .padding(.horizontal, 32)
        .scaleEffect(animateContent ? 1.0 : 0.9)
        .opacity(animateContent ? 1.0 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                animateContent = true
            }
        }
    }
    
    private func getHabitStatus(startDate: Date, endDate: Date, currentDate: Date) -> (text: String, color: Color) {
        let today = Calendar.current.startOfDay(for: currentDate)
        let start = Calendar.current.startOfDay(for: startDate)
        let end = Calendar.current.startOfDay(for: endDate)
        
        if today < start {
            return ("Upcoming", .orange)
        } else if today > end {
            return ("Completed", .gray)
        } else {
            return ("Active", .green)
        }
    }
}

private let modernDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()
