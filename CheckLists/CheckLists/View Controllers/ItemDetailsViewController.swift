//
//  itemDetailsViewController.swift
//  CheckLists
//
//  Created by yuancheng on 2/7/19.
//  Copyright © 2019 Yuan Cheng. All rights reserved.
//

import UIKit
import UserNotifications

// a protocol are a group of methods without implementation, any object that use this protocol must have these methods declared
protocol ItemDetailsViewControllerDelegate: class {
    func itemDetailsViewControllerDidCancel(_ controller: ItemDetailsViewController)
    
    func itemDetailsViewController(_ controller: ItemDetailsViewController, didFinishAdding item: ChecklistItem)
    
    func itemDetailsViewController(_ controller: ItemDetailsViewController, didFinishEditing item: ChecklistItem)
}

class ItemDetailsViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var datePickerCell: UITableViewCell!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // weak: the relationship between the view and its delegate. ChecklistView has a strong reference to AddItemView, and now AddItemView only has a weak reference to ChecklistView, so there is no ownership cycle, no potenital memory leak
    // delegate are always made weak
    // question mark: the delegates are optional
    weak var delegate: ItemDetailsViewControllerDelegate?
    
    var itemToEdit: ChecklistItem?
    var dueDate = Date() // current datetime
    var datePickerVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        if let item = itemToEdit {
            title = "Edit Item"
            textField.text = item.text
            doneBarButton.isEnabled = true
            
            // if there is an item to edit, we assign item's properties to UI elements
            shouldRemindSwitch.isOn = item.shouldRemind
            dueDate = item.dueDate
        }
         updateDueDateLabel()
    }
    
    // make textField focus when enter the screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    // MARK: - UITableView delegate
    // disable cell selection for adding item, except if it is date element
    // the func is expected to return a IndexPath type value, but the question mark at the end indicates that it also accepts nil value, here it means, no rows would be selected
    override func tableView(_ tableView: UITableView,
                            willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 1 && indexPath.row == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    // create the row for the date picker
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            if indexPath.section == 1 && indexPath.row == 2 {
                return datePickerCell
            } else {
                return super.tableView(tableView, cellForRowAt: indexPath)
            }
    }
    
    // display new cells for date picker
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        if section == 1 && datePickerVisible {
            return 3
        } else {
            return super.tableView(tableView,
                                   numberOfRowsInSection: section)
        }
    }
    
    // make enough height for date picker to be displayed
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 2 {
            return 217
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    // display the date picker when the date element is clicked
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        textField.resignFirstResponder()
        if indexPath.section == 1 && indexPath.row == 1 {
            if !datePickerVisible {
                showDatePicker()
            } else {
                hideDatePicker()
            }
        }
    }
    
    // let data source know that there is three rows in section 1
    override func tableView(_ tableView: UITableView,
                            indentationLevelForRowAt indexPath: IndexPath) -> Int {
        var newIndexPath = indexPath
        if indexPath.section == 1 && indexPath.row == 2 {
            newIndexPath = IndexPath(row: 0, section: indexPath.section)
        }
        return super.tableView(tableView,
                               indentationLevelForRowAt: newIndexPath)
    }
    
    // MARK: - UITextField delegate
    // check the text field, disable the Done button at the navigation bar if the text field is empty
    // we don't know the new text at first, we only know the changes, so calculate the text yourself
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text!
        let stringRange = Range(range, in:oldText)!
        let newText = oldText.replacingCharacters(in: stringRange,
                                                  with: string)
        doneBarButton.isEnabled = !newText.isEmpty
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideDatePicker()
    }
    
    // MARK: - Actions
    // @IBAction functions never return values
    // when user tap cancel button, send itemDetailsViewControllerDidCancel message to its delegate
    // the question mark indicates that if the delegate is nil, which measn not exist, then don't send the message
    @IBAction func cancel() {
        delegate?.itemDetailsViewControllerDidCancel(self)
    }
    @IBAction func done() {
        //print("Contents of the text field: \(textField.text!)")
        // put values of UI element back into the ChecklistItem obejct
        if let item = itemToEdit {
            item.text = textField.text!
            item.shouldRemind = shouldRemindSwitch.isOn
            item.dueDate = dueDate
            item.scheduleNotification()
            delegate?.itemDetailsViewController(self, didFinishEditing: item)
        }
        else {
            let item = ChecklistItem()
            item.text = textField.text!
            item.checked = false
            item.shouldRemind = shouldRemindSwitch.isOn
            item.dueDate = dueDate
            item.scheduleNotification()
            delegate?.itemDetailsViewController(self, didFinishAdding: item)
        }
    }
    
    @IBAction func dateChanged(_ datePicker: UIDatePicker) {
        // update the dueDate instance variable whenever the date picker value has changed
        dueDate = datePicker.date
        updateDueDateLabel()
    }
    
    @IBAction func shouldRemindToggled(_ switchControl: UISwitch) {
        textField.resignFirstResponder()
        if switchControl.isOn {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) {
                granted, error in
                // do nothing
            }
        }
    }
    
    // MARK: - Custom methods
    // convert date value to text
    func updateDueDateLabel() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dueDateLabel.text = formatter.string(from: dueDate)
    }
    
    func showDatePicker() {
        datePickerVisible = true
        let indexPathDateRow = IndexPath(row: 1, section: 1)
        let indexPathDatePicker = IndexPath(row: 2, section: 1)
        if let dateCell = tableView.cellForRow(at: indexPathDateRow) {
            dateCell.detailTextLabel!.textColor =
                dateCell.detailTextLabel!.tintColor
        }
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPathDatePicker], with: .fade)
        tableView.reloadRows(at: [indexPathDateRow], with: .none)
        tableView.endUpdates()
        datePicker.setDate(dueDate, animated: false)
    }

    func hideDatePicker() {
        if datePickerVisible {
            datePickerVisible = false
            let indexPathDateRow = IndexPath(row: 1, section: 1)
            let indexPathDatePicker = IndexPath(row: 2, section: 1)
            if let cell = tableView.cellForRow(at: indexPathDateRow) {
                cell.detailTextLabel!.textColor = UIColor.black
            }
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPathDateRow], with: .none)
            tableView.deleteRows(at: [indexPathDatePicker], with: .fade)
            tableView.endUpdates()
        }
    }

}
