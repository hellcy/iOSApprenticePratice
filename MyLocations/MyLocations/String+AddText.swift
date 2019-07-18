//
//  String+AddText.swift
//  MyLocations
//
//  Created by yuan cheng on 18/7/19.
//  Copyright © 2019 Yuan Cheng. All rights reserved.
//

extension String {
    // when a method changes the value of a struct, it must be marked as mutating, string is a struct
    mutating func add(text: String?, separatedBy separator: String = "") {
        if let text = text {
            if !isEmpty {
                self += separator
            }
            self += text
        }
    }
}
