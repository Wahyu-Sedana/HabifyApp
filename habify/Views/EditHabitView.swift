import SwiftUI

struct EditHabitView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var databaseManager: DatabaseManager
    
    var habit: Habit
    
    @State private var title: String
    @State private var description: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var selectedColor: Color
    
    // Animation states
    @State private var showValidationError: Bool = false
    @State private var saveButtonScale: CGFloat = 1.0
    @State private var formOffset: CGFloat = 0

    init(habit: Habit) {
        self.habit = habit
        _title = State(initialValue: habit.title)
        _description = State(initialValue: habit.description)
        _startDate = State(initialValue: habit.startDate)
        _endDate = State(initialValue: habit.endDate)
        _selectedColor = State(initialValue: .blue)
    }
    
    // Validation
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        endDate > startDate
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Adaptive background gradient - same as AddHabitView
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
                        // Header section with icon
                        VStack(spacing: 16) {
                            Text("Edit Your Habit")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: colorScheme == .dark ? [
                                            Color.white,
                                            Color(red: 0.9, green: 0.95, blue: 1.0)
                                        ] : [
                                            Color.primary,
                                            Color.primary
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                        .padding(.top, 20)
                        
                        // Basic Information Card
                        VStack(spacing: 20) {
                            HStack {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(colorScheme == .dark ? .orange : .orange)
                                Text("Edit Information")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            
                            // Title Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Habit Title")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                TextField("Enter habit title...", text: $title)
                                    .font(.system(size: 16))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(colorScheme == .dark ?
                                                  Color(red: 0.15, green: 0.15, blue: 0.2) :
                                                  Color.white
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(
                                                        title.isEmpty && showValidationError ?
                                                            Color.red.opacity(0.5) :
                                                            Color.gray.opacity(colorScheme == .dark ? 0.4 : 0.2),
                                                        lineWidth: 1
                                                    )
                                            )
                                    )
                            }
                            
                            // Description Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description (Optional)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                TextField("Add description...", text: $description, axis: .vertical)
                                    .font(.system(size: 16))
                                    .lineLimit(3...6)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(colorScheme == .dark ?
                                                  Color(red: 0.15, green: 0.15, blue: 0.2) :
                                                  Color.white
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.gray.opacity(colorScheme == .dark ? 0.4 : 0.2), lineWidth: 1)
                                            )
                                    )
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    colorScheme == .dark ?
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.12, green: 0.12, blue: 0.18),
                                                Color(red: 0.15, green: 0.15, blue: 0.2)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) :
                                        LinearGradient(
                                            colors: [Color.white, Color.white],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                )
                                .shadow(
                                    color: colorScheme == .dark ?
                                        Color.black.opacity(0.3) :
                                        Color.black.opacity(0.05),
                                    radius: colorScheme == .dark ? 15 : 10,
                                    x: 0,
                                    y: 2
                                )
                        )
                        
                        // Duration & Frequency Card
                        VStack(spacing: 20) {
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                    .foregroundColor(colorScheme == .dark ? .mint : .green)
                                Text("Duration & Goals")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            
                            VStack(spacing: 16) {
                                // Date Pickers with adaptive styling
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Start Date")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                        
                                        DatePicker("", selection: $startDate, displayedComponents: .date)
                                            .labelsHidden()
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(colorScheme == .dark ?
                                                          Color(red: 0.15, green: 0.15, blue: 0.2) :
                                                          Color.gray.opacity(0.1)
                                                    )
                                            )
                                            .colorScheme(colorScheme == .dark ? .dark : .light)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("End Date")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                        
                                        DatePicker("", selection: $endDate, displayedComponents: .date)
                                            .labelsHidden()
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(
                                                        endDate <= startDate ?
                                                            Color.red.opacity(colorScheme == .dark ? 0.2 : 0.1) :
                                                            (colorScheme == .dark ?
                                                             Color(red: 0.15, green: 0.15, blue: 0.2) :
                                                             Color.gray.opacity(0.1))
                                                    )
                                            )
                                            .colorScheme(colorScheme == .dark ? .dark : .light)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    colorScheme == .dark ?
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.12, green: 0.12, blue: 0.18),
                                                Color(red: 0.15, green: 0.15, blue: 0.2)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) :
                                        LinearGradient(
                                            colors: [Color.white, Color.white],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                )
                                .shadow(
                                    color: colorScheme == .dark ?
                                        Color.black.opacity(0.3) :
                                        Color.black.opacity(0.05),
                                    radius: colorScheme == .dark ? 15 : 10,
                                    x: 0,
                                    y: 2
                                )
                        )
                        
                        Color.clear.frame(height: 100)
                    }
                    .padding(.horizontal, 20)
                }
                .offset(y: formOffset)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showValidationError)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveHabit()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isFormValid ?
                                   (colorScheme == .dark ? .cyan : selectedColor) :
                                   .gray)
                    .scaleEffect(saveButtonScale)
                    .disabled(!isFormValid)
                }
            }
            .toolbarBackground(
                colorScheme == .dark ?
                    Color(red: 0.08, green: 0.08, blue: 0.12) :
                    Color.white,
                for: .navigationBar
            )
        }
    }
    
    private func saveHabit() {
        guard isFormValid else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                showValidationError = true
                formOffset = -10
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    formOffset = 0
                }
            }
            return
        }
        
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            saveButtonScale = 0.9
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            var updatedHabit = habit
            updatedHabit.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            updatedHabit.description = description.trimmingCharacters(in: .whitespacesAndNewlines)
            updatedHabit.startDate = startDate
            updatedHabit.endDate = endDate
            
            databaseManager.updateHabit(updatedHabit)
            
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                saveButtonScale = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                dismiss()
            }
        }
    }
}
