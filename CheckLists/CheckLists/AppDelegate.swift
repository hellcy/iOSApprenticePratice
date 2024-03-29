//
//  AppDelegate.swift
//  CheckLists
//
//  Created by yuan cheng on 2/7/19.
//  Copyright © 2019 Yuan Cheng. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    // let create a constant to a reference
    // so we could change its value, but we cannot move it or let dataModel points to another reference
    let dataModel = DataModel()

    // more about exclamation mark! 'window' variable is an optinal variable, so it could be nil sometimes, but if we can guarantee that the window will never be nil by the time we call this method, then we can use the exclamation method to force unwrap the optional variable to get its value. 'window' is the storyboard for apps, so basically it will never be nil when the app is running, so we use the exclamtion mark.
    // The reason Swift design 'window' variable to be an optional variable is because when we are swithcing apps, window need to load another storyboard from another app, so there could be a short period of time that the value of window is nil, because it is still loading the storyboard.
    // rootViewController is the initial view controller when we start the app, in this case it is the Navigation controller
    // go through the view controller array of navigation controller to find the right controller we need, in this case, it is the AllListViewController
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //Override point for customization after application launch.
        let navigationController = window!.rootViewController as! UINavigationController
        let controller = navigationController.viewControllers[0] as! AllListsViewController
        controller.dataModel = dataModel
        
        // notification authorization
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        saveData()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveData()
    }
    
    func saveData(){
        dataModel.saveChecklists()
    }
    
    // MARK:- User Notification Delegates
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Received local notification \(notification)")
    }


}

