//
//  HudView.swift
//  MyLocations
//
//  Created by yuan cheng on 12/7/19.
//  Copyright © 2019 Yuan Cheng. All rights reserved.
//

import UIKit

class HudView: UIView {
    var text = ""
    
    // convenience constructor is always a class method, a method that works on the class as a whole and not on any particular instance
    // this method adds the new HudView object as a subview on top of the parent view object
    class func hud(inView view: UIView, animated: Bool) -> HudView {
        let hudView = HudView(frame: view.bounds)
        hudView.isOpaque = false
        
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false // prevent user from interacting with the HudView
        
        hudView.Show(animated: animated)
        return hudView
    }
    
    // this method draw the hudView in the center of its parent view with specific size and font
    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        // hudView should be placed at centre of its parent view
        let boxRect = CGRect(
            x: round((bounds.size.width - boxWidth) / 2),
            y: round((bounds.size.height - boxHeight) / 2),
            width: boxWidth,
            height: boxHeight)
        
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        
        // Draw checkmark
        // UIImage has a failable initilizer, which means it could fail to initialize an image, simply because there could be no image or image name is not matching
        if let image = UIImage(named: "Checkmark") {
            let imagePoint = CGPoint(x: center.x - round(image.size.width / 2),
                                     y: center.y - round(image.size.height / 2) - boxHeight / 8)
            image.draw(at: imagePoint)
        }
        
        // Draw the text
        let attribs = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.white]
        let textSize = text.size(withAttributes: attribs)
        
        let textPoint = CGPoint(
            x: center.x - round(textSize.width / 2),
            y: center.y - round(textSize.height / 2) + boxHeight / 4)
        text.draw(at: textPoint, withAttributes: attribs)
    }
    
    // MARK: - Public methods
    func Show(animated: Bool) {
        if animated {
            // 1 make the view fully transparent, and larger at first(1.3)
            alpha = 0
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            // 2 a time during followed by a closure, a closure is a piece of code that will not be executed right away
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                self.alpha = 1
                self.transform = CGAffineTransform.identity
            }, completion: nil)
            
            // hide the hudView animation
            afterDelay(0.3) {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                    self.alpha = 0
                    self.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
                }, completion: nil)
            }
        }
    }
    
    func hide() {
        superview?.isUserInteractionEnabled = true
        removeFromSuperview()
    }
}
