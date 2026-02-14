//
//  ToDoDetailTableViewController.swift
//  ToDoList
//
//  Created by Alshabbaq on 13/02/2026.
//

import UIKit

class ToDoDetailTableViewController: UITableViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var isCompleteButton: UIButton!
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    @IBOutlet weak var notesTextView: UITextView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var isDatePickerHidden: Bool = true
    let dateLabelIndexPath = IndexPath(row: 1, section: 1)
    let datePickerIndexPath = IndexPath(row: 2, section: 1)
    let notesIndexPath = IndexPath(row: 0, section: 2)
    
    var toDo: ToDo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentDueDate: Date
        if let toDo = toDo {
            navigationItem.title = "To-Do"
            titleTextField.text = toDo.title
            isCompleteButton.isSelected = toDo.isComplete
            currentDueDate = toDo.dueDate
            notesTextView.text = toDo.notes
            reminderSwitch.isOn = toDo.shouldRemind
            
            switch toDo.category {
            case .work: categorySegmentedControl.selectedSegmentIndex = 0
            case .personal: categorySegmentedControl.selectedSegmentIndex = 1
            case .other: categorySegmentedControl.selectedSegmentIndex = 2
            }
            
        }
        else {
            categorySegmentedControl.selectedSegmentIndex = 0
            currentDueDate = Date().addingTimeInterval(24*60*60)
            reminderSwitch.isOn = false
        }
        
        dueDatePicker.date = currentDueDate
        updateDueDateLabel(date: currentDueDate)
        updateSaveButtonState()
        
//        dueDatePicker.date = Date().addingTimeInterval(24*60*60)
//        updateDueDateLabel(date: dueDatePicker.date)
//        updateSaveButtonState()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func updateDueDateLabel(date: Date) {
            dueDateLabel.text = date.formatted(.dateTime.month(.defaultDigits).day().year(.twoDigits).hour().minute())
        }
    
    func updateSaveButtonState() {
        let shouldEnableSaveButton = titleTextField.text?.isEmpty == false
        saveButton.isEnabled = shouldEnableSaveButton
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case datePickerIndexPath where isDatePickerHidden == true:
            return 0
        case notesIndexPath:
            return 200
        default:
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case datePickerIndexPath:
            return 216
        case notesIndexPath:
            return 200
        default:
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == dateLabelIndexPath {
            isDatePickerHidden.toggle()
            dueDateLabel.textColor = .black
            updateDueDateLabel(date: dueDatePicker.date)
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    @IBAction func returnPressed(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func isCompleteButtonTapped(_ sender: UIButton) {
        isCompleteButton.isSelected.toggle()
    }
    
    @IBAction func reminderSwitchChanged(_ sender: UISwitch) {
        if sender.isOn && dueDatePicker.date <= Date() {
                sender.setOn(false, animated: true)
            }
    }
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        updateDueDateLabel(date: sender.date)
        
        if reminderSwitch.isOn && sender.date <= Date() {
            reminderSwitch.setOn(false, animated: true)
        }
    }
    
    @IBAction func shareTapped(_ sender: UIBarButtonItem) {
        let title = titleTextField.text ?? ""
            let isComplete = isCompleteButton.isSelected
            let dueDate = dueDatePicker.date
            let notes = notesTextView.text ?? ""

            let statusText = isComplete ? "Completed" : "Not Completed"
            let dueText = dueDate.formatted(.dateTime.month().day().year().hour().minute())

            var shareText = "To-Do: \(title)\nStatus: \(statusText)\nDue: \(dueText)"

            if !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                shareText += "\nNotes: \(notes)"
            }

            let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)

            // iPad safety (doesn’t hurt on iPhone)
            activityVC.popoverPresentationController?.barButtonItem = sender

            present(activityVC, animated: true)
    }
    
    // MARK: - Navigation

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         super.prepare(for: segue, sender: sender)

         guard segue.identifier == "saveUnwind" else { return }

         let title = titleTextField.text!
         let isComplete = isCompleteButton.isSelected
         let dueDate = dueDatePicker.date
         let notes = notesTextView.text
         let shouldRemind = reminderSwitch.isOn
         
         let category: ToDoCategory
         switch categorySegmentedControl.selectedSegmentIndex {
         case 0: category = .work
         case 1: category = .personal
         default: category = .other
         }
         
         if toDo != nil {
             toDo?.title = title
             toDo?.isComplete = isComplete
             toDo?.dueDate = dueDate
             toDo?.notes = notes
             toDo?.shouldRemind = shouldRemind
             toDo?.category = category
         } else {
             toDo = ToDo(title: title, isComplete: isComplete, dueDate: dueDate, notes: notes, shouldRemind: shouldRemind, category: category)
         }
     }

}// class end
