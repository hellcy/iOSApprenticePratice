//
//  ViewController.swift
//  CheckLists
//
//  Created by yuan cheng on 2/7/19.
//  Copyright © 2019 Yuan Cheng. All rights reserved.
//

import UIKit

class ChecklistViewController: UITableViewController, AddItemViewControllerDelegate {
    
    // delegate handles the messages sent from AddItemViewController here
    func addItemViewControllerDidCancel(_ controller: AddItemViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    // 1. insert new item to the array, which is the data model
    // 2. add one more row to the table view. 
    func addItemViewController(_ controller: AddItemViewController, didFinishAdding item: ChecklistItem) {
        let newRowIndex = items.count
        items.append(item)
        
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
        navigationController?.popViewController(animated: true)
    }
    
    
    // declare a variable of array type of ChecklistItem
    var items: [ChecklistItem]
    
    required init?(coder aDecoder: NSCoder) {
        
        // initialize the items with an empty array, we still need to initialize all the objects that we will put in the array
        items = [ChecklistItem]()
        
        let row0item = ChecklistItem()
        row0item.text = "Walk the dog"
        row0item.checked = false
        items.append(row0item)
        
        let row1item = ChecklistItem()
        row1item.text = "Brush my teeth"
        row1item.checked = true
        items.append(row1item)

        let row2item = ChecklistItem()
        row2item.text = "Learn iOS development"
        row2item.checked = true
        items.append(row2item)

        let row3item = ChecklistItem()
        row3item.text = "Soccer practice"
        row3item.checked = false
        items.append(row3item)

        let row4item = ChecklistItem()
        row4item.text = "Eat ice cream"
        row4item.checked = true
        items.append(row4item)

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // large fonts for navigation controller title
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    // UITableView asks for the number of rows in the section, since we only have 5 rows to display, we simply return 5
    override func tableView(_ tableView: UITableView,           // parameter 1: underscore is used when we don't want a external name, external name is the name we used to call the method, we often set first parameter name to _ when the methods are come from frameworks
                            numberOfRowsInSection section: Int) // parameter 2: numberOfRowsInSection is the external name, section is the local parameter name, we use this name in the method
                            -> Int {                            // return value
        return items.count
    }
    
    // then the UITableView asks for the data to display on that cell, so we return a copy of the cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for: indexPath)
        
        let item = items[indexPath.row]
        
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
            let item = items[indexPath.row]
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
        items.remove(at: indexPath.row)
        
        // 2
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    // prepare method is invoked when a segue from one screen to another is about to performed
    // as! is a type cast, because destination is the type of UIViewController and AddItemViewController is it subclass
    // then create the connection that make AddItemViewControllerDelegate to be itself, which is ChecklistViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddItem" {
            let controller = segue.destination as! AddItemViewController
            controller.delegate = self
        }
    }
    
    func configureCheckmark(for cell: UITableViewCell, with item: ChecklistItem) {
        if item.checked {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }
    
    func configureText(for cell: UITableViewCell, with item: ChecklistItem) {
        // we can't use @IBOutlet to reference the table cells because we don't know how many cells there will be. If the table view contains static cells, then we can use @IBOutlet
        let label = cell.viewWithTag(1000) as! UILabel
        label.text = item.text
    }

}

