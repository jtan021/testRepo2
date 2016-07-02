//
//  Constants.swift
//  Hyve V0.07
//
//  Created by Jonathan Tan on 6/23/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import UIKit
import Parse

struct Constants {

    // Parse
    static let _currentUser = PFUser.currentUser()
    
    // THLabel
    static let kShadowColor1 = UIColor.blackColor
    static let kShadowColor2 = UIColor(white: 0.0, alpha: 0.75)
    static let kShadowOffset = CGSizeMake(0.0, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad ? 4.0 : 2.0)
    static let kShadowBlur:CGFloat = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad ? 10.0 : 5.0)
    static let kInnerShadowOffset = CGSizeMake(0.0, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad ? 2.0 : 1.0)
    static let kInnerShadowBlur:CGFloat = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad ? 4.0 : 2.0)
    static let kStrokeColor = UIColor.blackColor()
    static let kStrokeSize:CGFloat = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad ? 4.0 : 2.0)
    static let kGradientStartColor = UIColor(colorLiteralRed: 229/255, green: 185/255, blue: 36/255, alpha: 1.0)
    static let kGradientEndColor = UIColor(colorLiteralRed: 255/255, green: 138/255, blue: 0/255, alpha: 1.0)
    
    // Character sets
    static let alphaNumericCharacterSet:NSCharacterSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789")
    static let alphaNumericAndSymbolsCharacterSet:NSCharacterSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789!@#$%^&*?")
    
    // RequestCategory images
    static let FoodDeliveryImage = UIImage(named:"food")
    static let DrinkDeliveryImage = UIImage(named:"drink")
    static let GroceryDeliveryImage = UIImage(named: "grocery")
    static let WaitInLineImage = UIImage(named: "wait")
    static let LaundryImage = UIImage(named: "laundry")
    static let SpecialRequestImage = UIImage(named:"specialRequest")
    
}

