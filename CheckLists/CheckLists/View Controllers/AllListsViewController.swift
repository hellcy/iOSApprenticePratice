//
//  AllListsViewController.swift
//  CheckLists
//
//  Created by yuan cheng on 3/7/19.
//  Copyright © 2019 Yuan Cheng. All rights reserved.
//

import UIKit

class AllListsViewController: UITableViewController, ListDetailViewControllerDelegate, UINavigationControllerDelegate {
    var dataModel: DataModel!
    
    // this method is called when this view is about the become visible, before viewDidAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // this method will be called when the view become visible, check userDefaults and if index is not -1, we perform a certain segue to another view
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // need to set AllListsViewController to be NavigationController's delegate, otherwise delegate method won't be called
        navigationController?.delegate = self
        
        print("viewDidAppear")
        let index = dataModel.indexOfSelectedChecklist
        if index >= 0 && index < dataModel.lists.count {
            let checklist = dataModel.lists[index]
            performSegue(withIdentifier: "ShowChecklist", sender: checklist)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK:- List Detail View Controller Delegates
    func listDetailViewControllerDidCancel(_ controller: ListDetailViewController) {
        navigationController?.popViewController(animated: true)
    }
    func listDetailViewController(_ controller: ListDetailViewController, didFinishAdding checklist: Checklist) {
        dataModel.lists.append(checklist)
        dataModel.sortChecklists()
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
    func listDetailViewController(_ controller: ListDetailViewController, didFinishEditing checklist: Checklist) {
        dataModel.sortChecklists()
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }

    // MARK:- UITable View Delegates
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataModel.lists.count
    }

    // this method is called when new row of data is ready to be displayed, we assign the properties of checklist(the data) to the cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = makeCell(for: tableView)
        let checklist = dataModel.lists[indexPath.row]
        cell.textLabel!.text = checklist.name
        let count = checklist.countUncheckedItems()
        if checklist.items.count == 0 {
            cell.detailTextLabel!.text = "(No Items)"
        } else if count == 0 {
            cell.detailTextLabel!.text = "All done!"
        } else {
            cell.detailTextLabel!.text = "\(count) Remaining"
        }
        cell.accessoryType = .detailDisclosureButton
        cell.imageView!.image = UIImage(named: checklist.iconName)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // store last opened checklist in the userDefaults
        dataModel.indexOfSelectedChecklist = indexPath.row
        
        let checklist = dataModel.lists[indexPath.row]
        performSegue(withIdentifier: "ShowChecklist", sender: checklist)
    }
    
    // swipe and delete the checklist rows
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        dataModel.lists.remove(at: indexPath.row)
        
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    // this method is the same as using the EditChecklist segue
    // when tapped the accessory button, find the ListDetailViewController, set its delegate
    // pass the checklistToEdit to its properties, then show the view
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let controller = storyboard!.instantiateViewController(withIdentifier: "ListDetailViewController") as! ListDetailViewController
        
        controller.delegate = self
        let checklist = dataModel.lists[indexPath.row]
        controller.checklistToEdit = checklist
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - UIStoryboardSegue prepare delegate
    // remember the sender is the item that trigger the segue
    // if ShowChecklist is performed, the sender now is the Checklist cell we tapped, so pass it to the ChecklistViewController, we need it to change the title name
    // if AddChecklist is performed, we make this controller the delegate of ListDetailViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowChecklist" {
            let controller = segue.destination as! ChecklistViewController
            controller.checklist = sender as! Checklist
            print("prepare method at AllListsViewController")
        } else if segue.identifier == "AddChecklist" {
            let controller = segue.destination as! ListDetailViewController
            controller.delegate = self
        }
    }
    
    // MARK: - UINavigationController delegate
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // was the back button tapped?
        if viewController === self {
            dataModel.indexOfSelectedChecklist = -1
            print("willShow: userdefaults now -1")
        }
    }
    
    // MARK: - custom methods
    // when the data row is asking for a cell to be displayed, we check if there is a idle cell available first using dequeueResuableCell, if not, we then create a new cell for the data
    func makeCell(for tableView: UITableView) -> UITableViewCell{
        let cellIdentifier = "Cell"
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            return cell
        }
        else {
            // subtitle style add a second, smaller label below the main label
            return UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
    }

    // MARK: - Navigation

    // TODO: - Know the comments
    
    // FIXME: - Understand the structure
}
