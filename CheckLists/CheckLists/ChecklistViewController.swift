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
    var items: [ChecklistItem]
    
    required init?(coder aDecoder: NSCoder) {
        items = [ChecklistItem]()
        print("initializer goes first")
        super.init(coder: aDecoder)
    }
    
    // this initializer is no longer needed because we load the data from document folder
    // this initializer is called when the view controller is instantiated from a storyboard
    //    required init?(coder aDecoder: NSCoder) {
    //        // values into your instance variables and constants
    //        super.init(coder: aDecoder)
    
    //      // other initialization code, such as calling methods, goes here
    //    }
    
    // delegate handles the messages sent from itemDetailsViewController here
    func itemDetailsViewControllerDidCancel(_ controller: ItemDetailsViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    // 1. insert new item to the array, which is the data model
    // 2. add one more row to the table view. 
    func itemDetailsViewController(_ controller: ItemDetailsViewController, didFinishAdding item: ChecklistItem) {
        let newRowIndex = items.count
        items.append(item)
        
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
        navigationController?.popViewController(animated: true)
        saveChecklistItems()
    }
    
    func itemDetailsViewController(_ controller: ItemDetailsViewController, didFinishEditing item: ChecklistItem) {
        if let index = items.firstIndex(of: item) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                configureText(for: cell, with: item)
            }
        }
        navigationController?.popViewController(animated: true)
        saveChecklistItems()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // large fonts for navigation controller title
        navigationController?.navigationBar.prefersLargeTitles = true
        print("viewDidLoad goes next")
        print("data file path is: \(dataFilePath())")
        loadChecklistitems()
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
        saveChecklistItems()
        
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
        saveChecklistItems()
    }
    
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
                controller.itemToEdit = items[indexPath.row]
            }
        }
    }
    
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
    
    // get the full path to the app's document folder, any app uses a 32-character long name as its ID to create its own document folder, every app will have a different folder
    func documentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // constrct the full path to the file that will store the checklists items
    func dataFilePath() -> URL {
        return documentDirectory().appendingPathComponent("Checklists.plist")
    }
    
    // using encoder to save checklist to a plist file under application's document folder
    func saveChecklistItems(){
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(items)
            try data.write(to: dataFilePath(), options: Data.WritingOptions.atomic)
        } catch {
            print("Error encoding item array!")
        }
    }
    
    // load the Checklistitems from document folder
    // 1. load the content in the given path to a data, question mark indicates that it will return nil if the content doesn't exists
    // 2. decode the data into an array of type ChecklistItem, decoder needs to know the type
    func loadChecklistitems(){
        let path = dataFilePath()
        if let data = try? Data(contentsOf: path) {
            let decoder = PropertyListDecoder()
            do {
                items = try decoder.decode([ChecklistItem].self, from: data)
            } catch {
                print("Error decoding item array!")
            }
        }
    }

}

