import SwiftUI

struct HabitDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var databaseManager: DatabaseManager
    
    @State var habit: Habit
    @State private var showEditSheet = false
    @State private var showAddTaskSheet = false
    @State private var newTaskTitle = ""
    
    private func addTask() {
        guard !newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let habitId = habit.id else { return }
        
        let newTask = HabitTask(title: newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines))
        if let insertedTask = databaseManager.addTaskToHabit(newTask, habitId: habitId) {
            habit.tasks.append(insertedTask)
        }
        
        newTaskTitle = ""
        showAddTaskSheet = false
    }
    
    
    private func toggleTaskCompletion(_ task: HabitTask) {
        guard let habitId = habit.id,
              let index = habit.tasks.firstIndex(where: { $0.id == task.id }) else { return }
        
        habit.tasks[index].isCompleted.toggle()
        
        databaseManager.updateTask(habit.tasks[index], for: habitId)
        
        let allTasksCompleted = !habit.tasks.isEmpty && habit.tasks.allSatisfy { $0.isCompleted }
        if allTasksCompleted {
            NotificationManager.shared.scheduleTaskCompletionNotification(for: habit)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 20) {
            // Navigation Bar
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button(action: {
                    showEditSheet = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14, weight: .medium))
                        Text("Edit")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue)
                    )
                }
            }
            
            // Habit Info Card
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(habit.title)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Text(habit.description)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                }
                
                // Progress Section
                VStack(spacing: 12) {
                    HStack {
                        Text("Progress")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(Int(habit.progressPercentage * 100))%")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    
                    // Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(colorScheme == .dark ?
                                      Color.gray.opacity(0.3) :
                                      Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue, Color.cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * habit.progressPercentage, height: 8)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: habit.progressPercentage)
                        }
                    }
                    .frame(height: 8)
                    
                    // Stats
                    HStack(spacing: 20) {
                        VStack(spacing: 4) {
                            Text("\(habit.tasks.filter { $0.isCompleted }.count)")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.green)
                            Text("Completed")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(habit.tasks.count)")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.blue)
                            Text("Total Tasks")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text("\(habit.daysRemaining)")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.orange)
                            Text("Days Left")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ?
                          Color(red: 0.15, green: 0.15, blue: 0.2) :
                          Color.white)
                    .shadow(
                        color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1),
                        radius: 10,
                        x: 0,
                        y: 5
                    )
            )
        }
    }
    
    private var tasksSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Tasks")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    showAddTaskSheet = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                        Text("Add Task")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [Color.green, Color.green.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                }
            }
            
            if habit.tasks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checklist")
                        .font(.system(size: 30, weight: .light))
                        .foregroundColor(.gray.opacity(0.6))
                    
                    Text("No tasks yet")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("Add your first task to get started")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .dark ?
                              Color.gray.opacity(0.1) :
                              Color.gray.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    Color.gray.opacity(0.2),
                                    style: StrokeStyle(lineWidth: 1, dash: [5])
                                )
                        )
                )
            } else {
                List {
                    ForEach(Array(habit.tasks.enumerated()), id: \.element.id) { index, task in
                        TaskRowView(
                            task: task,
                            onToggle: { toggleTaskCompletion(task) },
                            onDelete: {
                                guard let habitId = habit.id else { return }
                                databaseManager.deleteTask(task, from: habitId)
                                habit.tasks.remove(at: index)
                            }
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                    }
                }
                .listStyle(PlainListStyle())
                .frame(height: CGFloat(habit.tasks.count * 60))
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background
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
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    headerView
                    tasksSection
                    
                    Color.clear.frame(height: 50)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showEditSheet) {
            EditHabitView(habit: habit)
                .environmentObject(databaseManager)
        }
        .sheet(isPresented: $showAddTaskSheet) {
            NavigationView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add New Task")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Add a task to track your habit progress")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task Title")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        TextField("Enter task title...", text: $newTaskTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: 16))
                    }
                    
                    Spacer()
                }
                .padding(20)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            newTaskTitle = ""
                            showAddTaskSheet = false
                        }
                        .foregroundColor(.red)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Add") {
                            addTask()
                        }
                        .foregroundColor(.blue)
                        .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .presentationDetents([.height(300)])
        }
        .onChange(of: showEditSheet) { isPresented in
            if !isPresented {
                    if let updatedHabit = databaseManager.habits.first(where: { $0.id == habit.id }) {
                    habit = updatedHabit
                }
            }
        }
    }
}

// MARK: - TaskRowView
struct TaskRowView: View {
    let task: HabitTask
    let onToggle: () -> Void
    let onDelete: (() -> Void)?
    @Environment(\.colorScheme) private var colorScheme
    
    init(task: HabitTask, onToggle: @escaping () -> Void, onDelete: (() -> Void)? = nil) {
       self.task = task
       self.onToggle = onToggle
       self.onDelete = onDelete
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(task.isCompleted ? .green : .gray.opacity(0.6))
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(task.title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(task.isCompleted ? .secondary : .primary)
                .strikethrough(task.isCompleted)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if task.isCompleted {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.green)
            }
            if let deleteAction = onDelete {
                Button(action: deleteAction) {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.leading, 8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    task.isCompleted ?
                    Color.green.opacity(colorScheme == .dark ? 0.15 : 0.08) :
                    (colorScheme == .dark ?
                     Color(red: 0.15, green: 0.15, blue: 0.2) :
                     Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            task.isCompleted ?
                            Color.green.opacity(0.3) :
                            Color.clear,
                            lineWidth: 1
                        )
                )
        )
        .scaleEffect(task.isCompleted ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: task.isCompleted)
    }
}
