//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by yuan cheng on 18/7/19.
//  Copyright © 2019 Yuan Cheng. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return nil
    }
}
