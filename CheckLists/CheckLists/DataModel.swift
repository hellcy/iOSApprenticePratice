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
    
    init(){
        loadChecklists()
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
            } catch {
                print("Error decoding item array!")
            }
        }
    }
}
