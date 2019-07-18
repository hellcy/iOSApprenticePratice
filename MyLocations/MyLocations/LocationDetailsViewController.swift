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
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    
    // CLLocationCoordinate2D is a struct, struct can also have variables and methods, but unlike class, struct cannot inherite from one another, Structs are more lightweight than classes, they are often used to pass a set of values
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    
    var categoryName = "No Category"
    
    var managedObjectContext: NSManagedObjectContext!
    var date = Date()
    
    // didSet block will be called everytime you put a new value into that variable. Because prepare is performed in LocationsViewController, so didSet is called before viewDidLoad start, so we already have the right values.
    var locationToEdit: Location? {
        // didSet block will be performed when the variable is being set to some value
        didSet {
            if let location = locationToEdit {
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date
                coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                placemark = location.placemark
            }
        }
    }
    var descriptionText = ""
    
    // if the photo is not picked, the image variable would be nil, so we declare it as optional
    var image: UIImage? {
        // when image has some value, put this image into the image view
        didSet {
            if let theImage = image {
                imageView.image = theImage
                imageView.isHidden = false
                imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
                addPhotoLabel.isHidden = true
            }
        }
    }
    
    var observer: Any!
    
    deinit {
        print("*** deinit \(self)")
        NotificationCenter.default.removeObserver(observer)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // if locationToEdit is not nil, set the title to Edit Location
        if let location = locationToEdit {
            title = "Edit Location"
            if location.hasPhoto {
                if let theImage = location.photoImage {
                    image = theImage
                }
            }
        }
        descriptionTextView.text = descriptionText
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
        
        // dismiss all alerts and action sheet when app is going to background
        listenForBackgroundNotification()
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
        
        let location: Location
        if let temp = locationToEdit {
            // if locationToEdit is not null, we are editing locations, so instead of creating a new location from Core Data, we grab values from temp.
            hudView.text = "Updated"
            location = temp
        } else {
            // 1 create a new location instance, initialize it with managedObjectContext
            hudView.text = "Tagged"
            location = Location(context: managedObjectContext)
            location.photoID = nil
        }
        
        // 2 assign values to location
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        
        // save image id to location
        if let image = image {
            // a if current location doesn't have a photo, get a new photoID
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID() as NSNumber
            }
            // b converts image to jpeg format, returns a data object, which contains binary data of the image
            if let data = image.jpegData(compressionQuality: 0.5) {
                // c save the data object to the path 
                do {
                    try data.write(to: location.photoURL, options: .atomic)
                } catch {
                    print("*** Error writing file: \(error)")
                }
            }
        }
        
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
        switch(indexPath.section, indexPath.row) {
        // Decription text view
        case (0, 0):
            return 88
        // image view
        case (1, _):
            return imageView.isHidden ? 44 : 280
        // address
        case (2, 2):
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
        // other table cells
        default:
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
        // tapped Description cell
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        }
        // tapped Add Photo cell
        else if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            pickPhoto()
        }
    }
    
    //MARK:- Private Methods
    // convert CLPlacemark to String
    func string(from placemark: CLPlacemark) -> String {
        var line = ""
        line.add(text: placemark.subThoroughfare)
        line.add(text: placemark.thoroughfare, separatedBy: " ")
        line.add(text: placemark.locality, separatedBy: ", ")
        line.add(text: placemark.administrativeArea, separatedBy: ", ")
        line.add(text: placemark.postalCode, separatedBy: " ")
        line.add(text: placemark.country, separatedBy: ", ")

        return line
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
    
    func listenForBackgroundNotification() {
        // this method has a closure that capture the self object, which is the LocationDetailsViewController itself, and because of that, this closure holds a strong reference to this view, so when we close the view, we can't destory it because there is still a strong reference to it. So we make a weakSelf. Variable inside [] is a capture list, includes all variables that will be captured by this closure
        observer = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { [weak self] _ in
            // dismiss all alerts and action sheet when app is go to the background.
            // the image picker and action sheet are both presented as modal view controllers, that appear above everything else, UIViewControoler's presentedViewController property has a reference to that modal view controller
            if let weakSelf = self {
                if weakSelf.presentedViewController != nil {
                    weakSelf.dismiss(animated: false, completion: nil)
                }
                weakSelf.descriptionTextView.resignFirstResponder()
            }
        }
    }
    
}

// extension is just to group all the conceptually related methods together, you could write these methods in the main class, you also could create a new swift file and add the extensions there
// To create an image picker, you have to conform both Delegates, but you don't need to implement any of the UINavigationControllerDelegate methods
extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // create a imagePicker instance and config it, then present it, we don't need to add a View Controller in the storyboard for imagePicker
    func takePhotoWithCamera(){
        let imagePicker = MyImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        // allow users to do some quick editing like crop to the image selected
        imagePicker.allowsEditing = true
        imagePicker.view.tintColor = view.tintColor
        present(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary(){
        let imagePicker = MyImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.view.tintColor = view.tintColor
        present(imagePicker, animated: true, completion: nil)
    }
    
    // check if device camera is available, if true, display a menu letting users to choose whether pick image from photo library or take new image
    func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    
    // display the alert
    func showPhotoMenu() {
        // .actionSheet sliders in from bottom and offers the user one of several choices
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actCancel)
        // _ is a wildcard represents the parameter passes to the closure, in this case, this parameter is the UIAlertAction, but we don't need it in the closure, so we use _ to represent it, means we don't care its name
        let actPhoto = UIAlertAction(title: "Take Photo", style: .default, handler: {
            _ in self.takePhotoWithCamera()
        })
        alert.addAction(actPhoto)
        let actLibrary = UIAlertAction(title: "Choose From Library", style: .default, handler: {
        _ in self.choosePhotoFromLibrary()
        })
        alert.addAction(actLibrary)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Image Picker Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // pass the selected image to the local image variable, then call 'show' method
        // info is a dictionary, to retrieve the image object, we give info the corrent string key UIImagePickerController.InfoKey.editedImage
        image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        // after set the image, image should already in the image view, but we also need to update table cell height to correctly display the whole image, so we reload table data, all table delegate methods should be called and table cells should be correctly re-rendered
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
