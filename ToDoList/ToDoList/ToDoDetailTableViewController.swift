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
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var notesTextView: UITextView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var isDatePickerHidden: Bool = true
    let dateLabelIndexPath = IndexPath(row: 0, section: 1)
    let datePickerIndexPath = IndexPath(row: 1, section: 1)
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
        } else {
            currentDueDate = Date().addingTimeInterval(24*60*60)
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
    
    // MARK: - Navigation

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         super.prepare(for: segue, sender: sender)

         guard segue.identifier == "saveUnwind" else { return }

         let title = titleTextField.text!
         let isComplete = isCompleteButton.isSelected
         let dueDate = dueDatePicker.date
         let notes = notesTextView.text
         
         if toDo != nil {
             toDo?.title = title
             toDo?.isComplete = isComplete
             toDo?.dueDate = dueDate
             toDo?.notes = notes
         } else {
             toDo = ToDo(title: title, isComplete: isComplete, dueDate: dueDate, notes: notes)
         }
     }

}// class end
