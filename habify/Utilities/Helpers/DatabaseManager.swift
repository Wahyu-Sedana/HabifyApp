import Foundation
import SQLite3

// MARK: - Database Manager
class DatabaseManager: ObservableObject {
    static let shared = DatabaseManager()
    private var db: OpaquePointer?
    
    @Published var habits: [Habit] = []
    
    private let currentDatabaseVersion = 3
    
    private init() {
        openDatabase()
        migrateDatabase()
        createTables()
        loadHabits()
    }
    
    deinit {
        closeDatabase()
    }
    
    // MARK: - Database Connection
    private func openDatabase() {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("habify.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Unable to open database: \(String(cString: sqlite3_errmsg(db)))")
            return
        }
        
        print("Successfully opened connection to database at \(fileURL.path)")
    }
    
    private func closeDatabase() {
        if sqlite3_close(db) != SQLITE_OK {
            print("Unable to close database")
        }
        db = nil
    }
    
    // MARK: - Database Migration
    private func migrateDatabase() {
        let currentVersion = getDatabaseVersion()
        
        if currentVersion < currentDatabaseVersion {
            print("Migrating database from version \(currentVersion) to \(currentDatabaseVersion)")
            
            if currentVersion < 2 {
                migrateToVersion2()
            }
            if currentVersion < 3 {
                migrateToVersion3()
            }
            
            setDatabaseVersion(currentDatabaseVersion)
            print("Database migration completed")
        }
    }
    
    private func getDatabaseVersion() -> Int {
        var version = 0
        let versionSQL = "PRAGMA user_version;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, versionSQL, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                version = Int(sqlite3_column_int(statement, 0))
            }
        }
        
        sqlite3_finalize(statement)
        
        if version == 0 {
            let checkTableSQL = "SELECT name FROM sqlite_master WHERE type='table' AND name='habits';"
            var checkStatement: OpaquePointer?
            
            if sqlite3_prepare_v2(db, checkTableSQL, -1, &checkStatement, nil) == SQLITE_OK {
                if sqlite3_step(checkStatement) == SQLITE_ROW {
                    version = 1
                }
            }
            sqlite3_finalize(checkStatement)
        }
        
        return version
    }
    
    private func setDatabaseVersion(_ version: Int) {
        let versionSQL = "PRAGMA user_version = \(version);"
        sqlite3_exec(db, versionSQL, nil, nil, nil)
    }
    
    private func migrateToVersion2() {
        print("Migrating to version 2: Adding reminder columns")
        
        if !columnExists(table: "habits", column: "reminder_enabled") {
            let addReminderEnabledSQL = "ALTER TABLE habits ADD COLUMN reminder_enabled INTEGER DEFAULT 0;"
            if sqlite3_exec(db, addReminderEnabledSQL, nil, nil, nil) != SQLITE_OK {
                print("Error adding reminder_enabled column: \(String(cString: sqlite3_errmsg(db)))")
            } else {
                print("Successfully added reminder_enabled column")
            }
        }
        
        if !columnExists(table: "habits", column: "reminder_time") {
            let addReminderTimeSQL = "ALTER TABLE habits ADD COLUMN reminder_time TEXT;"
            if sqlite3_exec(db, addReminderTimeSQL, nil, nil, nil) != SQLITE_OK {
                print("Error adding reminder_time column: \(String(cString: sqlite3_errmsg(db)))")
            } else {
                print("Successfully added reminder_time column")
            }
        }
    }
    
    private func migrateToVersion3() {
        print("Migrating to version 3: Adding habit_tasks table")
        createHabitTasksTable()
    }
    
    private func columnExists(table: String, column: String) -> Bool {
        let pragmaSQL = "PRAGMA table_info(\(table));"
        var statement: OpaquePointer?
        var exists = false
        
        if sqlite3_prepare_v2(db, pragmaSQL, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                if let columnName = sqlite3_column_text(statement, 1) {
                    let name = String(cString: columnName)
                    if name == column {
                        exists = true
                        break
                    }
                }
            }
        }
        
        sqlite3_finalize(statement)
        return exists
    }
    
    // MARK: - Table Creation
    private func createTables() {
        createHabitsTable()
        createHabitEntriesTable()
        createHabitTasksTable() // New table for tasks
    }
    
    private func createHabitsTable() {
        let createHabitsSQL = """
            CREATE TABLE IF NOT EXISTS habits (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                description TEXT,
                start_date TEXT NOT NULL,
                end_date TEXT NOT NULL,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
                reminder_enabled INTEGER DEFAULT 0,
                reminder_time TEXT
            );
        """
        
        if sqlite3_exec(db, createHabitsSQL, nil, nil, nil) != SQLITE_OK {
            print("Error creating habits table: \(String(cString: sqlite3_errmsg(db)))")
        }
    }
    
    private func createHabitEntriesTable() {
        let createEntriesSQL = """
            CREATE TABLE IF NOT EXISTS habit_entries (
                id INTEGER PRIMARY KEY,
                habit_id TEXT NOT NULL,
                date TEXT NOT NULL,
                is_completed INTEGER DEFAULT 0,
                notes TEXT,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE,
                UNIQUE(habit_id, date)
            );
        """
        
        if sqlite3_exec(db, createEntriesSQL, nil, nil, nil) != SQLITE_OK {
            print("Error creating habit_entries table: \(String(cString: sqlite3_errmsg(db)))")
        }
    }
    
    private func createHabitTasksTable() {
        let createTasksSQL = """
            CREATE TABLE IF NOT EXISTS habit_tasks (
                id INTEGER PRIMARY KEY,
                habit_id INTEGER NOT NULL,
                title TEXT NOT NULL,
                is_completed INTEGER DEFAULT 0,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
            );
        """
        
        if sqlite3_exec(db, createTasksSQL, nil, nil, nil) != SQLITE_OK {
            print("Error creating habit_tasks table: \(String(cString: sqlite3_errmsg(db)))")
        } else {
            print("Successfully created habit_tasks table")
        }
    }
    
    // MARK: - Habit CRUD Operations
    func addHabit(_ habit: Habit) {
        let insertSQL = """
            INSERT INTO habits (title, description, start_date, end_date, created_at, updated_at, reminder_enabled, reminder_time)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            let dateFormatter = ISO8601DateFormatter()
            let now = dateFormatter.string(from: Date())
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            
            sqlite3_bind_text(statement, 1, habit.title, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, habit.description, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, dateFormatter.string(from: habit.startDate), -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, dateFormatter.string(from: habit.endDate), -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, now, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 6, now, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 7, habit.reminderEnabled ? 1 : 0)
            
            let reminderTimeString = dateFormatter.string(from: habit.reminderTime)
            sqlite3_bind_text(statement, 8, reminderTimeString, -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                let habitId = Int(sqlite3_last_insert_rowid(db))
                print("Successfully inserted habit with ID: \(habitId)")
                
                for task in habit.tasks {
                    addTask(task, to: habitId)
                }
                
                loadHabits()
            } else {
                print("Could not insert habit: \(String(cString: sqlite3_errmsg(db)))")
            }
        } else {
            print("Could not prepare statement: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        sqlite3_finalize(statement)
    }
    
    func loadHabits() {
        let querySQL = """
            SELECT id, title, description, start_date, end_date, created_at, updated_at, 
                   COALESCE(reminder_enabled, 0) as reminder_enabled,
                   COALESCE(reminder_time, '') as reminder_time
            FROM habits ORDER BY created_at DESC;
        """
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            var loadedHabits: [Habit] = []
            let dateFormatter = ISO8601DateFormatter()
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let title = String(cString: sqlite3_column_text(statement, 1))
                let description = String(cString: sqlite3_column_text(statement, 2))
                
                let startDateString = String(cString: sqlite3_column_text(statement, 3))
                let endDateString = String(cString: sqlite3_column_text(statement, 4))
                
                let startDate = dateFormatter.date(from: startDateString) ?? Date()
                let endDate = dateFormatter.date(from: endDateString) ?? Date()
                
                let reminderEnabled = sqlite3_column_int(statement, 7) == 1
                
                var reminderTime = Date()
                if let reminderTimeText = sqlite3_column_text(statement, 8) {
                    let reminderTimeString = String(cString: reminderTimeText)
                    if !reminderTimeString.isEmpty {
                        reminderTime = dateFormatter.date(from: reminderTimeString) ?? Date()
                    }
                }
                
                let tasks = loadTasks(for: id)
                
                let habit = Habit(
                    id: id,
                    title: title,
                    description: description,
                    startDate: startDate,
                    endDate: endDate,
                    reminderEnabled: reminderEnabled,
                    reminderTime: reminderTime,
                    tasks: tasks
                )
                
                loadedHabits.append(habit)
            }
            
            DispatchQueue.main.async {
                self.habits = loadedHabits
                print("Loaded \(loadedHabits.count) habits from database")
                
                for habit in loadedHabits {
                    print("   - \(habit.title) (ID: \(habit.id ?? 0), Tasks: \(habit.tasks.count))")
                }
            }
        } else {
            print("Could not prepare load statement: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        sqlite3_finalize(statement)
    }
    
    func updateHabit(_ habit: Habit) {
        guard let id = habit.id else { return }
        
        let updateSQL = """
            UPDATE habits 
            SET title = ?, description = ?, start_date = ?, end_date = ?, updated_at = ?, 
                reminder_enabled = ?, reminder_time = ?
            WHERE id = ?;
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            let dateFormatter = ISO8601DateFormatter()
            let now = dateFormatter.string(from: Date())
            let reminderTimeString = dateFormatter.string(from: habit.reminderTime)
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            
            sqlite3_bind_text(statement, 1, habit.title, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, habit.description, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, dateFormatter.string(from: habit.startDate), -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, dateFormatter.string(from: habit.endDate), -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, now, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 6, habit.reminderEnabled ? 1 : 0)
            sqlite3_bind_text(statement, 7, reminderTimeString, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 8, Int32(id))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully updated habit")
                
                deleteAllTasks(for: id)
                for task in habit.tasks {
                    addTask(task, to: id)
                }
                
                loadHabits()
            } else {
                print("Could not update habit: \(String(cString: sqlite3_errmsg(db)))")
            }
        }
        
        sqlite3_finalize(statement)
    }
    
    func deleteHabit(_ habit: Habit) {
        guard let id = habit.id else { return }
        
        deleteAllTasks(for: id)
        
        let deleteSQL = "DELETE FROM habits WHERE id = ?;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(id))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully deleted habit")
                DispatchQueue.main.async {
                    self.habits.removeAll { $0.id == habit.id }
                }
            } else {
                print("Could not delete habit: \(String(cString: sqlite3_errmsg(db)))")
            }
        }
        
        sqlite3_finalize(statement)
    }
    
    // MARK: - Task CRUD Operations
    
    func loadTasks(for habitId: Int) -> [HabitTask] {
        let querySQL = "SELECT id, title, is_completed, created_at FROM habit_tasks WHERE habit_id = ? ORDER BY created_at;"
        var statement: OpaquePointer?
        var tasks: [HabitTask] = []
        
        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(habitId))
            
            let dateFormatter = ISO8601DateFormatter()
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let title = String(cString: sqlite3_column_text(statement, 1))
                let isCompleted = sqlite3_column_int(statement, 2) == 1
                
                var createdAt = Date()
                if let createdAtText = sqlite3_column_text(statement, 3) {
                    let createdAtString = String(cString: createdAtText)
                    createdAt = dateFormatter.date(from: createdAtString) ?? Date()
                }
                
                let task = HabitTask(
                    id: id,
                    title: title,
                    isCompleted: isCompleted,
                    createdAt: createdAt
                )
                tasks.append(task)
            }
        } else {
            print("Could not prepare load tasks statement: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        sqlite3_finalize(statement)
        return tasks
    }
    
    private func addTask(_ task: HabitTask, to habitId: Int) -> HabitTask? {
        let insertSQL = """
            INSERT INTO habit_tasks (habit_id, title, is_completed, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?);
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            let dateFormatter = ISO8601DateFormatter()
            let now = dateFormatter.string(from: Date())
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            
            sqlite3_bind_int(statement, 1, Int32(habitId))
            sqlite3_bind_text(statement, 2, task.title, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 3, task.isCompleted ? 1 : 0)
            sqlite3_bind_text(statement, 4, now, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, now, -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) == SQLITE_DONE {
               let newId = Int(sqlite3_last_insert_rowid(db))
               sqlite3_finalize(statement)
                loadHabits()
               return HabitTask(id: newId, title: task.title, isCompleted: task.isCompleted, createdAt: task.createdAt)
           } else {
               print("Could not insert task: \(String(cString: sqlite3_errmsg(db)))")
           }
        }
        
        sqlite3_finalize(statement)
        return nil
    }
    
    private func deleteAllTasks(for habitId: Int) {
        let deleteSQL = "DELETE FROM habit_tasks WHERE habit_id = ?;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(habitId))
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Could not delete tasks: \(String(cString: sqlite3_errmsg(db)))")
            }
        }
        
        sqlite3_finalize(statement)
    }
    
    func updateTask(_ task: HabitTask, for habitId: Int) {
        guard let taskId = task.id else { return }
        
        let updateSQL = """
            UPDATE habit_tasks 
            SET title = ?, is_completed = ?, updated_at = ?
            WHERE id = ? AND habit_id = ?;
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            let dateFormatter = ISO8601DateFormatter()
            let now = dateFormatter.string(from: Date())
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            
            sqlite3_bind_text(statement, 1, task.title, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 2, task.isCompleted ? 1 : 0)
            sqlite3_bind_text(statement, 3, now, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 4, Int32(taskId))
            sqlite3_bind_int(statement, 5, Int32(habitId))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully updated task")
                loadHabits()
            } else {
                print("Could not update task: \(String(cString: sqlite3_errmsg(db)))")
            }
        }
        
        sqlite3_finalize(statement)
    }
    
    func deleteTask(_ task: HabitTask, from habitId: Int) {
        guard let taskId = task.id else {
            return
        }
        
        print("Attempting to delete task ID: \(taskId) from habit: \(habitId)")
        
        let deleteSQL = "DELETE FROM habit_tasks WHERE id = ? AND habit_id = ?;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(taskId))
            sqlite3_bind_int(statement, 2, Int32(habitId))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                let changes = sqlite3_changes(db)
                print("Successfully deleted task. Rows affected: \(changes)")
                if changes > 0 {
                    loadHabits() // Refresh data
                }
            } else {
                print("Could not delete task: \(String(cString: sqlite3_errmsg(db)))")
            }
        } else {
            print("Could not prepare delete statement: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        sqlite3_finalize(statement)
    }
    
    func addTaskToHabit(_ task: HabitTask, habitId: Int) -> HabitTask? {
        return addTask(task, to: habitId)
    }
}
