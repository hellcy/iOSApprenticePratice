//
//  ViewController.swift
//  CheckLists
//
//  Created by yuan cheng on 2/7/19.
//  Copyright © 2019 Yuan Cheng. All rights reserved.
//

import UIKit

class ChecklistViewController: UITableViewController {
    
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
    }

    // UITableView asks for the number of rows in the section, since we only have 5 rows to display, we simply return 5
    override func tableView(_ tableView: UITableView,           // parameter 1: underscore is used when we don't want a external name, external name is the name we used to call the method, we often set first parameter name to _ when the methods are come from frameworks
                            numberOfRowsInSection section: Int) // parameter 2: numberOfRowsInSection is the external name, section is the local parameter name, we use this name in the method
                            -> Int {                            // return value
        return 5
    }
    
    // then the UITableView asks for the data to display on that cell, so we return a copy of the cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for: indexPath)
        
        // using tags is the same as using @IBOutlet to refernce object in the storyboard
        let label = cell.viewWithTag(1000) as! UILabel
        
        if indexPath.row == 0
        {
            label.text = row0item.text
        }
        else if indexPath.row == 1
        {
            label.text = row1item.text
        }
        else if indexPath.row == 2
        {
            label.text = row2item.text
        }
        else if indexPath.row == 3
        {
            label.text = row3item.text
        }
        else if indexPath.row == 4
        {
            label.text = row4item.text
        }
        configCheckmark(for: cell, at: indexPath)
        return cell
    }
    
    // toggle checkmark on and off
    // cell, to display data, in this exammple we have 5 cells, cells can be reused
    // row, the data itself
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at:  indexPath)
        {
            if indexPath.row == 0 {
                row0item.checked = !row0item.checked
            }
            else if indexPath.row == 1 {
                row1item.checked = !row1item.checked
            }
            else if indexPath.row == 2 {
                row2item.checked = !row2item.checked
            }
            else if indexPath.row == 3 {
                row3item.checked = !row3item.checked
            }
            else if indexPath.row == 4 {
                row4item.checked = !row4item.checked
            }
            configCheckmark(for: cell, at: indexPath)

        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func configCheckmark(for cell: UITableViewCell, at indexPath: IndexPath)
    {
        var isChecked = false
        if indexPath.row == 0 {
            isChecked = row0item.checked
        }
        else if indexPath.row == 1 {
            isChecked = row1item.checked
        }
        else if indexPath.row == 2 {
            isChecked = row2item.checked
        }
        else if indexPath.row == 3 {
            isChecked = row3item.checked
        }
        else if indexPath.row == 4 {
            isChecked = row4item.checked
        }
        
        if isChecked {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }

}

