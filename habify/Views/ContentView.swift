import SwiftUI

struct ContentView: View {
    @StateObject private var databaseManager = DatabaseManager.shared
    @State private var selectedTab: Int = 0
    @State private var showAddHabit: Bool = false
    @State private var fabScale: CGFloat = 1.0
    
    func deleteHabit(_ habit: Habit) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            databaseManager.deleteHabit(habit)
        }
    }
    
    private func filteredHabits() -> [Habit] {
        let today = Calendar.current.startOfDay(for: Date())
        
        switch selectedTab {
        case 0: // Today
            return databaseManager.habits.filter { habit in
                let habitStart = Calendar.current.startOfDay(for: habit.startDate)
                let habitEnd = Calendar.current.startOfDay(for: habit.endDate)
                return today >= habitStart && today <= habitEnd
            }
        case 1: // Weekly
            guard let weekInterval = Calendar.current.dateInterval(of: .weekOfYear, for: today) else {
                return []
            }
            return databaseManager.habits.filter { habit in
                habit.startDate <= weekInterval.end && habit.endDate >= weekInterval.start
            }
        case 2: // Monthly
            guard let monthInterval = Calendar.current.dateInterval(of: .month, for: today) else {
                return []
            }
            return databaseManager.habits.filter { habit in
                habit.startDate <= monthInterval.end && habit.endDate >= monthInterval.start
            }
        default:
            return databaseManager.habits
        }
    }
    
    private var headerView: some View {
        Group {
            let filteredList = filteredHabits()
            let totalHabits = filteredList.count
            VStack(alignment: .leading, spacing: 16) {
                // Welcome text with modern styling
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome back 👋")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text("Habify")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.2, green: 0.2, blue: 0.3),
                                        Color(red: 0.4, green: 0.4, blue: 0.5)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    
                    Spacer()
                    
                    // Stats summary with completion rate
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(totalHabits)/")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.blue)
                        
                        Text("habits")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.1))
                    )
                }
                
                // Modern segmented picker
                HStack(spacing: 0) {
                    ForEach(0..<3) { index in
                        let titles = ["Today", "Weekly", "Monthly"]
                        let icons = ["sun.max", "calendar.badge.clock", "calendar"]
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = index
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: icons[index])
                                    .font(.system(size: 14, weight: .medium))
                                
                                Text(titles[index])
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(selectedTab == index ? .white : .secondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedTab == index ?
                                        LinearGradient(
                                            colors: [Color.blue, Color.blue.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) :
                                        LinearGradient(
                                            colors: [Color.clear, Color.clear],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.1))
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            // Animated empty state icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "target")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(.blue.opacity(0.6))
            }
            
            VStack(spacing: 8) {
                Text("No habits yet")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Start building your daily habits\nby tapping the + button below")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.white,
                    Color(red: 0.98, green: 0.98, blue: 1.0),
                    Color(red: 0.96, green: 0.97, blue: 0.99)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        let list = filteredHabits()
                        
                        if list.isEmpty {
                            emptyStateView
                        } else {
                            ForEach(Array(list.enumerated()), id: \.element.id) { index, habit in
                                EnhancedHabitCard(habit: habit)
                                    .transition(.asymmetric(
                                        insertion: .scale.combined(with: .opacity),
                                        removal: .scale.combined(with: .opacity)
                                    ))
                                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.05), value: list.count)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            deleteHabit(habit)
                                        } label: {
                                            Label("Delete Habit", systemImage: "trash")
                                        }
                                        
//                                        Button {
//                                            // TODO: Implement edit functionality
//                                        } label: {
//                                            Label("Edit Habit", systemImage: "pencil")
//                                        }
                                    }
                            }
                            
                            // Bottom padding for FAB
                            Color.clear.frame(height: 100)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            
            // Modern Floating Action Button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    fabScale = 0.9
                    showAddHabit = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        fabScale = 1.0
                    }
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                    
                    if !filteredHabits().isEmpty {
                        Text("Add Habit")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, filteredHabits().isEmpty ? 18 : 20)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: filteredHabits().isEmpty ? 30 : 25)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(
                            color: Color.blue.opacity(0.3),
                            radius: 12,
                            x: 0,
                            y: 6
                        )
                )
            }
            .scaleEffect(fabScale)
            .padding(.trailing, 20)
            .padding(.bottom, 34)
            .sheet(isPresented: $showAddHabit) {
                // HAPUS onSave callback - biarkan DatabaseManager yang handle
                AddHabitView()
            }
        }
        .onAppear {
            // Refresh data when view appears
            databaseManager.loadHabits()
        }
        .refreshable {
            // Add pull to refresh functionality
            databaseManager.loadHabits()
        }
    }
}

// MARK: - Enhanced Habit Card with SQLite Integration
struct EnhancedHabitCard: View {
    var habit: Habit
    
    var body: some View {
        HStack(spacing: 16) {
            // Progress indicator circle
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 50, height: 50)
                
                Text("\(Int(habit.progressPercentage * 100))%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.blue)
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
                    
                    Spacer()
                    
                    // Status badge
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
                            .fill((habit.isActive ? Color.green : Color.red).opacity(0.1))
                    )
                }
                
                if !habit.description.isEmpty {
                    Text(habit.description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Date range
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
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
                
                // Days remaining
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
                        colors: [
                            Color.white,
                            Color(red: 0.99, green: 0.99, blue: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(
                    color: Color.black.opacity(0.05),
                    radius: 8,
                    x: 0,
                    y: 2
                )
        )
    }
}
