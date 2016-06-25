//
//  SearchTextField.swift
//  Hyve V0.07
//
//  Created by Jonathan Tan on 6/24/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import UIKit

class SearchTextField: UITextField {
        
    let inset: CGFloat = 37
    
    // placeholder position
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , inset , 0)
    }
    
    // text position
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , inset , 0)
    }
    
    override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, inset, 0)
    }
    
    // Clear button position
    override func clearButtonRectForBounds(bounds: CGRect) -> CGRect {
        let rect: CGRect = super.clearButtonRectForBounds(bounds)
        return CGRectOffset(rect, -5, 0)
    }
    

}
