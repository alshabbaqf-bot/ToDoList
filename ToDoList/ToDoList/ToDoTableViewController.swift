//
//  ToDoTableViewController.swift
//  ToDoList
//
//  Created by Alshabbaq on 12/02/2026.
//

import UIKit
import UserNotifications

class ToDoTableViewController: UITableViewController, ToDoCellDelegate {
    
    var toDos: [ToDo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestNotificationAuthorization()
        
        if let savedToDos = ToDo.loadToDos() {
            toDos = savedToDos
        } else {
            toDos = ToDo.loadSampleToDos()
        }
        
        navigationItem.leftBarButtonItem = editButtonItem

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return toDos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCellIdentifier", for: indexPath) as! ToDoCell

        let toDo = toDos[indexPath.row]
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
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let toDo = toDos[indexPath.row]
            cancelNotification(for: toDo)
            toDos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        ToDo.saveToDos(toDos)
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
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
    }// unwindToToDoList end
    
    @IBSegueAction func editToDo(_ coder: NSCoder, sender: Any?) -> ToDoDetailTableViewController? {
        let detailController = ToDoDetailTableViewController(coder: coder)
        
        guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else {
            // if sender is the add button, return an empty controller
            return detailController
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        detailController?.toDo = toDos[indexPath.row]
        
        return detailController
    }
    
    func checkmarkTapped(sender: ToDoCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            var toDo = toDos[indexPath.row]
            
            toDo.isComplete.toggle()
            
            cancelNotification(for: toDo)

            if toDo.shouldRemind && !toDo.isComplete {
                scheduleNotification(for: toDo)
            }

            toDos[indexPath.row] = toDo
            tableView.reloadRows(at: [indexPath], with: .automatic)
            ToDo.saveToDos(toDos)
        }
    }
    
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
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

}// class end
