//
//  HomeViewController.swift
//  Hyve V0.07
//
//  Created by Jonathan Tan on 6/23/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import Bond
import UIKit
import MapKit
import THLabel

class HomeViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, UITableViewDelegate {
    /*
     *
     * CONSTANTS
     * section
     *
     */
    private let _mainSearchViewModel = MainSearchViewModel()
    private let _searchLocationAddressViewModel = SearchLocationAddressViewModel()
    private let _requestCategoryViewModel = RequestCategoryViewModel()
    var geoCoder: CLGeocoder?
    let locationManager = CLLocationManager()
    
    /*
     *
     * OUTLETS
     * section
     *
     */
    @IBOutlet weak var _searchTextField: SearchTextField!
    @IBOutlet weak var _searchHYVETextField: SearchTextField!
    @IBOutlet weak var _mapView: MKMapView!
    @IBOutlet weak var _switchSearchViewButton: UIButton!
    @IBOutlet weak var _resetMapButton: UIButton!
    @IBOutlet weak var _searchLocationAddressTextField: SearchTextField!
    @IBOutlet weak var _requestCategoryTableView: UITableView!
    @IBOutlet weak var _searchLocationAddressTableView: UITableView!
    @IBOutlet weak var _searchNavigationBarView: UIView!
    @IBOutlet weak var _searchNavigationBarViewOriginY: NSLayoutConstraint!
    @IBOutlet weak var _hyveNavigationBarLabel: THLabel!
    @IBOutlet weak var _hyveNavigationBarView: UIView!
    @IBOutlet weak var _generalNavigationBarView: UIView!
    @IBOutlet weak var _generalNavigationBarLabel: UILabel!
    
    /*
     *
     * ACTION FUNCTIONS
     * section
     *
     */
    @IBAction func ReturnFromSearchNavigationBarDidTouch(sender: AnyObject) {
        // Set _searchHYVETextField contents to _searchTextField
        self._searchTextField.text = self._searchHYVETextField.text
        
        // Move _searchNavigationBarViewOriginY out of View && hide _searchLocationAddressTableView
        self._searchLocationAddressTableView.hidden = true
        self._searchNavigationBarViewOriginY.constant -= 154
        
        // Unhide _hyveNavigationBarView
        self._hyveNavigationBarView.hidden = false
    }
    
    @IBAction func SwitchSearchViewDidTouch(sender: AnyObject) {
        self._switchSearchViewButton.setBackgroundColor(colorWithHexString("E5B924"), forState: UIControlState.Highlighted)
        if(self._switchSearchViewButton.currentImage == UIImage(named: "list2")) {
            self._switchSearchViewButton.setImage(UIImage(named: "map2"), forState: UIControlState.Normal)
        } else {
            self._switchSearchViewButton.setImage(UIImage(named: "list2"), forState: UIControlState.Normal)
        }
    }
    
    @IBAction func MapPostDidTouch(sender: AnyObject) {
        // Hide _hyveNavigationBarView & _searchNavigationBarView
        self._hyveNavigationBarView.hidden = true
        self._searchNavigationBarView.hidden = true
        
        // Unhide _generalNavigationBarView & _requestCategoryTableView
        self._generalNavigationBarView.hidden = false
        self._requestCategoryTableView.hidden = false

        // Replace _generalNavigationBarLabel text with "Select a Category"
        self._generalNavigationBarLabel.text = "Select a Category"
    }

    @IBAction func GeneralNavigationViewReturnDidTouch(sender: AnyObject) {
        if(self._generalNavigationBarLabel.text == "Select a Category") {
            // Hide _generalNavigationBarView & _requestCategoryTableView
            self._generalNavigationBarView.hidden = true
            self._requestCategoryTableView.hidden = true
            
            // Unhide _hyveNavigationBarView & _searchNavigationBarView
            self._hyveNavigationBarView.hidden = false
            self._searchNavigationBarView.hidden = false
        }
    }
    
