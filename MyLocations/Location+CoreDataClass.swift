//
//  Location+CoreDataClass.swift
//  MyLocations
//
//  Created by yuan cheng on 12/7/19.
//  Copyright © 2019 Yuan Cheng. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

@objc(Location)
public class Location: NSManagedObject, MKAnnotation {
    // to make Location conforms to the MKAnnotation protocol, we need 3 properties: coordicate, title and  subtitle. These variables are all associated with a block of code, they are read-only computed properties, they don't actually store a value in a memory location until you access to them, then they perform their code blocks. They are read-only because they only return a value, you can't assign new values to them.
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    public var title: String? {
        if locationDescription.isEmpty {
            return "(No Description)"
        } else {
            return locationDescription
        }
    }
    
    public var subtitle: String? {
        return category
    }
    
    var hasPhoto: Bool {
        return photoID != nil
    }
    
    var photoURL: URL {
        // assertion is a special debugging tool that is used to check that your code always does something valid
        assert(photoID != nil, "No photo ID set")
        let filename = "Photo-\(photoID!.intValue).jpg"
        return applicationDocumentDirectory.appendingPathComponent(filename)
    }
    
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoURL.path)
    }
    
    class func nextPhotoID() -> Int {
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "PhotoID") + 1
        userDefaults.set(currentID, forKey: "PhotoID")
        userDefaults.synchronize()
        return currentID
    }
    
    // remove the photo from a location
    func removePhotoFile() {
        if hasPhoto {
            do {
                try FileManager.default.removeItem(at: photoURL)
            } catch {
                print("*** Error removing file: \(error)")
            }
        }
    }
}
