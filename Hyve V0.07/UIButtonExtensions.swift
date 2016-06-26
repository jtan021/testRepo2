//
//  UIButtonExtensions.swift
//  Hyve V0.07
//
//  Created by Jonathan Tan on 6/25/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import UIKit

extension UIButton {
    // Name: setBackgroundColor
    // Input: color: UIColor, forState: UIControlState
    // Output: ...
    // Function: Set's UIButton's background color for given state
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), color.CGColor)
        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, forState: forState)
    }
}