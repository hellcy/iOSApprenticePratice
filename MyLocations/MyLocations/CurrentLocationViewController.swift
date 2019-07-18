//
//  FirstViewController.swift
//  MyLocations
//
//  Created by yuan cheng on 5/7/19.
//  Copyright © 2019 Yuan Cheng. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false // flag to check if app is now updating locations
    var lastLocationError: Error?
    
    // reverse gencodeing variables
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?
    
    // track the time for updating location
    var timer: Timer?
    
    var managedObjectContext: NSManagedObjectContext!

    // Override: viewDidload() method is from its superclass: UIViewController, and bacause of CurrentLocationViewController is inherited from UIViewController, it has all its variables and methods. But it makes some changes to fit its own purpose, so we override this method, and super.viewDidLoad means that we simply call the method in its super class. 
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updateLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    // just before view disappear and go to the locationDetails view
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Action methods
    
    @IBAction func getLocation(){
        // asking for permission to get current location
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        // display alert if don't have user's permission on using location services
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil // since we may restart getting locations, so clear out the previous error
            startLocationManager()
        }
        updateLabels()
    }
    
    // MARK: - CLLocationManagerDelegate
    // when app wants to get location but doesn't have access to it(user denied)
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
        
        if (error as NSError).code ==
            CLError.locationUnknown.rawValue {
            return
        }
        // if error is some serious error, stop updating locations.
        lastLocationError = error
        stopLocationManager()
        updateLabels()
    }
    
    // when app got the current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        // 1. because getting locations consume battery power a lot, so we don't want to call this service too often, if last location is got less than 5 seconds ago, we simply end the method by return nothing.
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        // 2. if the location results accuracy less than 0, it doesn't make any sense, so we ignore these.
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = location {
            distance = newLocation.distance(from: location)
        }
        // 3. if this is the first time we get location, location variable might be nil at first. Or if the newLocation accuracy is better than the current accuracy, we replace the new location results with the current location results.
        if location == nil || location!.horizontalAccuracy >
            newLocation.horizontalAccuracy {
            // 4. update location results and clear out previous error bacause this time we successfully got location results
            lastLocationError = nil
            location = newLocation
            // 5. if the new location results accuracy is better than the desired accuracy, than we finish updating the locations
            if newLocation.horizontalAccuracy <=
                locationManager.desiredAccuracy {
                print("*** We're done!")
                stopLocationManager()
                
                if distance > 0 {
                    performingReverseGeocoding = false
                }
            }
            
            if !performingReverseGeocoding {
                print("*** Going to geocode \(distance)")
                performingReverseGeocoding = true
                // Closure: compeltionHandler is where you call the location services and got values in placeamrks and error. It is like a callback method in other languages, where user can also do other things with the app while it is getting location results. The difference between the delegate methods and closure is that you can put all reletive variables in the same place, whereas delegate has to be in separate methods.
                geocoder.reverseGeocodeLocation(newLocation, completionHandler: {
                    placemarks, error in
                    self.lastGeocodingError = error
                    if error == nil, let p = placemarks, !p.isEmpty {
                        self.placemark = p.last!
                    } else {
                        self.placemark = nil
                    }
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                })
            }
            
        }
        // if the distance is not far from the last location and it has been more than 10 seconds since you have received last reading, than force stop because it is unlikely that you will receive any better results
        else if distance < 1 {
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            if timeInterval > 10 {
                print("*** Force done!")
                stopLocationManager()
                updateLabels()
            }
        }
        else {
            print("\(distance)")
        }
    }
    
    // MARK: - Custom methods
    // display an alert to user, when they tapped on getButton but the app doesn't have permission to use the location services
    func showLocationServicesDeniedAlert(){
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "Please enable location services for this app in Settings.",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default,
                                     handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f",
                                        location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f",
                                         location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
            
            // display address to the label
            if let placemark = placemark {
                addressLabel.text = string(from: placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            let statusMessage: String
            if let error = lastLocationError as NSError? {
                if error.domain == kCLErrorDomain &&
                    error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled" // check if user has denied app from getting locations
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled" // check if device has disabled location services for all apps
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get My Location' to Start"
            }
            messageLabel.text = statusMessage
        }
         configureGetButton()
    }
    
    // stop updating locations, also change the updatingLocation flag to false
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            
            // stop the timer when user tapped 'stop' button or desired location found before time is up
            if let timer = timer {
                timer.invalidate()
            }
        }
    }
    
    // start updating locations.
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy =
            kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)
        }
    }
    
    // config the text of getButton, if we are updating locations, change text to 'Stop', or change text to 'Get my location'
    func configureGetButton() {
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
        } else {
            getButton.setTitle("Get My Location", for: .normal)
        }
    }
    
    // convert CLPlacemark to string
    func string(from placemark: CLPlacemark) -> String {
        // 1. empty variable string for address
        var line1 = ""
        // 2. subThoroughfare is just a fancy name for street number
        line1.add(text: placemark.subThoroughfare)
        // 3. thoroughfare is the street number
        line1.add(text: placemark.thoroughfare, separatedBy: " ")
        
        var line2 = ""
        // 4. locality = city, administrativeArea = state, postalCode = postal Code
        line2.add(text: placemark.locality)
        line2.add(text: placemark.administrativeArea, separatedBy: " ")
        
        line1.add(text: line2, separatedBy: "\n")
        return line1
    }
    
    // this method has @objc keyword before its name because we declared it as being accessiable from Objective-C
    @objc func didTimeOut(){
        print("*** Time out")
        stopLocationManager()
        updateLabels()

        if location == nil {
            lastLocationError = NSError(domain: "MyLocationErrorDomain", code: 1, userInfo: nil)
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // go to LocationDetailsViewController, so pass all values needed from here
        if segue.identifier == "TagLocation" {
            let controller = segue.destination as! LocationDetailsViewController
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
            // pass the core data variable to the next view. CurrentLocationViewController doesn't really need managedObjectContext, it only adds it as its property to pass it along.
            controller.managedObjectContext = managedObjectContext
        }
    }
}

