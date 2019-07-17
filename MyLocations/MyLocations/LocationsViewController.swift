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
    lazy var fetchedResultsController: NSFetchedResultsController<Location> = {
        // 1 create a fetch request that describes the search parameters of the object. Define Location in <> to tell the Request that we are going to fetch Location objects
        let fetchRequest = NSFetchRequest<Location>()
        // 2 tell the fetch request that I am looking for Location entities
        let entity = Location.entity()
        fetchRequest.entity = entity
        // 3 tell the fetch request to sort on the date attribute
        let sortDescriptor1 = NSSortDescriptor(key: "category", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        
        fetchRequest.fetchBatchSize = 20
        // lazy initilization: don't allocate them until you first use them, makes loading quicker and saves memory
        // make this view contorller to be fetchedResultsController's delegate, whenever its changes, we update the table view.
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObejctContext, sectionNameKeyPath: "category", cacheName: "Locations")
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    // deinit is called when this view controller is destroied, we don't want to listen to NSFetchResultsController anymore if LocationsViewController doesn't exists anymore, in practice, LocationsViewController will never be destroied when app is running since its the top level view controller, but it is a good defensive programming to write deinit methods.
    deinit {
        fetchedResultsController.delegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performFetch()
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    // MARK: - Table View Delegates
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        
        let location = fetchedResultsController.object(at: indexPath)
        cell.configure(for: location)
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.name
    }
    
    // this method enable swipe-to-delete, when we delete a row, gets the Location object and tell the context to delete the object, this will trigger the NSFetchedResultsController to send a notification to the delegate, the update the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let location = fetchedResultsController.object(at: indexPath)
            managedObejctContext.delete(location)
            do {
                try managedObejctContext.save()
            } catch {
                fatalCoreDataError(error)
            }
        }
    }
    
    // MARK: - Navgition
    
    // sender has type of any, if the segue was triggered from a table view, sender is of type UITableViewCell, if segue was triggered from a button, sender is of type UIBarButtonItem...
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // if EditLocation, pass the Core Data and the selected location to the LocationDetailsViewController
        if segue.identifier == "EditLocation" {
            let controller = segue.destination as! LocationDetailsViewController
            controller.managedObjectContext = managedObejctContext
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                let location = fetchedResultsController.object(at: indexPath)
                controller.locationToEdit = location
            }
        }
    }
    
    // MARK: - Private Methods
    
    func performFetch(){
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
    }
}

// MARK: - NSFetchResultsController Delegate Extension
extension LocationsViewController : NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("*** NSFetchResultsChangeInsert (object)")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            print("*** NSFetchResultsChangeDelete (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            print("*** NSFetchResultsChangeUpdate (object)")
            if let cell = tableView.cellForRow(at: indexPath!) as? LocationCell {
                let location = controller.object(at: indexPath!) as! Location
                cell.configure(for: location)
            }
        case .move:
            print("*** NSFetchResultsChangeMove (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            print("*** NSFetchResultsChangeInsert (section)")
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            print("*** NSFetchResultsChangeDelete (section)")
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .update:
            print("*** NSFetchResultsChangeUpdate (section)")
        case .move:
            print("*** NSFetchResultsChangeMove (section)")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerDidChangeContent")
        tableView.endUpdates()
    }
}
