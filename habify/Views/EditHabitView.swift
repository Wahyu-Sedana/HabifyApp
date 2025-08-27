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
    
    // Init untuk isi state dengan data lama
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
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    Text("Edit Your Habit")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white : .primary)
                        .padding(.top, 20)
                    
                    // Title
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
                    
                    // Description
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
                    
                    // Dates
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Start Date")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                DatePicker("", selection: $startDate, displayedComponents: .date)
                                    .labelsHidden()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("End Date")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                DatePicker("", selection: $endDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(endDate <= startDate ? Color.red.opacity(0.2) : Color.clear)
                                    )
                            }
                        }
                    }
                    
                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 20)
            }
            .offset(y: formOffset)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showValidationError)
            
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveHabit()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isFormValid ? (colorScheme == .dark ? .cyan : selectedColor) : .gray)
                    .scaleEffect(saveButtonScale)
                    .disabled(!isFormValid)
                }
            }
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
        
        var updatedHabit = habit
        updatedHabit.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedHabit.description = description.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedHabit.startDate = startDate
        updatedHabit.endDate = endDate
        
        databaseManager.updateHabit(updatedHabit)
        dismiss()
    }
}
