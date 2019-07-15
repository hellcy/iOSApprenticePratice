//
//  Functions.swift
//  MyLocations
//
//  Created by yuan cheng on 12/7/19.
//  Copyright © 2019 Yuan Cheng. All rights reserved.
//

import Foundation

// a global constant that contains the path to the app's Documents directory. It is a global because it is not inside of a class, we are using a closure to initialize the constant, like all globals, this is evaluated lazily the very first time it is used.
let applicationDocumentDirectory: URL = {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}()

// this method is not declared in a class, so it is a free method, can be used anywhere in the project
// the second parameter in this method is a closure, it takes no argument and return nothing. the arrow -> in a method parameter section represents a closure.
func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}

// when Core Data failed to save new data to Data Store, it will pop up a notification and crash the app
let CoreDataFailedNotification = Notification.Name(rawValue: "CoreDataSaveFailedNotification")

// create a notification with a specific name, post this notification out to all objects of the app, anyone can listen to and catch it. In this case, this notification is caught in appDelegate class
func fatalCoreDataError(_ error: Error) {
    print("*** Fatal error: \(error)")
    NotificationCenter.default.post(name: CoreDataFailedNotification, object: nil)
}
