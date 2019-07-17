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
}
