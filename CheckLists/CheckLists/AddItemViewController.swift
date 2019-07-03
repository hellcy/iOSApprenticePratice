//
//  AddItemViewController.swift
//  CheckLists
//
//  Created by yuancheng on 2/7/19.
//  Copyright © 2019 Yuan Cheng. All rights reserved.
//

import UIKit

// a protocol are a group of methods without implementation, any object that use this protocol must have these methods declared
protocol AddItemViewControllerDelegate: class {
    func addItemViewControllerDidCancel(_ controller: ItemDetailsViewController)
    
    func addItemViewController(_ controller: ItemDetailsViewController, didFinishAdding item: ChecklistItem)
    
    func addItemViewController(_ controller: ItemDetailsViewController, didFinishEditing item: ChecklistItem)
}

class ItemDetailsViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    // weak: the relationship between the view and its delegate. ChecklistView has a strong reference to AddItemView, and now AddItemView only has a weak reference to ChecklistView, so there is no ownership cycle, no potenital memory leak
    // delegate are always made weak
    // question mark: the delegates are optional
    weak var delegate: AddItemViewControllerDelegate?
    
    var itemToEdit: ChecklistItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        if let itemToEdit = itemToEdit {
            title = "Edit Item"
            textField.text = itemToEdit.text
            doneBarButton.isEnabled = true
        }
    }
    
    // disable cell selection for adding item
    // the func is expected to return a IndexPath type value, but the question mark at the end indicates that it also accepts nil value, here it means, no rows would be selected
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath)
        -> IndexPath? {
            return nil
    }
    
    // make textField focus when enter the screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    // delegate method for textField
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
    
    // @IBAction functions never return values
    // when user tap cancel button, send addItemViewControllerDidCancel message to its delegate
    // the question mark indicates that if the delegate is nil, which measn not exist, then don't send the message
    @IBAction func cancel() {
        delegate?.addItemViewControllerDidCancel(self)
    }
    @IBAction func done() {
        //print("Contents of the text field: \(textField.text!)")
        if let itemToEdit = itemToEdit {
            itemToEdit.text = textField.text!
            delegate?.addItemViewController(self, didFinishEditing: itemToEdit)
        }
        else {
            let item = ChecklistItem()
            item.text = textField.text!
            item.checked = false
            
            delegate?.addItemViewController(self, didFinishAdding: item)
        }
    }


}
