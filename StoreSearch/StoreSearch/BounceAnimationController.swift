//
//  BounceAnimationController.swift
//  StoreSearch
//
//  Created by yuan cheng on 23/7/19.
//  Copyright © 2019 yuancheng. All rights reserved.
//

import UIKit
class BounceAnimationController: NSObject,
UIViewControllerAnimatedTransitioning {
    
    // This determines how long the animation is
    func transitionDuration(using transitionContext:
        UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    // This performs the actual animation
    func animateTransition(using transitionContext:
        UIViewControllerContextTransitioning) {
        
        if let toViewController = transitionContext.viewController(
            forKey: UITransitionContextViewControllerKey.to),
            let toView = transitionContext.view(
                forKey: UITransitionContextViewKey.to) {
            let containerView = transitionContext.containerView
            toView.frame = transitionContext.finalFrame(for:
                toViewController)
            containerView.addSubview(toView)
            toView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            
            UIView.animateKeyframes(withDuration: transitionDuration(
                using: transitionContext), delay: 0, options:
                .calculationModeCubic, animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.334, animations: {
                                        toView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    })
                    UIView.addKeyframe(withRelativeStartTime: 0.334, relativeDuration: 0.333, animations: {
                                        toView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                    })
                    UIView.addKeyframe(withRelativeStartTime: 0.666, relativeDuration: 0.333, animations: {
                                        toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    })
            }, completion: { finished in
                transitionContext.completeTransition(finished)
            })
        }
    }
}
