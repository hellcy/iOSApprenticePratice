//
//  GradientView.swift
//  StoreSearch
//
//  Created by yuan cheng on 23/7/19.
//  Copyright © 2019 yuancheng. All rights reserved.
//

import UIKit
class GradientView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        // pin the GradientView to the edges of the window so that it will always stretch along with the window
        autoresizingMask = [.flexibleWidth , .flexibleHeight]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
        // pin the GradientView to the edges of the window so that it will always stretch along with the window
        autoresizingMask = [.flexibleWidth , .flexibleHeight]
    }
    
    override func draw(_ rect: CGRect) {
        // 1
        let components: [CGFloat] = [ 0, 0, 0, 0.3, 0, 0, 0, 0.7 ]
        let locations: [CGFloat] = [ 0, 1 ]
        // 2
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorSpace: colorSpace,
                                  colorComponents: components,
                                  locations: locations, count: 2)
        // 3
        let x = bounds.midX
        let y = bounds.midY
        let centerPoint = CGPoint(x: x, y : y)
        let radius = max(x, y)
        // 4
        let context = UIGraphicsGetCurrentContext()
        context?.drawRadialGradient(gradient!,
                                    startCenter: centerPoint, startRadius: 0,
                                    endCenter: centerPoint, endRadius: radius,
                                    options: .drawsAfterEndLocation)
    }
}
