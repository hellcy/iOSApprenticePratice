//
//  AddItemViewController.swift
//  CheckLists
//
//  Created by yuancheng on 2/7/19.
//  Copyright © 2019 Yuan Cheng. All rights reserved.
//

import UIKit

class AddItemViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
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
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func done() {
        print("Contents of the text field: \(textField.text!)")
        
        navigationController?.popViewController(animated: true)
    }


}
