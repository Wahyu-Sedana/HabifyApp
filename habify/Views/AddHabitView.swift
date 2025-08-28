import SwiftUI
import UserNotifications

struct AddHabitView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var databaseManager: DatabaseManager
    private let notificationManager = NotificationManager.shared
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
    @State private var targetFrequency: Int = 7
    @State private var reminderEnabled: Bool = false
    @State private var reminderTime: Date = {
        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    @State private var selectedColor: Color = .blue
    
    @State private var showValidationError: Bool = false
    @State private var saveButtonScale: CGFloat = 1.0
    @State private var formOffset: CGFloat = 0
    @State private var notificationPermissionDenied: Bool = false
    
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        endDate > startDate
    }
    
//    private let colorOptions: [Color] = [
//        .blue, .green, .orange, .red, .purple, .pink, .indigo, .mint, .cyan, .teal
//    ]
    
    var onSave: ((Habit) -> Void)?
    
    var body: some View {
        NavigationView {
            ZStack {
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
                        VStack(spacing: 16) {
                            Text("Create New Habit")
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
                        
                        VStack(spacing: 20) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(colorScheme == .dark ? .cyan : .blue)
                                Text("Basic Information")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            
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
                        .cardStyle(colorScheme: colorScheme)
                        VStack(spacing: 20) {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(colorScheme == .dark ? .yellow : .orange)
                                Text("Reminder Settings")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Daily Reminder")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                    
                                    Text("Get notified to complete your habit")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $reminderEnabled)
                                    .tint(selectedColor)
                            }
                            
                            if reminderEnabled {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Reminder Time")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                    
                                    DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(colorScheme == .dark ?
                                                      Color(red: 0.15, green: 0.15, blue: 0.2) :
                                                      Color.gray.opacity(0.1))
                                        )
                                        .colorScheme(colorScheme == .dark ? .dark : .light)
                                }
                                .transition(.opacity.combined(with: .scale))
                            }
                            
                            if notificationPermissionDenied && reminderEnabled {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Notification Permission Required")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.primary)
                                        
                                        Text("Enable notifications in Settings to receive reminders")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button("Settings") {
                                        openSettings()
                                    }
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.blue)
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.orange.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                .transition(.opacity.combined(with: .scale))
                            }
                        }
                        .cardStyle(colorScheme: colorScheme)
                        
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
                        .cardStyle(colorScheme: colorScheme)
                        
                        Color.clear.frame(height: 100)
                    }
                    .padding(.horizontal, 20)
                }
                .offset(y: formOffset)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showValidationError)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: reminderEnabled)
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
        .onAppear {
            checkNotificationPermission()
        }
    }
    
    private func checkNotificationPermission() {
        notificationManager.checkPermissionStatus { status in
            notificationPermissionDenied = (status != UNAuthorizationStatus.authorized)
        }
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
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
            
            if reminderEnabled {
                notificationManager.checkPermissionStatus { status in
                    if status == UNAuthorizationStatus.authorized {
                        notificationManager.scheduleHabitReminder(for: newHabit, at: reminderTime)
                        print("Notification scheduled for habit: \(newHabit.title)")
                    } else {
                        print("Notification permission not granted")
                    }
                }
            }
            
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                saveButtonScale = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                dismiss()
            }
        }
    }
}

// MARK: - View Extension for Card Styling
extension View {
    func cardStyle(colorScheme: ColorScheme) -> some View {
        self
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
    }
}
