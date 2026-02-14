//
//  ToDoTableViewController.swift
//  ToDoList
//
//  Created by Alshabbaq on 12/02/2026.
//

import UIKit
import UserNotifications

class ToDoTableViewController: UITableViewController, ToDoCellDelegate, UNUserNotificationCenterDelegate, UISearchResultsUpdating {
    
    var toDos: [ToDo] = []
    
    private var filteredToDos: [ToDo] = []
    private var isSearching: Bool = false
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var groupedToDos: [(category: ToDoCategory, items: [ToDo])] {
        ToDoCategory.allCases.map { category in
            let items = toDos.filter { $0.category == category }
            return (category, items)
        }.filter { !$0.items.isEmpty }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestNotificationAuthorization()
        
        UNUserNotificationCenter.current().delegate = self
        
        if let savedToDos = ToDo.loadToDos() {
            toDos = savedToDos
        } else {
            toDos = ToDo.loadSampleToDos()
        }
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        setupSearchController()

    }// viewDidLoad end
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return isSearching ? 1 : groupedToDos.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredToDos.count
        } else {
            return groupedToDos[section].items.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard !isSearching else { return nil }
        return groupedToDos[section].category.rawValue
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCellIdentifier", for: indexPath) as! ToDoCell

        let toDo: ToDo
        if isSearching {
            toDo = filteredToDos[indexPath.row]
        } else {
            toDo = groupedToDos[indexPath.section].items[indexPath.row]
        }
        
        cell.titleLabel?.text = toDo.title
        cell.isCompleteButton.isSelected = toDo.isComplete
        
        cell.delegate = self
        
        // Show due date text
        let formatted = ToDoCell.dueDateFormatter.string(from: toDo.dueDate)
        cell.dueDateLabel.text = "Due: \(formatted)"

        // Highlight rules
        let now = Date()
        let isOverdue = (toDo.dueDate < now) && (toDo.isComplete == false)

        // Upcoming next 24 hours
        let upcomingLimit = now.addingTimeInterval(24 * 60 * 60)
        let isUpcoming = (toDo.dueDate >= now) && (toDo.dueDate <= upcomingLimit) && (toDo.isComplete == false)

        if isOverdue {
            cell.dueDateLabel.text = "Overdue: \(formatted)"
            cell.dueDateLabel.textColor = .systemRed
        } else if isUpcoming {
            cell.dueDateLabel.text = "Soon: \(formatted)"
            cell.dueDateLabel.textColor = .systemOrange
        } else {
            cell.dueDateLabel.textColor = .secondaryLabel
        }
        
        // Dim the title for completed items
        cell.titleLabel.textColor = toDo.isComplete ? .secondaryLabel : .label
        
        return cell
    }// cellForRowAt end

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let toDoToDelete: ToDo

            if isSearching {
                toDoToDelete = filteredToDos[indexPath.row]
                filteredToDos.remove(at: indexPath.row)

                if let mainIndex = toDos.firstIndex(of: toDoToDelete) {
                    toDos.remove(at: mainIndex)
                }
            } else {
                toDoToDelete = groupedToDos[indexPath.section].items[indexPath.row]
                if let mainIndex = indexInMainList(for: toDoToDelete) {
                    toDos.remove(at: mainIndex)
                }
            }

            cancelNotification(for: toDoToDelete)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            ToDo.saveToDos(toDos)
        }
    }
    
    @IBAction func unwindToToDoList(segue: UIStoryboardSegue) {
        guard segue.identifier == "saveUnwind" else { return }
        let sourceViewController = segue.source as! ToDoDetailTableViewController

        if let toDo = sourceViewController.toDo {
            if let indexOfExistingToDo = toDos.firstIndex(of: toDo) {
                toDos[indexOfExistingToDo] = toDo
                tableView.reloadRows(at: [IndexPath(row: indexOfExistingToDo, section: 0)], with: .automatic)
            } else {
                let newIndexPath = IndexPath(row: toDos.count, section: 0)
                toDos.append(toDo)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            
            cancelNotification(for: toDo)
            
            if toDo.shouldRemind && !toDo.isComplete {
                scheduleNotification(for: toDo)
            }
        }
        
        ToDo.saveToDos(toDos)
        
        if isSearching {
            filterContent(for: searchController.searchBar.text ?? "")
        }

    }// unwindToToDoList end
    
    @IBSegueAction func editToDo(_ coder: NSCoder, sender: Any?) -> ToDoDetailTableViewController? {
        let detailController = ToDoDetailTableViewController(coder: coder)
        
        guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else {
            // if sender is the add button, return an empty controller
            return detailController
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if isSearching {
            detailController?.toDo = filteredToDos[indexPath.row]
        } else {
            detailController?.toDo = groupedToDos[indexPath.section].items[indexPath.row]
        }

        return detailController
    }
    
    func checkmarkTapped(sender: ToDoCell) {
        guard let indexPath = tableView.indexPath(for: sender) else { return }

        if isSearching {
            // Toggle in filtered list
            var toDo = filteredToDos[indexPath.row]
            toDo.isComplete.toggle()

            // Apply change back to main list using id
            if let mainIndex = toDos.firstIndex(of: toDo) {
                toDos[mainIndex] = toDo
            }

            // Update filtered list too
            filteredToDos[indexPath.row] = toDo

            cancelNotification(for: toDo)
            if toDo.shouldRemind && !toDo.isComplete {
                scheduleNotification(for: toDo)
            }

            tableView.reloadRows(at: [indexPath], with: .automatic)
            ToDo.saveToDos(toDos)
        } else {
            let toDoFromSection = groupedToDos[indexPath.section].items[indexPath.row]
            guard let mainIndex = indexInMainList(for: toDoFromSection) else { return }

            var toDo = toDos[mainIndex]
            toDo.isComplete.toggle()

            cancelNotification(for: toDo)
            if toDo.shouldRemind && !toDo.isComplete {
                scheduleNotification(for: toDo)
            }

            toDos[mainIndex] = toDo
            tableView.reloadData()
            ToDo.saveToDos(toDos)
        }

    }// checkmarkTapped end
    
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }
    
    private func scheduleNotification(for toDo: ToDo) {
        guard toDo.isComplete == false else { return }
        guard toDo.shouldRemind == true else { return }
        guard toDo.dueDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "To-Do Reminder"
        content.body = toDo.title
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: toDo.dueDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(
            identifier: toDo.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    private func cancelNotification(for toDo: ToDo) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [toDo.id.uuidString])
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search to-dos"
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        filterContent(for: searchText)
    }
    
    private func filterContent(for searchText: String) {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            isSearching = false
            filteredToDos = []
            tableView.reloadData()
            return
        }

        isSearching = true
        let lower = trimmed.lowercased()

        filteredToDos = toDos.filter { toDo in
            let titleMatch = toDo.title.lowercased().contains(lower)
            let notesMatch = (toDo.notes ?? "").lowercased().contains(lower)
            let categoryMatch = toDo.category.rawValue.lowercased().contains(lower)
            return titleMatch || notesMatch || categoryMatch
        }
        
        tableView.reloadData()
    }
    
    private func indexInMainList(for toDo: ToDo) -> Int? {
        return toDos.firstIndex(of: toDo)
    }

}// class end
