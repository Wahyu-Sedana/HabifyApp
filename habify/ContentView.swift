import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    @State private var habits: [Habit] = []
    @State private var showAddHabit: Bool = false
    
    func deleteHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits.remove(at: index)
        }
    }
    
    private func filteredHabits() -> [Habit] {
        let today = Date()
        let calendar = Calendar.current
        
        switch selectedTab {
        case 0: // Today
            return habits.filter { habit in
                    let today = Date()
                    return Calendar.current.isDate(today, inSameDayAs: habit.startDate)
                        || (today >= habit.startDate && today <= habit.endDate)
                
            }
        case 1: // Weekly
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else { return [] }
            return habits.filter { habit in
                habit.startDate <= weekInterval.end && habit.endDate >= weekInterval.start
            }
        case 2: // Monthly
            guard let monthInterval = calendar.dateInterval(of: .month, for: today) else { return [] }
            return habits.filter { habit in
                habit.startDate <= monthInterval.end && habit.endDate >= monthInterval.start
            }
        default:
            return habits
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("Welcome back, Habify 👋")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                    .padding(.horizontal)
                

                Picker("", selection: $selectedTab) {
                    Text("Today").tag(0)
                    Text("Weekly").tag(1)
                    Text("Monthly").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                List {
                    let list = filteredHabits()
                    
                    if list.isEmpty {
                        Text("No habits found")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .listRowSeparator(.hidden)
                    } else {
                        ForEach(list) { habit in
                            VStack(spacing: 16) {
                                ForEach(list) { habit in
                                    HabitCard(habit: habit)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                deleteHabit(habit)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                            .tint(.red)
                                        }
                                        .listRowSeparator(.hidden)
                                }
                            }

                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            
            Button(action: {
                showAddHabit = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                    .background(AppColorTheme.textColor)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            .padding()
            .sheet(isPresented: $showAddHabit) {
                AddHabitView { newHabit in
                    habits.append(newHabit)
                }
            }
        }
    }
}
