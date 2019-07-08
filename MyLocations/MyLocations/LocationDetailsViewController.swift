//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by yuan cheng on 8/7/19.
//  Copyright © 2019 Yuan Cheng. All rights reserved.
//

import UIKit
import CoreLocation

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextView.text = ""
        categoryLabel.text = ""
        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        
        dateLabel.text = format(date: Date())
    }
    
    //MARK: - Actions
    @IBAction func done(){
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func cancel(){
        navigationController?.popViewController(animated: true)
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
    
}
