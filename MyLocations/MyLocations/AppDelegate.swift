//
//  AppDelegate.swift
//  MyLocations
//
//  Created by yuan cheng on 5/7/19.
//  Copyright © 2019 Yuan Cheng. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // variables to access Core Data
    // lazy variable will not execute the code in the {}() block until someone asks for it. In this case, it is at the didFinishLaunchingWithOptions when we pass managedObjctContext to the CurrentLocationViewController
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: {
            storeDescription, error in
            if let error = error {
                fatalError("Could load data store: \(error)")
            }
        })
        return container
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = self.persistentContainer.viewContext

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let tabController = window!.rootViewController as! UITabBarController
        if let tabViewControllers = tabController.viewControllers {
            // finds the CuurentLocationViewController and pass the managedObjectContext property to it.
            var navController = tabViewControllers[0] as! UINavigationController
            let controller1 = navController.viewControllers.first as! CurrentLocationViewController
            controller1.managedObjectContext = managedObjectContext
            // LocationsViewController in the second tab also needs managedObjectContext, so we need to pass the object to this view controller as well
            navController = tabViewControllers[1] as! UINavigationController
            let controller2 = navController.viewControllers.first as! LocationsViewController
            controller2.managedObejctContext = managedObjectContext
            let _ = controller2.view
            // pass managedObjectContext to the third tab (Map View)
            navController = tabViewControllers[2] as! UINavigationController
            let controller3 = navController.viewControllers.first as! MapViewController
            controller3.managedObjectContext = managedObjectContext
        }
        
        print(applicationDocumentDirectory)
        
        // listen for the notification calls for CoreDataSaveFailed
        listenForFatalCoreDataNotifications()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - Helper methods
    func listenForFatalCoreDataNotifications(){
        // 1 whenever a CoreDataSaveFailedNotification is posted, perform the following code in the closure
        NotificationCenter.default.addObserver(forName: CoreDataFailedNotification, object: nil, queue: OperationQueue.main, using: { notification in
            // 2 set up the error message, triple quotes indicates a multi-line string
            let message = """
There was a fatal error in the app and it cannot continue.

Press OK to terminate the app. Sorry for the inconvenience.
"""
            // 3 create a UIAlertController to show the error message
            let alert = UIAlertController(title: "Internal Error", message: message, preferredStyle: .alert)
            // 4 add an action for the alert's OK button
            let action = UIAlertAction(title: "OK", style: .default) {
                _ in
                let exception = NSException(name: NSExceptionName.internalInconsistencyException, reason: "Fatal Core Data error", userInfo: nil)
                exception.raise()
            }
            alert.addAction(action)
            
            // 5 use a view controller to present the alert, simply use the root view controller is fine, and in this app the root view controller is the tab bar controller
            let tabController = self.window!.rootViewController!
            tabController.present(alert, animated: true, completion: nil)
        })
    }


}

