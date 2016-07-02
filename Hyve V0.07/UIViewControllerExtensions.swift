//
//  ViewControllerExtensions.swift
//  Hyve V0.07
//
//  Created by Jonathan Tan on 6/23/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import UIKit
import MapKit
import THLabel

extension UIViewController {
    // Name: displayAlert
    // Inputs: title:String, message:String
    // Output: UIAlertAction
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle:  UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // Name: DismissKeyboard()
    // Inputs: ...
    // Outputs: ...
    // Function: Ends editing
    func DismissKeyboard() {
        view.endEditing(true)
    }
    
    // Name: textFieldShouldReturn()
    // Inputs: ...
    // Outputs: ...
    // Function: If "Done" button is pressed on keyboard, dismiss the keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Name: parseAddress
    // Input: ...
    // Output: ...
    // Function: Obtain's string address from a MKPlacemark
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    // Name: locationManager
    // Inputs: ...
    // Outputs: ...
    // Function: Managers errors with locationManager
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: " + error.localizedDescription)
    }
    
    // Name: newLocationZoomIn
    // Input: placemark: MKPlacemark, mapView: MKMapView
    // Output: ...
    // Function: Zooms into coordinates provided by the placemark on the provided mapview
    func newLocationZoomIn(placemark:MKPlacemark, mapView:MKMapView) {
        mapView.centerCoordinate = placemark.coordinate
        let reg = MKCoordinateRegionMakeWithDistance(placemark.coordinate, 1500, 1500)
        mapView.setRegion(reg, animated: true)
    }
    
    // Name: setupHYVETHLabel
    // Input: hyveLabel: THLabel
    // Output: ...
    // Function: Sets up passed in THLabel with preset Title constants
    func setupHyveTHLabel(hyveLabel: THLabel) {
        hyveLabel.shadowColor = Constants.kShadowColor2
        hyveLabel.shadowOffset = Constants.kShadowOffset
        hyveLabel.shadowBlur = Constants.kShadowBlur
        hyveLabel.innerShadowColor = Constants.kShadowColor2
        hyveLabel.innerShadowOffset = Constants.kInnerShadowOffset
        hyveLabel.innerShadowBlur = Constants.kInnerShadowBlur
        hyveLabel.strokeColor = Constants.kStrokeColor
        hyveLabel.strokeSize = Constants.kStrokeSize
        hyveLabel.gradientStartColor = Constants.kGradientStartColor
        hyveLabel.gradientEndColor = Constants.kGradientEndColor
    }
    
    // Name: colorWithHexString
    // Input: hex: String
    // Output: UIColor
    // Function: Transforms hex string to UIColor equivalent
    func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }
        
        if (cString.characters.count != 6) {
            return UIColor.grayColor()
        }
        
        let rString = (cString as NSString).substringToIndex(2)
        let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
    // Name: TextViewLikeTextField
    // Input: textView: UITextView
    // Output: ...
    // Function: Transforms textView's layers to appear similar to a TextField
    func TextViewLikeTextField(textView: UITextView) {
        //textView.layer.borderColor = UIColor(red: 215.0 / 255.0, green: 215.0 / 255.0, blue: 215.0 / 255.0, alpha: 1).CGColor
        textView.layer.borderColor = UIColor.grayColor().CGColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.layer.masksToBounds = true
    }
    
    // Name: textFieldDidChange
    // Inputs: None
    // Outputs: None
    // Function: Adds a '$' to the front of the jobOfferTextField if user inputs text
    func changeToMoneyString(textField: UITextField) {
        if !(textField.text!.hasPrefix("$")) {
            textField.text = "$\(textField.text!)"
        } else {
            if (textField.text!.hasSuffix("$")) {
                textField.text = ""
            }
        }
    }
    
    // Name: animateTextField
    // Inputs: ...
    // Outputs: ...
    // Function: Custom function for pushing textFields up when editting
    func animateTextField(textField: UITextField, up: Bool) {
        let movementDistance:CGFloat = -150
        let movementDuration: Double = 0.3
        
        var movement:CGFloat = 0
        if up {
            movement = movementDistance
        }
        else {
            movement = -movementDistance
        }
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        UIView.commitAnimations()
    }
    
    func setInputTextFieldLayers(textField: UITextField) {
        textField.borderStyle = .Line
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.grayColor().CGColor
        textField.layer.cornerRadius = 5
    }
    
    func setSecureTextEntry(secureTextEntry: Bool, textField: UITextField) {
        UIView.performWithoutAnimation({() -> Void in
            var resumeResponder: Bool = false
            
            if (textField.isFirstResponder()) {
                resumeResponder = true
                textField.resignFirstResponder()
            }
            textField.secureTextEntry = secureTextEntry
            if resumeResponder {
                textField.becomeFirstResponder()
            }
        })
    }
    
    // Name: getUTCFromLocalDate
    // Inputs: strDate: String
    // Outputs: String
    // Function: Take an input string which is the local date and convert it to UTC time
    func getUTCfromLocalDate(strDate: String) -> String {
        let dateFormat: NSDateFormatter = NSDateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormat.timeZone = NSTimeZone.systemTimeZone()
        let aDate: NSDate = dateFormat.dateFromString(strDate)!
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormat.timeZone = NSTimeZone(name: "UTC")
        return dateFormat.stringFromDate(aDate)
    }
    
    // Name: getDate
    // Inputs: None
    // Outputs: String
    // Function: Gets current date and output in format yyyy-MM-dd HH:mm:ss
    func getDate() -> String {
        let currentDate = NSDate()
        let dateFormat: NSDateFormatter = NSDateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let convertedDate = dateFormat.stringFromDate(currentDate)
        return convertedDate
    }
    
    // Name: getLocalFromUTCDate
    // Inputs: strDate: String
    // Outputs: NSDate
    // Function: Take an input string which is in UTC time and convert it to local time as an NSDate object
    func getLocalFromUTCDate(strDate: String) -> NSDate {
        let dateFormat: NSDateFormatter = NSDateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormat.timeZone = NSTimeZone(name: "UTC")
        let aDate: NSDate = dateFormat.dateFromString(strDate)!
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormat.timeZone = NSTimeZone.systemTimeZone()
        return aDate
    }
    
}
