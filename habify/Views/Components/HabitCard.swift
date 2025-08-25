import SwiftUI

struct HabitCard: View {
    var habit: Habit
    @State private var isCompleted = false
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: isCompleted ?
                                [Color.green.opacity(0.3), Color.green.opacity(0.1)] :
                                [Color.gray.opacity(0.2), Color.gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 50, height: 50)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isCompleted ?
                                [Color.green, Color.green.opacity(0.8)] :
                                [Color.gray.opacity(0.1), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .scaleEffect(isCompleted ? 1.0 : 0.1)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isCompleted)
                
                Image(systemName: isCompleted ? "checkmark" : "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(isCompleted ? .white : .gray.opacity(0.6))
                    .scaleEffect(scale)
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    isCompleted.toggle()
                    scale = 0.8
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        scale = 1.0
                    }
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(habit.title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.2, green: 0.2, blue: 0.3),
                                    Color(red: 0.3, green: 0.3, blue: 0.4)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .strikethrough(isCompleted, color: .gray)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(isCompleted ? Color.green : Color.orange)
                            .frame(width: 6, height: 6)
                        
                        Text(isCompleted ? "Done" : "Active")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(isCompleted ? .green : .orange)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill((isCompleted ? Color.green : Color.orange).opacity(0.1))
                    )
                }
                
                if !habit.description.isEmpty {
                    Text(habit.description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .opacity(isCompleted ? 0.6 : 1.0)
                }
                
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 12))
                            .foregroundColor(.blue.opacity(0.7))
                        
                        Text("\(habit.startDate, style: .date)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.blue.opacity(0.8))
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
                .opacity(isCompleted ? 0.6 : 0.8)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white,
                            Color(red: 0.99, green: 0.99, blue: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(
                    color: Color.black.opacity(isCompleted ? 0.05 : 0.08),
                    radius: isCompleted ? 8 : 12,
                    x: 0,
                    y: isCompleted ? 2 : 4
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.8),
                            Color.gray.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .scaleEffect(isCompleted ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCompleted)
    }
}
