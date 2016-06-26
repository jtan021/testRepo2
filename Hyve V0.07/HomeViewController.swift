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
import Parse

class HomeViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, UITextFieldDelegate {
    /*
     *
     * CONSTANTS
     * section
     *
     */
    private let _mainSearchViewModel = MainSearchViewModel()
    private let _searchLocationAddressViewModel = SearchLocationAddressViewModel()
    private let _requestCategoryViewModel = RequestCategoryViewModel()
    var _geoCoder: CLGeocoder?
    let _locationManager = CLLocationManager()
    var _categoryPickerView = UIPickerView()
    var _datePickerView = UIPickerView()
    var _selectedDay:Int = 0
    var _selectedHour: Int = 0
    var _selectedMinute: Int = 0
    var _hourArray = [AnyObject]()
    var _minuteArray = [AnyObject]()
    var _dayArray = [AnyObject]()
    var _screenWidth: CGFloat?
    var _screenRect:CGRect = UIScreen.mainScreen().bounds
    var _pickerStringVal: String = String()
    var _currentUser = PFUser.currentUser()
    var PLACEHOLDER_TEXT = "Let others know more specifics about what you need done here."
    var SELECTACATEGORY_TEXT = "Select a Category"
    var JOBREQUEST_TEXT = "Job Request"
    var POSTBUTTON_TEXT = " Post"
    var VERIFYPOSTBUTTON_TEXT = " Verify"
    
