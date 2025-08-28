import SwiftUI

struct HabitCard: View {
    var habit: Habit
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            // Adaptive progress indicator circle
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: colorScheme == .dark ?
                                [Color.cyan.opacity(0.4), Color.blue.opacity(0.2)] :
                                [Color.blue.opacity(0.3), Color.blue.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 50, height: 50)
                
                Text("\(Int(habit.progressPercentage * 100))%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .cyan : .blue)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(habit.title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: colorScheme == .dark ? [
                                    Color.white,
                                    Color(red: 0.9, green: 0.9, blue: 0.95)
                                ] : [
                                    Color(red: 0.2, green: 0.2, blue: 0.3),
                                    Color(red: 0.3, green: 0.3, blue: 0.4)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Spacer()
                    
                    // Adaptive status badge
                    HStack(spacing: 4) {
                        Circle()
                            .fill(habit.isActive ? Color.green : Color.red)
                            .frame(width: 6, height: 6)
                        
                        Text(habit.isActive ? "Active" : "Ended")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(habit.isActive ? .green : .red)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill((habit.isActive ? Color.green : Color.red).opacity(colorScheme == .dark ? 0.2 : 0.1))
                    )
                }
                
                if !habit.description.isEmpty {
                    Text(habit.description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor((colorScheme == .dark ? Color.cyan : Color.blue).opacity(0.7))
                        
                        Text("\(habit.startDate, style: .date)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor((colorScheme == .dark ? Color.cyan : Color.blue).opacity(0.8))
                    }
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 10))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flag.checkered")
                            .font(.system(size: 12))
                            .foregroundColor(.purple.opacity(0.7))
                        
                        Text("\(habit.endDate, style: .date)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.purple.opacity(0.8))
                    }
                }
                
                Text("⏳ \(habit.daysRemaining) days left")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.orange)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: colorScheme == .dark ? [
                            Color(red: 0.12, green: 0.12, blue: 0.18),
                            Color(red: 0.15, green: 0.15, blue: 0.2)
                        ] : [
                            Color.white,
                            Color(red: 0.99, green: 0.99, blue: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(
                    color: colorScheme == .dark ?
                        Color.black.opacity(0.3) :
                        Color.black.opacity(0.05),
                    radius: colorScheme == .dark ? 10 : 8,
                    x: 0,
                    y: 2
                )
        )
    }
}
