//
//  NoPasteTextField.swift
//  Hyve V0.07
//
//  Created by Jonathan Tan on 6/26/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import UIKit

class NoPasteTextField: UITextField {
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == #selector(NSObject.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
