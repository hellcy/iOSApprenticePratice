//
//  Functions.swift
//  MyLocations
//
//  Created by yuan cheng on 12/7/19.
//  Copyright © 2019 Yuan Cheng. All rights reserved.
//

import Foundation

// this method is not declared in a class, so it is a free method, can be used anywhere in the project
// the second parameter in this method is a closure, it takes no argument and return nothing. the arrow -> in a method parameter section represents a closure.
func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}
