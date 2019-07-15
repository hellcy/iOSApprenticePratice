//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by yuan cheng on 8/7/19.
//  Copyright © 2019 Yuan Cheng. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

// this is a private global variable, it lives outside of the LocationDetailsViewController but only visible inside it. so we don't need to create a instance of it everytime we go to LocationDetailsViewController, the reason is that dataFormatter is a quiet expensive variable to create, it takes time and battery. So we want to reuse it as much as possible.
// what behind the dateFormatter global is a closure, it creates and initializes the new DateFormatter object, and return its value to the global constant.
// globals are always used in a lazy fasion, it is called lazy loading, meaning that DateFormatter object is not performed until the first time the dateFormatter global is used in the app
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

class LocationDetailsViewController: UITableViewController {
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    // CLLocationCoordinate2D is a struct, struct can also have variables and methods, but unlike class, struct cannot inherite from one another, Structs are more lightweight than classes, they are often used to pass a set of values
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    
    var categoryName = "No Category"
    
    var managedObjectContext: NSManagedObjectContext!
    var date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextView.text = ""
        categoryLabel.text = categoryName
        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        
        dateLabel.text = format(date: date)
        
        // Hide keyboard when user tapped somewhere else other than the textView table cell
        // gestureRecongnizer can recognize a tap, when this happens, a message will be sent to 'target', and the 'action' is the message to send.
        let gestureRecongnizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecongnizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecongnizer)
    }
    
    // MARK: - Navigation
    // prepare method is the place for passing values
    // here we are passing categoryName value to another view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
    //MARK: - Actions
    @IBAction func done(){
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
        hudView.text = "Tagged"
        
        // 1 create a new location instance, initialize it with managedObjectContext
        let location = Location(context: managedObjectContext)
        // 2 assign values to location
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        // 3 save to data store, catch failures if save was not successful
        do {
            try managedObjectContext.save()
            // using the closure outside the method: trailing closure syntax
            // go back to the previous view after a certain period of time, asyncAfter method takes a closure as its second parameter, everything inside the closure will not be executed after some time.
            afterDelay(0.6) {
                hudView.hide()
                self.navigationController?.popViewController(animated: true)
            }
        } catch {
            // 4 output the error message
            fatalCoreDataError(error)
        }
    }
    
    @IBAction func cancel(){
        navigationController?.popViewController(animated: true)
    }
    
    // unwind segue is an action method that takes a segue as its parameter, it will leave the source view and go to this view, also could pass values from that view to this view.
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
    
    // MARK: - Table View Delegates
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Decription text view
        if indexPath.section == 0 && indexPath.row == 0 {
            return 88
        }
        // Address
        else if indexPath.section == 2 && indexPath.row == 2 {
            // 1.set the width of the label to be 120 points less than the width of the entire view, and height as much as possible so we can word-wrapping
            // difference between bounds and frame:
            // frame: describes the position and size of a view in its parent view.
            // bound: describes the position and size inside the view
            addressLabel.frame.size = CGSize(width: view.bounds.size.width - 120, height: 10000)
            // 2. reduce the height to fit the words
            addressLabel.sizeToFit()
            // 3.
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 16
            // 4. add a margin to the label
            return addressLabel.frame.size.height + 20
        }
        // other table cells
        else {
            return 44
        }
    }
    
    // the app only response to the first two sections of the table, the third section is read only
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    // when user tapped on the decription cell, let the textView become active so the keyboard will come up
    // there is a margin between the textView and the frame of the cell that contains the textView, so there is a small chance when user tapped inside the cell, but outside the textView. Normally, the keyboard wouldn't come up because user didn't tap on the textView, so this method is to let the keyboard come up even when user tapped outside the textView but inside the table cell.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        }
    }
    
    //MARK:- Private Methods
    // convert CLPlacemark to String
    func string(from placemark: CLPlacemark) -> String {
        var text = ""
        
        if let s = placemark.subThoroughfare {
            text += s + " "
        }
        if let s = placemark.thoroughfare {
            text += s + ", "
        }
        if let s = placemark.locality {
            text += s + ", "
        }
        if let s = placemark.administrativeArea {
            text += s + " "
        }
        if let s = placemark.postalCode {
            text += s + ", "
        }
        if let s = placemark.country {
            text += s
        }
        return text
    }
    
    // convert Date to String
    func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        // indexPath returned by indexPathForRow is an optional instance, becasue when user tapped on somewhere between two sections or on the section header, indexPath will have no value.
        let indexPath = tableView.indexPathForRow(at: point)
        
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return
        }
        descriptionTextView.resignFirstResponder()
    }
    
}
