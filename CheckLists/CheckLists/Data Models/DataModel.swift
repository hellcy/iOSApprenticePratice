//
//  DataModel.swift
//  CheckLists
//
//  Created by yuan cheng on 4/7/19.
//  Copyright © 2019 Yuan Cheng. All rights reserved.
//

import Foundation

class DataModel {
    var lists = [Checklist]()
    var indexOfSelectedChecklist: Int {
        get {
            return UserDefaults.standard.integer(forKey: "ChecklistIndex")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ChecklistIndex")
        }
    }
    
    init(){
        loadChecklists()
        registerDefaults()
        handleFirstTime()
        print("data file path is: \(dataFilePath())")

    }
    
    // get the full path to the app's document folder, any app uses a 32-character long name as its ID to create its own document folder, every app will have a different folder
    func documentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // constrct the full path to the file that will store the checklists items
    func dataFilePath() -> URL {
        return documentDirectory().appendingPathComponent("Checklists.plist")
    }
    
    // using encoder to save checklist to a plist file under application's document folder
    func saveChecklists(){
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(lists)
            try data.write(to: dataFilePath(), options: Data.WritingOptions.atomic)
        } catch {
            print("Error encoding item array!")
        }
    }
    
    // load the Checklistitems from document folder
    // 1. load the content in the given path to a data, question mark indicates that it will return nil if the content doesn't exists
    // 2. decode the data into an array of type ChecklistItem, decoder needs to know the type
    func loadChecklists(){
        let path = dataFilePath()
        if let data = try? Data(contentsOf: path) {
            let decoder = PropertyListDecoder()
            do {
                lists = try decoder.decode([Checklist].self, from: data)
                sortChecklists()
            } catch {
                print("Error decoding item array!")
            }
        }
    }
    
    // create a template list when the users open the app for the first time
    func handleFirstTime(){
        let userDefaults = UserDefaults.standard
        let firstTime = userDefaults.bool(forKey: "FirstTime")
        
        if firstTime {
            let checklist = Checklist(name: "List")
            lists.append(checklist)
            
            indexOfSelectedChecklist = 0
            userDefaults.set(false, forKey: "FirstTime")
            userDefaults.synchronize()
        }
    }
    
    func sortChecklists(){
        lists.sort(by: {checklist1,checklist2 in
            return checklist1.name.localizedStandardCompare(checklist2.name) == .orderedAscending
        })
    }
    
    // when a key doesn't exist, UserDefault will return 0, we don't want that because that's a valid row number, so instead we set the key and initial value when app starts.
    func registerDefaults(){
        let dictionary: [String:Any] = ["ChecklistIndex": -1, "FirstTime": true]
        
        UserDefaults.standard.register(defaults: dictionary)
    }
    
    // gets the current ID from userDefaults, add 1 to its value and write back, return the current value
    // the class keyword in front of this method make this method callable even we don't have a reference of an object dataModel
    class func nextChecklistItemID() -> Int {
        let userDefaults = UserDefaults.standard
        let itemID = userDefaults.integer(forKey: "ChecklistItemID")
        userDefaults.set(itemID + 1, forKey: "ChecklistItemID")
        userDefaults.synchronize()
        return itemID
    }
    
    
}
