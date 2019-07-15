//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by yuan cheng on 15/7/19.
//  Copyright © 2019 Yuan Cheng. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
    var managedObejctContext: NSManagedObjectContext!
    var locations = [Location]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 1 create a fetch request that describes the search parameters of the object. Define Location in <> to tell the Request that we are going to fetch Location objects
        let fetchRequest = NSFetchRequest<Location>()
        // 2 tell the fetch request that I am looking for Location entities
        let entity = Location.entity()
        fetchRequest.entity = entity
        // 3 tell the fetch request to sort on the date attribute
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            // 4 fetch the array of locations and store to local variable
            locations = try managedObejctContext.fetch(fetchRequest)
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    // MARK: - Table View Delegates
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        
        let location = locations[indexPath.row]
        cell.configure(for: location)
        
        return cell
    }
    
    // MARK: - Navgition
    
    // sender has type of any, if the segue was triggered from a table view, sender is of type UITableViewCell, if segue was triggered from a button, sender is of type UIBarButtonItem...
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // if EditLocation, pass the Core Data and the selected location to the LocationDetailsViewController
        if segue.identifier == "EditLocation" {
            let controller = segue.destination as! LocationDetailsViewController
            controller.managedObjectContext = managedObejctContext
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                let location = locations[indexPath.row]
                controller.locationToEdit = location
            }
        }
    }
}
