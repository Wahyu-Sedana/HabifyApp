import SwiftUI

struct ContentView: View {
    @StateObject private var databaseManager = DatabaseManager.shared
    @State private var selectedTab: Int = 0
    @State private var showAddHabit: Bool = false
    @State private var fabScale: CGFloat = 1.0
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var selectedHabitForDetail: Habit? = nil
    @State private var isDetailViewPresented = false
    
    @State private var selectedHabitForEdit: Habit? = nil
    @State private var isEditSheetPresented = false
    
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())

    func deleteHabit(_ habit: Habit) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            databaseManager.deleteHabit(habit)
        }
    }
    
    private func updateHabit(_ habit: Habit) {
        databaseManager.updateHabit(habit)
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
            var components = DateComponents()
            components.year = selectedYear
            components.month = selectedMonth
            guard let monthStart = Calendar.current.date(from: components),
                  let monthInterval = Calendar.current.dateInterval(of: .month, for: monthStart) else {
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
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text("Welcome back")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                            Image(systemName: "hand.wave.fill")
                                .foregroundColor(.orange)
                        }
                        Text("Habify")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
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
                    }
                    
                    Spacer()
                    
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
                                            colors: colorScheme == .dark ?
                                                [Color.blue.opacity(0.8), Color.cyan.opacity(0.6)] :
                                                [Color.blue, Color.blue.opacity(0.8)],
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
                        .fill(colorScheme == .dark ?
                              Color(red: 0.15, green: 0.15, blue: 0.2) :
                              Color.gray.opacity(0.1)
                        )
                )
                
                if selectedTab == 2 {
                    HStack(spacing: 12) {
                        Menu {
                            ForEach(1...12, id: \.self) { month in
                                Button(action: {
                                    withAnimation(.spring()) {
                                        selectedMonth = month
                                    }
                                }) {
                                    Text(DateFormatter().monthSymbols[month-1])
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "calendar")
                                Text(DateFormatter().monthSymbols[selectedMonth-1])
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().fill(Color.blue.opacity(0.1))
                            )
                        }
                        
                        Menu {
                            let currentYear = Calendar.current.component(.year, from: Date())
                            ForEach(currentYear...(currentYear+5), id: \.self) { year in
                                Button(action: {
                                    withAnimation(.spring()) {
                                        selectedYear = year
                                    }
                                }) {
                                    Text(String(year))
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "clock")
                                Text(String(selectedYear))
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.purple)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().fill(Color.purple.opacity(0.1))
                            )
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: colorScheme == .dark ?
                                [Color.blue.opacity(0.2), Color.purple.opacity(0.1)] :
                                [Color.blue.opacity(0.1), Color.purple.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "target")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(.blue.opacity(colorScheme == .dark ? 0.8 : 0.6))
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
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                LinearGradient(
                    colors: colorScheme == .dark ? [
                        Color(red: 0.05, green: 0.05, blue: 0.1),
                        Color(red: 0.08, green: 0.08, blue: 0.12),
                        Color(red: 0.06, green: 0.06, blue: 0.11)
                    ] : [
                        Color.white,
                        Color(red: 0.98, green: 0.98, blue: 1.0),
                        Color(red: 0.96, green: 0.97, blue: 0.99)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerView
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 16) {
                            let list = filteredHabits()
                            
                            if list.isEmpty {
                                emptyStateView
                            } else {
                                ForEach(Array(list.enumerated()), id: \.element.id) { index, habit in
                                    HabitCard(habit: habit)
                                        .onTapGesture {
                                            selectedHabitForDetail = habit
                                            isDetailViewPresented = true
                                        }
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
                                            
                                            Button {
                                                selectedHabitForEdit = habit
                                                isEditSheetPresented = true
                                            } label: {
                                                Label("Edit Habit", systemImage: "pencil")
                                            }
                                        }
                                }
                                
                                Color.clear.frame(height: 100)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
                
                // FAB button
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
                                    colors: colorScheme == .dark ?
                                        [Color.cyan.opacity(0.8), Color.blue.opacity(0.7)] :
                                        [Color.blue, Color.blue.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(
                                color: (colorScheme == .dark ? Color.cyan : Color.blue).opacity(0.3),
                                radius: 12,
                                x: 0,
                                y: 6
                            )
                    )
                }
                .scaleEffect(fabScale)
                .padding(.trailing, 20)
                .padding(.bottom, 34)
                
                // Navigation Link untuk Detail View (hidden)
                NavigationLink(
                    destination: selectedHabitForDetail.map { habit in
                        HabitDetailView(habit: habit)
                            .environmentObject(databaseManager)
                    },
                    isActive: $isDetailViewPresented,
                    label: { EmptyView() }
                )
                .hidden()
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Force stack navigation on all devices
        .onAppear {
            databaseManager.loadHabits()
        }
        .refreshable {
            databaseManager.loadHabits()
        }
        .sheet(isPresented: $showAddHabit) {
            AddHabitView()
        }
        .sheet(isPresented: $isEditSheetPresented) {
            if let habitToEdit = selectedHabitForEdit {
                EditHabitView(habit: habitToEdit)
                    .environmentObject(databaseManager)
            }
        }
        .onChange(of: isEditSheetPresented) { isPresented in
            if !isPresented {
                selectedHabitForEdit = nil
            }
        }
        .onChange(of: isDetailViewPresented) { isPresented in
            if !isPresented {
                selectedHabitForDetail = nil
            }
        }
    }
}
