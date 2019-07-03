//
//  ChecklistItem.swift
//  CheckLists
//
//  Created by yuan cheng on 2/7/19.
//  Copyright © 2019 Yuan Cheng. All rights reserved.
//

import Foundation

class ChecklistItem: NSObject, Codable {
    var text = ""
    var checked = false
    
    func toggleChecked() {
        checked = !checked
    }
}
