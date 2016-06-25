//
//  ViewControllerExtensions.swift
//  Hyve V0.07
//
//  Created by Jonathan Tan on 6/23/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import UIKit
import MapKit

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
    
    // Name: newLocationZoomIn
    // Input: placemark: MKPlacemark, mapView: MKMapView
    // Output: ...
    // Function: Zooms into coordinates provided by the placemark on the provided mapview
    func newLocationZoomIn(placemark:MKPlacemark, mapView:MKMapView) {
        mapView.centerCoordinate = placemark.coordinate
        let reg = MKCoordinateRegionMakeWithDistance(placemark.coordinate, 1500, 1500)
        mapView.setRegion(reg, animated: true)
    }

}
