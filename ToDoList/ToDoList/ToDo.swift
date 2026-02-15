//
//  ToDo.swift
//  ToDoList
//
//  Created by Alshabbaq on 12/02/2026.
//

import Foundation

enum ToDoCategory: String, CaseIterable, Codable {
    case work = "Work"
    case personal = "Personal"
    case other = "Other"
}

struct ToDo: Equatable, Codable {
    let id: UUID
    var title: String
    var isComplete: Bool
    var dueDate: Date
    var notes: String?
    var shouldRemind: Bool
    var category: ToDoCategory
    
    init(title: String, isComplete: Bool, dueDate: Date, notes: String?, shouldRemind: Bool, category: ToDoCategory) {
        self.id = UUID()
        self.title = title
        self.isComplete = isComplete
        self.dueDate = dueDate
        self.notes = notes
        self.shouldRemind = shouldRemind
        self.category = category
    }
    
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveURL = documentsDirectory.appendingPathComponent("toDos").appendingPathExtension("plist")
    
    static func saveToDos(_ todos: [ToDo]) {
        let propertyListEncoder = PropertyListEncoder()
        let codedToDos = try? propertyListEncoder.encode(todos)
        try? codedToDos?.write(to: archiveURL, options: .noFileProtection)
    }
    
    static func loadToDos() -> [ToDo]?  {
        guard let codedToDos = try? Data(contentsOf: archiveURL) else {return nil}
        let propertyListDecoder = PropertyListDecoder()
        return try? propertyListDecoder.decode(Array<ToDo>.self, from: codedToDos)
    }
    
    static func loadSampleToDos() -> [ToDo] {
        
        let now = Date()
        
        return [
            // MARK: - Work
            
            ToDo(
                title: "Submit project report",
                isComplete: false,
                dueDate: now.addingTimeInterval(60 * 60),
                notes: "Upload final PDF to Moodle",
                shouldRemind: true,
                category: .work
            ),
            
            ToDo(
                title: "Team meeting",
                isComplete: false,
                dueDate: now.addingTimeInterval(3 * 24 * 60 * 60),
                notes: "Discuss UI improvements",
                shouldRemind: false,
                category: .work
            ),
            
            ToDo(
                title: "Fix login bug",
                isComplete: true,
                dueDate: now.addingTimeInterval(-2 * 24 * 60 * 60),
                notes: "Resolved navigation issue",
                shouldRemind: false,
                category: .work
            ),
            
            // MARK: - Personal
            
            ToDo(
                title: "Gym session",
                isComplete: false,
                dueDate: now.addingTimeInterval(24 * 60 * 60),
                notes: "Leg day",
                shouldRemind: true,
                category: .personal
            ),
            
            ToDo(
                title: "Buy groceries",
                isComplete: false,
                dueDate: now.addingTimeInterval(-3 * 60 * 60),
                notes: "Milk, eggs, rice",
                shouldRemind: true,
                category: .personal
            ),
            
            ToDo(
                title: "Call family",
                isComplete: true,
                dueDate: now.addingTimeInterval(-5 * 24 * 60 * 60),
                notes: "",
                shouldRemind: false,
                category: .personal
            ),
            
            // MARK: - Other
            
            ToDo(
                title: "Read a book",
                isComplete: false,
                dueDate: now.addingTimeInterval(5 * 24 * 60 * 60),
                notes: "Finish SwiftUI chapter",
                shouldRemind: false,
                category: .other
            ),
            
            ToDo(
                title: "Watch tutorial",
                isComplete: false,
                dueDate: now.addingTimeInterval(2 * 60 * 60),
                notes: "UNUserNotificationCenter deep dive",
                shouldRemind: true,
                category: .other
            ),
            
            ToDo(
                title: "Old archived task",
                isComplete: true,
                dueDate: now.addingTimeInterval(-10 * 24 * 60 * 60),
                notes: "",
                shouldRemind: false,
                category: .other
            )
        ]
    }

    
    static func == (lhs: ToDo, rhs: ToDo) -> Bool {
        return lhs.id == rhs.id
    }
    
}// class end
