//
//  ViewController.swift
//  CheckLists
//
//  Created by yuan cheng on 2/7/19.
//  Copyright © 2019 Yuan Cheng. All rights reserved.
//

import UIKit

class ChecklistViewController: UITableViewController, ItemDetailsViewControllerDelegate {
    
    // declare a variable of array type of ChecklistItem
    
    var checklist: Checklist!
    
    // this initializer is called when the view controller is instantiated from a storyboard
    required init?(coder aDecoder: NSCoder) {
        // values into your instance variables and constants
        print("initializer at ChecklistViewController") // test
        super.init(coder: aDecoder)
        // other initialization code, such as calling methods, goes here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // large fonts for navigation controller title
        navigationItem.largeTitleDisplayMode = .never
        print("viewDidLoad at ChecklistViewController")
        title = checklist.name
    }
    
    // MARK: - ItemDetails View Controller Delegate
    // delegate handles the messages sent from itemDetailsViewController here
    func itemDetailsViewControllerDidCancel(_ controller: ItemDetailsViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    // 1. insert new item to the array, which is the data model
    // 2. add one more row to the table view. 
    func itemDetailsViewController(_ controller: ItemDetailsViewController, didFinishAdding item: ChecklistItem) {
        let newRowIndex = checklist.items.count
        checklist.items.append(item)
        
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
        navigationController?.popViewController(animated: true)
    }
    
    func itemDetailsViewController(_ controller: ItemDetailsViewController, didFinishEditing item: ChecklistItem) {
        if let index = checklist.items.firstIndex(of: item) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                configureText(for: cell, with: item)
            }
        }
        navigationController?.popViewController(animated: true)
    }

    // MARK: - UITable View delegate
    // UITableView asks for the number of rows in the section, since we only have 5 rows to display, we simply return 5
    override func tableView(_ tableView: UITableView,           // parameter 1: underscore is used when we don't want a external name, external name is the name we used to call the method, we often set first parameter name to _ when the methods are come from frameworks
                            numberOfRowsInSection section: Int) // parameter 2: numberOfRowsInSection is the external name, section is the local parameter name, we use this name in the method
                            -> Int {                            // return value
        return checklist.items.count
    }
    
    // then the UITableView asks for the data to display on that cell, so we return a copy of the cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for: indexPath)
        
        let item = checklist.items[indexPath.row]
        
        configureText(for: cell, with: item)
        configureCheckmark(for: cell, with: item)
        return cell
    }
    
    // toggle checkmark on and off
    // cell, to display data, in this exammple we have 5 cells, cells can be reused
    // row, the data itself
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at:  indexPath)
        {
            let item = checklist.items[indexPath.row]
            item.toggleChecked()
            configureCheckmark(for: cell, with: item)

        }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // swipe to delete rows and cells
    // 1. delete the item from data model
    // 2. delete the row from the table view
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 1
        checklist.items.remove(at: indexPath.row)
        
        // 2
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    // MARK: - UIStoryboardSegue delegate
    // prepare method is invoked when a segue from one screen to another is about to performed
    // as! is a type cast, because destination is the type of UIViewController and itemDetailsViewController is it subclass
    // then create the connection that make itemDetailsViewControllerDelegate to be itself, which is ChecklistViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddItem" {
            let controller = segue.destination as! ItemDetailsViewController
            controller.delegate = self
        }
        else if segue.identifier == "EditItem" {
            let controller = segue.destination as! ItemDetailsViewController
            controller.delegate = self
            
            // sender contains a reference to the control that triggered the segue, in this case is the table view cell, we find its indexPath and assign the correct item to itemToEdit in itemDetailsViewController
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell){
                controller.itemToEdit = checklist.items[indexPath.row]
            }
        }
    }
    
    // MARK: - custom methods
    func configureCheckmark(for cell: UITableViewCell, with item: ChecklistItem) {
        let label = cell.viewWithTag(1001) as! UILabel
        if item.checked {
            label.text = "√"
        } else {
            label.text = ""
        }
    }
    
    func configureText(for cell: UITableViewCell, with item: ChecklistItem) {
        // we can't use @IBOutlet to reference the table cells because we don't know how many cells there will be. If the table view contains static cells, then we can use @IBOutlet
        let label = cell.viewWithTag(1000) as! UILabel
        label.text = item.text
    }

}