    @IBAction func ResetMapDidTouch(sender: AnyObject) {
        self._resetMapButton.setBackgroundColor(colorWithHexString("E5B924"), forState: UIControlState.Highlighted)
        self._mapView.setCenterCoordinate(self._mapView.userLocation.coordinate, animated: true)
    }
    
    /*
     *
     * OVERRIDED FUNCTIONS
     * section
     *
     */
    override func viewDidLoad() {
        // Set up _hyveNavigationBarView & _searchNavigationBarView
        self._searchNavigationBarViewOriginY.constant -= 154
        self._searchTextField.addTarget(self, action: #selector(HomeViewController.SearchTextFieldShouldBeginEditing(_:)), forControlEvents: .EditingDidBegin)
        self._searchLocationAddressTextField.addTarget(self, action: #selector(HomeViewController.SearchTextFieldShoudEndEditing(_:)), forControlEvents: .EditingDidEnd)
        
        self.setupHyveTHLabel(_hyveNavigationBarLabel)
        
        // Bind ViewController to SearchLocationViewModel
        _searchLocationAddressTableView.delegate = self
        _searchLocationAddressViewModel._mapView = _mapView
        self.BindSearchLocationAddressViewModel()
        
        // Bind ViewController to RequestCategoryViewModel
        self.BindRequestCategoryViewModel()

        // Zoom Map View into Current Location
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestLocation()
        geoCoder = CLGeocoder()
        self._mapView!.delegate = self
        
        // Detect if user panned through mapView
        let panRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "didDragMap:")
        panRecognizer.delegate = self
        self._mapView.addGestureRecognizer(panRecognizer)
        
        ///
        ///
        ///
        self._requestCategoryTableView.hidden = true
    }
    
    /*
     *
     * OTHER FUNCTIONS
     * section
     *
     */
    // Name: BindMainSearchViewModel()
    // Inputs: ...
    // Outputs: ...
    // Function:
    func BindMainSearchViewModel() {

    }
    
    // Name: BindSearchLocationAddressViewModel()
    // Inputs: ...
    // Outputs: ...
    // Function: Binds _searchLocationAddressTextField and _searchLocationAddressTableView to the _searchLocationAddressViewModel to obtain data
    func BindSearchLocationAddressViewModel() {
        _searchLocationAddressViewModel._searchLocationAddress.bidirectionalBindTo(_searchLocationAddressTextField.bnd_text)
        
        _searchLocationAddressViewModel._searchLocationAddressResults.lift().bindTo(_searchLocationAddressTableView) { indexPath, dataSource, tableView in
            let cell = tableView.dequeueReusableCellWithIdentifier("_searchLocationAddressCell", forIndexPath: indexPath)
            let locationTableItem = dataSource[indexPath.section][indexPath.row].placemark
            cell.textLabel!.text = locationTableItem.name
            cell.detailTextLabel!.text = self.parseAddress(locationTableItem)
            //print(locationTableItem.name)
            return cell
        }

        _searchLocationAddressViewModel._searchDidBegin
            .map { $0 ? false : true }
            .bindTo(_searchLocationAddressTableView.bnd_hidden)
    }
    
    // Name: BindRequestCategoryViewModel()
    // Inputs: ...
    // Outputs: ...
    // Function: Binds _requestCategoryTableView to the _requestCategoryViewModel to obtain data
    func BindRequestCategoryViewModel() {
        _requestCategoryViewModel._requestCategoryTableData.lift().bindTo(_requestCategoryTableView) { indexPath, dataSource, tableView in
            let cell = tableView.dequeueReusableCellWithIdentifier("_requestCategoryCell", forIndexPath: indexPath) as! RequestCategoryCell
            cell._requestTitle.text = dataSource[indexPath.section][indexPath.row].Title
            cell._requestImage.image = dataSource[indexPath.section][indexPath.row].Image
            return cell
        }
    }
    
    // Name: SearchTextFieldShouldBeginEditing
    // Inputs: ...
    // Outputs: ...
    // Function: When _searchTextField is tapped, hide it and set _searchHYVETextField to first responder
    func SearchTextFieldShouldBeginEditing(textField: SearchTextField) -> Bool {
        dispatch_async(dispatch_get_main_queue()) { 
            if(textField == self._searchTextField) {
                self._hyveNavigationBarView.hidden = true
                self._searchNavigationBarViewOriginY.constant += 154
                self._searchHYVETextField.becomeFirstResponder()
            }
        }
        return true
    }
    
    // Name: SearchTextFieldShoudEndEditing
    // Inputs: ...
    // Outputs: ...
    // Function: When _searchTextField is tapped, hide it and set _searchHYVETextField to first responder
    func SearchTextFieldShoudEndEditing(textField: SearchTextField) -> Bool {
        dispatch_async(dispatch_get_main_queue()) { // 2
            if(textField == self._searchLocationAddressTextField) {
                self._searchLocationAddressTableView.hidden = true
            }
        }
        return true
    }
    
    // Name: locationManager
    // Inputs: ...
    // Outputs: ...
    // Function: Zooms into map
    func locationManager(manager: CLLocationManager,didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.first!
        self._mapView!.centerCoordinate = location.coordinate
        let reg = MKCoordinateRegionMakeWithDistance(location.coordinate, 1500, 1500)
        self._mapView!.setRegion(reg, animated: true)
        geoCode(location)
    }
    
    // Name: locationManager
    // Inputs: ...
    // Outputs: ...
    // Function: Obtains coordinates of current location and sends it to be geoCode
    func mapView(mapView: MKMapView, regionDidChangeAnimated animate: Bool) {
        let location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        geoCode(location)
    }
    
    // Name: geoCode
    // Inputs: ...
    // Outputs: ...
    // Function: reverseGeocodes the current location and updates the _searchLocationAddressTextField.text address
    func geoCode(location : CLLocation!) {
        geoCoder!.cancelGeocode()
        geoCoder!.reverseGeocodeLocation(location, completionHandler: { (data, error) -> Void in
            guard let placeMarks = data as [CLPlacemark]! else {
                return
            }
            let loc: CLPlacemark = placeMarks[0]
            let addressDict : [NSString:NSObject] = loc.addressDictionary as! [NSString:NSObject]
            let addrList = addressDict["FormattedAddressLines"] as! [String]
            let address = addrList.joinWithSeparator(", ")
            print(address)
            self._searchLocationAddressTextField.text = address
        })
    }
    
    // Name: tableView -- didSelectRowAtIndexPath
    // Inputs: ...
    // Outputs: ...
    // Function: Sets up what happens when a cell is selected
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // If tableView == searchTable -> setup selection for map
        if(tableView == _searchLocationAddressTableView) {
            let selectedItem = _searchLocationAddressViewModel._searchLocationAddressResults[indexPath.row].placemark
            self.newLocationZoomIn(selectedItem, mapView: self._mapView)
            self._searchLocationAddressTableView.hidden = true
            self._searchLocationAddressTextField.resignFirstResponder()
            // Else setup selection for job request categories
        } else {
//            print("selected")
//            tableView.deselectRowAtIndexPath(indexPath, animated: true)
//            self.requestView.hidden = false
//            
//            // Set and show navigation bar title
//            self.requestNavBarLabel.text = "Request a Job"
//            self.requestNavBarView.hidden = false
//            // Make sure requestPostButton is not hidden
//            self.requestPostButton.hidden = false
//            
//            // Hide jobMenuView
//            self.jobMenuView.hidden = true
//            
//            // Set jobMenuView defaults
//            self.categoryTF.text = self.jobMenuArray[indexPath.row].menuTitle
//            self.offerTF.placeholder = "$0.00"
//            self.lifetimeTF.text = "0 Days, 0 Hours, 0 Minutes"
//            self.addressTV.text = self.searchViewLocationSearchTF.text
        }
    }


}