    /*
     *
     * OUTLETS
     * section
     *
     */
    // Search & Category outlets
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
    // HYVE navigation bar outlets
    @IBOutlet weak var _hyveNavigationBarLabel: THLabel!
    @IBOutlet weak var _hyveNavigationBarView: UIView!
    // General navigation bar outlets
    @IBOutlet weak var _generalNavigationBarView: UIView!
    @IBOutlet weak var _generalNavigationBarLabel: UILabel!
    // Job request outlets
    @IBOutlet weak var _jobRequestView: UIView!
    @IBOutlet weak var _jobAddressTextView: UITextView!
    @IBOutlet weak var _jobDescriptionTextView: UITextView!
    @IBOutlet weak var _jobTitleTextField: UITextField!
    @IBOutlet weak var _jobCategoryTextField: UITextField!
    @IBOutlet weak var _jobLifetimeTextField: UITextField!
    @IBOutlet weak var _jobOfferForCompletionTextField: UITextField!
    @IBOutlet weak var _jobKeywordsTextField: UITextField!
    @IBOutlet weak var _postJobButton: UIButton!
    
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
        self._generalNavigationBarLabel.text = SELECTACATEGORY_TEXT
    }

    @IBAction func GeneralNavigationViewReturnDidTouch(sender: AnyObject) {
        if(self._generalNavigationBarLabel.text == SELECTACATEGORY_TEXT) {
            // Hide _generalNavigationBarView & _requestCategoryTableView
            self._generalNavigationBarView.hidden = true
            self._requestCategoryTableView.hidden = true
            
            // Unhide _hyveNavigationBarView & _searchNavigationBarView
            self._hyveNavigationBarView.hidden = false
            self._searchNavigationBarView.hidden = false
        } else if (self._generalNavigationBarLabel.text == JOBREQUEST_TEXT) {
            // Set _generalNavigationBarLabel to "Select a Category"
            self._generalNavigationBarLabel.text = SELECTACATEGORY_TEXT
            
            // Unhide _requestCategoryTableView
            self._requestCategoryTableView.hidden = false
            
            // Hide _jobRequestView
            self._jobRequestView.hidden = true
            
        }
    }
    
    @IBAction func ResetMapDidTouch(sender: AnyObject) {
        self._resetMapButton.setBackgroundColor(colorWithHexString("E5B924"), forState: UIControlState.Highlighted)
        self._mapView.setCenterCoordinate(self._mapView.userLocation.coordinate, animated: true)
    }
    
    @IBAction func PostJobDidTouch(sender: AnyObject) {
        // 1) Check that all required fields (title & description) are filled in
        if(self._jobTitleTextField.text == "" || self._jobDescriptionTextView.text == "") {
            self.displayAlert("Missing field(s)", message: "Help others understand what you need done by providing a nice title and description.")
            return
        }
        // 2) Check that lifetime > 0
        if(self._selectedDay + self._selectedHour + self._selectedMinute == 0) {
            self.displayAlert("Invalid Request Lifetime", message: "Please increase the lifetime of your request so more people have the chance to see it.")
            return
        }
        // 3) If button == "Post", switch to "Verify"
        if (self._postJobButton.titleLabel?.text == POSTBUTTON_TEXT) {
            self._postJobButton.setTitle(self.VERIFYPOSTBUTTON_TEXT, forState: .Normal)
            self._postJobButton.setImage(UIImage(named: "verifyPost"), forState: UIControlState.Normal)
        }
        // 4) If button == "Verify", do Post
        else if (self._postJobButton.titleLabel?.text == VERIFYPOSTBUTTON_TEXT) {
            // do post
            // 1) Verify user
            if _currentUser != nil {
                // 2) Save the request in "JobRequest"
                let username = _currentUser!.username!
                let firstName = _currentUser!["firstName"] as! String
                let lastName = _currentUser!["lastName"] as! String
                let fullName = firstName + " " + lastName
                let totalTimeInMinutes = (_selectedDay*24*60 + _selectedHour*60 + _selectedMinute)
                let currentDate = self.getUTCfromLocalDate(self.getDate())
                
                let newRequest = PFObject(className: "JobRequest")
                print(username)
                newRequest["username"] = _currentUser!.username!
                newRequest["fullName"] = fullName
                newRequest["jobTitle"] = self._jobTitleTextField.text
                newRequest["jobAddress"] = self._jobAddressTextView.text
                newRequest["jobCategory"] = self._jobCategoryTextField.text
                newRequest["jobDescription"] = self._jobDescriptionTextView.text
                newRequest["jobLifetime"] = totalTimeInMinutes
                newRequest["jobOfferForCompletion"] = self._jobOfferForCompletionTextField.text
                newRequest["jobKeywords"] = self._jobKeywordsTextField.text
                newRequest["jobStatus"] = "Active"
                newRequest["jobCompleted"] = false
                newRequest["jobLastUpdated"] = currentDate
                newRequest["jobEmployee"] = ""
                
                newRequest.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                    if (success) {
                        print(currentDate)
                        print(self.getDate())
                        print("Request successfully saved to Parse db.\n")
                        self.displayAlert("Request successfuly saved", message: "Your request \(self._jobTitleTextField.text!) has been added to the Hyve.")
                        
                        // Hide _jobRequestView and the _generalNavigationBarView
                        self._jobRequestView.hidden = true
                        self._generalNavigationBarView.hidden = true
                        
                        // Show the _hyveNavigationBarView
                        self._hyveNavigationBarView.hidden = false
                        
                    } else {
                        self.displayAlert("Request could not be saved", message: "Please try again later.")
                        print("Error saving request: \(error!) \(error!.description)")
                    }
                }
            }
        }
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
        self._searchLocationAddressTableView.delegate = self
        self._searchLocationAddressViewModel._mapView = _mapView
        self.BindSearchLocationAddressViewModel()
        
        // Bind ViewController to RequestCategoryViewModel & hide _requestCategoryTableView
        self.BindRequestCategoryViewModel()
        self._requestCategoryTableView.delegate = self
        self._requestCategoryTableView.hidden = true

        // Zoom Map View into Current Location
        self._locationManager.delegate = self
        self._locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self._locationManager.requestWhenInUseAuthorization()
        self._locationManager.requestLocation()
        _geoCoder = CLGeocoder()
        self._mapView!.delegate = self
        
        // Detect if user panned through mapView
        let panRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "didDragMap:")
        panRecognizer.delegate = self
        self._mapView.addGestureRecognizer(panRecognizer)
        
        // Hide keyboard when users tap outside editable area
        let tapper = UITapGestureRecognizer(target: view, action:#selector(UIView.endEditing))
        tapper.cancelsTouchesInView = false
        view.addGestureRecognizer(tapper)
        
        // Setup job request view
        // 1) Hide _jobRequestView
        self._jobRequestView.hidden = true
        // 2) Set _screenWidth var
        self._screenWidth = self._screenRect.size.width
        // 3) Setup keyboard for _jobCategoryTextField to _categoryPickerView
        self._categoryPickerView.backgroundColor = .whiteColor()
        self._categoryPickerView.showsSelectionIndicator = true
        self._categoryPickerView.dataSource = self
        self._categoryPickerView.delegate = self
        self._jobCategoryTextField.inputView = _categoryPickerView
        // 4) Setup keyboard for _jobLifetimeTextfield to _datePickerView
        self._datePickerView.backgroundColor = .whiteColor()
        self._datePickerView.showsSelectionIndicator = true
        self._datePickerView.dataSource = self
        self._datePickerView.delegate = self
        
        // Populate hour,day,minutes array
        for i in 0...59 {
            _pickerStringVal = "\(i)"
            //Creates day array with 0-13 days
            if (i < 14) {
                _dayArray.append(_pickerStringVal)
                //Creates hour array with 0-23 hours
            }
            if (i < 24) {
                _hourArray.append(_pickerStringVal)
                //Sets minute array with 0-59 minutes
            }
            _minuteArray.append(_pickerStringVal)
        }
        
        self._jobLifetimeTextField.inputView = _datePickerView
        // 5) Setup keyboard for _jobOfferForCompletionTextfield  to DecimalPad
        self._jobOfferForCompletionTextField.keyboardType = UIKeyboardType.DecimalPad
        self._jobOfferForCompletionTextField.addTarget(self, action: "changeToMoneyString:", forControlEvents: UIControlEvents.EditingChanged)
        // 6) Create "Done" button for _jobOfferForCompletionTextField, _jobLifetimeTextField, and _jobCategoryTextField keyboards and set returnkey for other job input textfields to done
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.setBackgroundImage(UIImage(named: "Hyve_BG2"), forToolbarPosition: .Any, barMetrics: .Default)
        toolBar.translucent = false
        toolBar.tintColor = colorWithHexString("E5B924")
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Bordered, target: self, action: #selector(DismissKeyboard))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        self._jobCategoryTextField.inputAccessoryView = toolBar
        self._jobOfferForCompletionTextField.inputAccessoryView = toolBar
        self._jobLifetimeTextField.inputAccessoryView = toolBar
        self._jobTitleTextField.returnKeyType = UIReturnKeyType.Done
        self._jobKeywordsTextField.returnKeyType = UIReturnKeyType.Done
        // 7) Set _jobAddressTextView & _jobDescriptionTextView to look like TextField and add placeholder text to description textview
        self.TextViewLikeTextField(self._jobAddressTextView)
        self.TextViewLikeTextField(self._jobDescriptionTextView)
        self._jobDescriptionTextView.delegate = self
        self._jobDescriptionTextView.text = PLACEHOLDER_TEXT
        self._jobDescriptionTextView.textColor = UIColor.lightGrayColor()
        // 8) Set job input textfield delegates
        self._jobTitleTextField.delegate = self
        self._jobCategoryTextField.delegate = self
        self._jobOfferForCompletionTextField.delegate = self
        self._jobKeywordsTextField.delegate = self
        self._jobLifetimeTextField.delegate = self
        // 9) Setup input textfield layers
        self.setInputTextFieldLayers(_jobTitleTextField)
        self.setInputTextFieldLayers(_jobCategoryTextField)
        self.setInputTextFieldLayers(_jobOfferForCompletionTextField)
        self.setInputTextFieldLayers(_jobKeywordsTextField)
        self.setInputTextFieldLayers(_jobLifetimeTextField)
        // 10) Add observers to input textfields to check for textchange and change _postButton accordingly
        self._jobTitleTextField.addTarget(self, action: #selector(HomeViewController.jobInputTextFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        self._jobCategoryTextField.addTarget(self, action: #selector(HomeViewController.jobInputPickerViewsDidChange(_:)), forControlEvents: UIControlEvents.EditingDidEnd)
        self._jobLifetimeTextField.addTarget(self, action: #selector(HomeViewController.jobInputPickerViewsDidChange(_:)), forControlEvents: UIControlEvents.EditingDidEnd)
        self._jobOfferForCompletionTextField.addTarget(self, action: #selector(HomeViewController.jobInputTextFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        self._jobKeywordsTextField.addTarget(self, action: #selector(HomeViewController.jobInputTextFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
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
    func BindMainSearchViewModel(textField: UITextField) {
        print("BOOM")
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
        self._geoCoder!.cancelGeocode()
        self._geoCoder!.reverseGeocodeLocation(location, completionHandler: { (data, error) -> Void in
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
            print("selected")
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            // Set _generalNavigationBarLabel to "Job Request"
            self._generalNavigationBarLabel.text = JOBREQUEST_TEXT
            
            // Set _jobMenuView defaults
            self._jobCategoryTextField.text = self._requestCategoryViewModel._requestCategoryTableData[indexPath.row].Title
            
            if(self._jobOfferForCompletionTextField.text != "$0.00") {
                self._jobOfferForCompletionTextField.text = "$0.00"
            }
            if(self._jobLifetimeTextField.text != "0 Days, 0 Hours, 0 Minutes") {
                self._jobLifetimeTextField.text = "0 Days, 0 Hours, 0 Minutes"
            }
            if(self._jobAddressTextView.text != self._searchLocationAddressTextField.text) {
                self._jobAddressTextView.text = self._searchLocationAddressTextField.text
            }
            if(self._postJobButton.titleLabel?.text != POSTBUTTON_TEXT) {
                self._postJobButton.setTitle(self.POSTBUTTON_TEXT, forState: .Normal)
                self._postJobButton.setImage(UIImage(named: "post"), forState: UIControlState.Normal)
            }
            
            
            // Hide _requestCategoryTableView and show _jobRequestView
            self._requestCategoryTableView.hidden = true
            self._jobRequestView.hidden = false
        }
    }
    
    // Name: numberOfComponentsInPickerView
    // Inputs: ...
    // Outputs: ...
    // Function: Sets the number of components in the pickerview
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        if(pickerView == _datePickerView) {
            return 6
        } else if (pickerView == _categoryPickerView) {
            return 1
        }
        return 1
    }
    
    // Name: pickerView
    // Inputs: None
    // Outputs: None
    // Function: Sets variables: day, hour, minute, and updates the jobLifeTextField with user selection
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView == self._datePickerView) {
            switch component {
            case 0:
                self._selectedDay = row
            case 2:
                self._selectedHour = row
            case 4:
                self._selectedMinute = row
            default:
                print("No component with number \(component)")
            }
            if (_selectedDay > 1) {
                self._jobLifetimeTextField.text = "\(_selectedDay) Days"
            } else {
                self._jobLifetimeTextField.text = "\(_selectedDay) Day"
            }
            
            if (_selectedHour > 1) {
                self._jobLifetimeTextField.text = "\(self._jobLifetimeTextField.text!), \(_selectedHour) Hours"
            } else {
                self._jobLifetimeTextField.text = "\(self._jobLifetimeTextField.text!), \(_selectedHour) Hour"
            }
            
            if (_selectedMinute > 1) {
                self._jobLifetimeTextField.text = "\(self._jobLifetimeTextField.text!), \(_selectedMinute) Minutes."
            } else {
                self._jobLifetimeTextField.text = "\(self._jobLifetimeTextField.text!), \(_selectedMinute) Minute."
            }
        } else if(pickerView == self._categoryPickerView) {
            self._jobCategoryTextField.text = self._requestCategoryViewModel._requestCategoryTableData[row].Title
        }
    }
    
    // Name: pickerView -- numberOfRowsInComponent
    // Inputs: None
    // Outputs: None
    // Function: Sets the number of choices in each component of the pickerView
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView == self._datePickerView) {
            if component == 0 {
                return _dayArray.count
            } else if component == 2 {
                return _hourArray.count
            } else if component == 4 {
                return _minuteArray.count
            } else {
                return 1
            }
        } else if (pickerView == self._categoryPickerView) {
            return self._requestCategoryViewModel._requestCategoryTableData.count
        } else {
            return 1
        }
    }
    
    // Name: pickerView -- titleForRow
    // Inputs: ...
    // Outputs: ...
    // Function: Sets the title of rows in pickerViews
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView == self._categoryPickerView) {
            return self._requestCategoryViewModel._requestCategoryTableData[row].Title
        } else {
            return "\(row)"
        }
    }
    
    // Name: pickerView -- viewForRow
    // Inputs: None
    // Outputs: None
    // Function: Populates the keyboard pickerViews with required fields.
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        if pickerView == _datePickerView {
            let columnView = UILabel(frame: CGRectMake(30, 0, _screenWidth!/6 - 15, 30))
            let columnViewNum = UILabel(frame: CGRectMake(30, 0, 20, 30))
            if(component == 1) {
                columnView.text = "Day"
            } else if(component == 3) {
                columnView.text = "Hour"
            } else if(component == 5) {
                columnView.text = "Min"
            } else {
                columnView.text = "\(row)"
                columnView.textAlignment = NSTextAlignment.Center
            }
            return columnView
        } else if pickerView == _categoryPickerView {
            let columnView = UILabel(frame: CGRectMake(30, 0, _screenWidth! - 30, 30))
            columnView.text = self._requestCategoryViewModel._requestCategoryTableData[row].Title
            columnView.textAlignment = NSTextAlignment.Center
            return columnView
        }
        return view!
    }
    
    // Name: textViewDidBeginEditing
    // Inputs: ...
    // Outputs: ...
    // Function: If user edits textview, check textColor to make sure the color is returned to black
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    // Name: textViewDidChange
    // Inputs: ...
    // Outputs: ...
    // Function: If textView is changed and cleared, update it with placeholder text
    func textViewDidChange(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
        if (textView.text.isEmpty) {
            textView.textColor = UIColor.lightGrayColor()
            textView.text = self.PLACEHOLDER_TEXT
        }
        
        if(self._postJobButton.titleLabel?.text != POSTBUTTON_TEXT) {
            self._postJobButton.setTitle(self.POSTBUTTON_TEXT, forState: .Normal)
            self._postJobButton.setImage(UIImage(named: "post"), forState: UIControlState.Normal)
        }
    }
    
    // Name: textViewDidEndEditing
    // Inputs: ...
    // Outputs: ...
    // Function: If user finished editing the textView, check if empty. If yes, update it with placeholder text.
    func textViewDidEndEditing(textView: UITextView) {
        if (textView.text.isEmpty) {
            textView.textColor = UIColor.lightGrayColor()
            textView.text = self.PLACEHOLDER_TEXT
        }
    }
    
    // Name: textFieldDidBeginEditing
    // Inputs: ...
    // Outputs: ...
    // Function: Push view up if textField == offerTF || keyTF is edited
    func textFieldDidBeginEditing(textField: UITextField) {
        if(textField == self._jobOfferForCompletionTextField || textField == self._jobKeywordsTextField) {
            self.animateTextField(textField, up:true)
        }
    }
    
    // Name: textFieldDidEndEditing
    // Inputs: ...
    // Outputs: ...
    // Function: Push view down if textfield == offerTF || keyTF is finished editing
    func textFieldDidEndEditing(textField: UITextField) {
        if(textField == self._jobOfferForCompletionTextField || textField == self._jobKeywordsTextField) {
            self.animateTextField(textField, up:false)
        }
    }
    
    // Name: jobInputTextFieldDidChange
    // Inputs: ...
    // Outputs: ...
    // Function: If any input textfields were changed, make sure the Post button reset and is not "Verify"
    func jobInputTextFieldDidChange(textField: UITextField) {
        if(self._postJobButton.titleLabel?.text != POSTBUTTON_TEXT) {
            self._postJobButton.setTitle(self.POSTBUTTON_TEXT, forState: .Normal)
            self._postJobButton.setImage(UIImage(named: "post"), forState: UIControlState.Normal)
        }
    }
    
    // Name: jobInputPickerViewsDidChange
    // Inputs: ...
    // Outputs: ...
    // Function: If any input textfields with pickerview keyboards were changed, make sure the Post button reset and is not "Verify"
    func jobInputPickerViewsDidChange(textField: UITextField) {
        if(self._postJobButton.titleLabel?.text != POSTBUTTON_TEXT) {
            self._postJobButton.setTitle(self.POSTBUTTON_TEXT, forState: .Normal)
            self._postJobButton.setImage(UIImage(named: "post"), forState: UIControlState.Normal)
        }
    }
    
    // Name: textField -- shouldChangeCharactersInRange
    // Inputs: ...
    // Outputs: ...
    // Function: Stops accepting user input for textField under circumstances
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if(textField == self._jobOfferForCompletionTextField) {
            let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string) as? NSString
            var arrayOfString: [AnyObject] = newString!.componentsSeparatedByString(".")
            // Check if there are more than 1 decimal points
            if arrayOfString.count > 2 {
                return false
            }
            // Check for more than 2 chars after the decimal point
            if (arrayOfString.count > 1)
            {
                let decimalAmount:NSString = arrayOfString[1] as! String
                if(decimalAmount.length > 2) {
                    return false
                }
            }
            // Check for an absurdly large amount
            if (arrayOfString.count > 0)
            {
                let dollarAmount:NSString = arrayOfString[0] as! String
                if (dollarAmount.length > 8) {
                    return false
                }
            }
            return true
        }
        return true
    }

}
