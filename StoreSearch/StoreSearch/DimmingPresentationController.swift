//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by yuan cheng on 22/7/19.
//  Copyright © 2019 yuancheng. All rights reserved.
//

import UIKit

// A presentation controller is an object that “controls” the presentation of something
class DimmingPresentationController: UIPresentationController {
    override var shouldRemovePresentersView: Bool {
        return false
    }
}
