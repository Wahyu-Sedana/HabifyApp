import Foundation
import SQLite3

// MARK: - Database Manager
class DatabaseManager: ObservableObject {
    static let shared = DatabaseManager()
    private var db: OpaquePointer?
    
    @Published var habits: [Habit] = []
    
    private init() {
//        let fileURL = try! FileManager.default
//                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//                .appendingPathComponent("habify.sqlite")
//            try? FileManager.default.removeItem(at: fileURL)
        openDatabase()
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
    
    // MARK: - Table Creation
    private func createTables() {
        createHabitsTable()
        createHabitEntriesTable()
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
                updated_at TEXT DEFAULT CURRENT_TIMESTAMP
            );
        """
        
        if sqlite3_exec(db, createHabitsSQL, nil, nil, nil) != SQLITE_OK {
            print("Error creating habits table: \(String(cString: sqlite3_errmsg(db)))")
        }
    }
    
    private func createHabitEntriesTable() {
        let createEntriesSQL = """
            CREATE TABLE IF NOT EXISTS habit_entries (
                id TEXT PRIMARY KEY,
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
    
    // MARK: - Habit CRUD Operations
    func addHabit(_ habit: Habit) {
        let insertSQL = """
            INSERT INTO habits (title, description, start_date, end_date, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?);
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
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully inserted habit")
                
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
        let querySQL = "SELECT id, title, description, start_date, end_date, created_at, updated_at FROM habits ORDER BY created_at DESC;"
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
                
                let habit = Habit(
                    id: id,
                    title: title,
                    description: description,
                    startDate: startDate,
                    endDate: endDate
                )
                
                loadedHabits.append(habit)
            }
            
            DispatchQueue.main.async {
                self.habits = loadedHabits
                print("Loaded \(loadedHabits.count) habits from database")

                for habit in loadedHabits {
                    print("   - \(habit.title) (ID: \(habit.id ?? 0))")
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
            SET title = ?, description = ?, start_date = ?, end_date = ?, updated_at = ?
            WHERE id = ?;
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            let dateFormatter = ISO8601DateFormatter()
            let now = dateFormatter.string(from: Date())
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            
            sqlite3_bind_text(statement, 1, habit.title, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, habit.description, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, dateFormatter.string(from: habit.startDate), -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, dateFormatter.string(from: habit.endDate), -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, now, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 6, Int32(id))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully updated habit")
                loadHabits()
            } else {
                print("Could not update habit: \(String(cString: sqlite3_errmsg(db)))")
            }
        }
        
        sqlite3_finalize(statement)
    }
    
    func deleteHabit(_ habit: Habit) {
        guard let id = habit.id else { return }
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
}
