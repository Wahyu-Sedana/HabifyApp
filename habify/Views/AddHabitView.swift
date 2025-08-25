import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var databaseManager: DatabaseManager
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
    @State private var targetFrequency: Int = 7
    @State private var reminderEnabled: Bool = false
    @State private var reminderTime: Date = Date()
    @State private var selectedColor: Color = .blue
    
    // Animation states
    @State private var showValidationError: Bool = false
    @State private var saveButtonScale: CGFloat = 1.0
    @State private var formOffset: CGFloat = 0
    
    // Validation
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        endDate > startDate
    }
    
    // Color options for habit customization
    private let colorOptions: [Color] = [
        .blue, .green, .orange, .red, .purple, .pink, .indigo, .mint, .cyan, .teal
    ]
    
    var onSave: ((Habit) -> Void)?
    
    var body: some View {
        NavigationView {
            ZStack {
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
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header section with icon
                        VStack(spacing: 16) {
                            
                            Text("Create New Habit")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        .padding(.top, 20)
                        
                        // Basic Information Card
                        VStack(spacing: 20) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Basic Information")
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
                                            .fill(Color.white)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(
                                                        title.isEmpty && showValidationError ?
                                                            Color.red.opacity(0.5) :
                                                            Color.gray.opacity(0.2),
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
                                            .fill(Color.white)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                        )
                        
                        // Duration & Frequency Card
                        VStack(spacing: 20) {
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                    .foregroundColor(.green)
                                Text("Duration & Goals")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            
                            VStack(spacing: 16) {
                                // Date Pickers with modern styling
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
                                                    .fill(Color.gray.opacity(0.1))
                                            )
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
                                                    .fill(endDate <= startDate ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
                                            )
                                    }
                                }
                                
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
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
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveHabit()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isFormValid ? selectedColor : .gray)
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
        
    
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            saveButtonScale = 0.9
            formOffset = showValidationError ? -10 : 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let newHabit = Habit(
                id: nil,
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                startDate: startDate,
                endDate: endDate
            )
            
            databaseManager.addHabit(newHabit)
            
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                saveButtonScale = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                dismiss()
            }
        }
    }
}
