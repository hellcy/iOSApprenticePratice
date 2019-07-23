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
    
    lazy var dimmingView = GradientView(frame: CGRect.zero)
    
    // give DetailView a gradient background
    //  method is invoked when the new view controller is about to be shown on the screen. Here you create the GradientView object, make it as big as the containerView, and insert it behind everything else in this “container view”
    override func presentationTransitionWillBegin() {
        dimmingView.frame = containerView!.bounds
        containerView!.insertSubview(dimmingView, at: 0)
        // Animate background gradient view
        dimmingView.alpha = 0
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 1
            }, completion: nil)
        }
    }
    
    // dismiss the background gradient in a fade out animation
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 0
            }, completion: nil)
        }
    }
    
    // don't remove the SearchView when DetailView is popup
    override var shouldRemovePresentersView: Bool {
        return false
    }
}
