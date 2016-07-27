//
//  EditPendingRequestViewController.swift
//  Hyve V0.07
//
//  Created by Jonathan Tan on 7/11/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import UIKit
import Parse

class EditPendingRequestViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate {

    /*
     *
     * CONSTANTS
     * section
     *
     */
    private let _requestCategoryViewModel = RequestCategoryViewModel()
    var jobId:String = ""
    var jobTitle:String = ""
    var jobCategory:String = ""
    var jobDescription:String = ""
    var jobAdditionalLifetime:String = "0 Day, 0 Hour, 0 Minute."
    var jobOffer:String = ""
    var jobKeywords:String = ""
    var _categoryPickerView = UIPickerView()
    var _datePickerView = UIPickerView()
    var _pickerStringVal: String = String()
    var _selectedDay:Int = 0
    var _selectedHour: Int = 0
    var _selectedMinute: Int = 0
    var _hourArray = [AnyObject]()
    var _minuteArray = [AnyObject]()
    var _dayArray = [AnyObject]()
    var _screenWidth: CGFloat?
    var _screenRect:CGRect = UIScreen.mainScreen().bounds
    
    /*
     *
     * OUTLETS
     * section
     *
     */
    @IBOutlet weak var commitEditsButton: UIButton!
    @IBOutlet weak var _jobKeywordsTextField: UITextField!
    @IBOutlet weak var _jobTitleTextField: UITextField!
    @IBOutlet weak var _jobCategoryTextField: UITextField!
    @IBOutlet weak var _jobDescriptionTextView: UITextView!
    @IBOutlet weak var _jobLifetimeTextField: UITextField!
    @IBOutlet weak var _jobOfferForCompletionTextField: NoPasteTextField!

    /*
     *
     * ACTION FUNCTIONS
     * section
     *
     */
    @IBAction func backButtonDidTouch(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func commitEditsDidTouch(sender: AnyObject) {
        if(commitEditsButton.imageView?.image == UIImage(named: "post2")) {
            commitEditsButton.setImage(UIImage(named:"verifyPost2"), forState: .Normal)
            return
        } else {
            let query = PFQuery(className: "JobRequest")
            query.whereKey("objectId", equalTo: jobId)
            query.getFirstObjectInBackgroundWithBlock {
                (request: PFObject?, error: NSError?) -> Void in
                if (request == nil) {
                    self.displayAlert("Request not found", message: "We don't see your request in the Hyve. Try refreshing the table.")
                } else {
                    // The find succeeded.
                    // Edit request
                    let oldLifetime:Int = request!["jobLifetime"] as! Int
                    let totalTimeInMinutes:Int = (self._selectedDay*24*60 + self._selectedHour*60 + self._selectedMinute)
                    let newLifetime:Int = oldLifetime + totalTimeInMinutes
                    
                    request!["jobTitle"] = self._jobTitleTextField.text
                    request!["jobCategory"] = self._jobCategoryTextField.text
                    request!["jobDescription"] = self._jobDescriptionTextView.text
                    request!["jobOfferForCompletion"] = self._jobOfferForCompletionTextField.text
                    request!["jobLifetime"] = newLifetime
                    
                    request!.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                        if (success) {
                            self.displayRequestUpdatedAlert()
                        } else {
                            self.displayAlert("Error", message: "Request could not be updated. Please try again later.")
                            print("Error saving request: \(error!) \(error!.description)")
                        }
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
        self.commitEditsButton.hidden = true
        
        _jobTitleTextField.text = jobTitle
        _jobCategoryTextField.text = jobCategory
        _jobDescriptionTextView.text = jobDescription
        _jobLifetimeTextField.text = jobAdditionalLifetime
        _jobOfferForCompletionTextField.text = jobOffer
        _jobKeywordsTextField.text = jobKeywords
        
        
        // Hide keyboard when users tap outside editable area
        let tapper = UITapGestureRecognizer(target: view, action:#selector(UIView.endEditing))
        tapper.cancelsTouchesInView = false
        view.addGestureRecognizer(tapper)
        
        // Setup keyboards
        self._screenWidth = self._screenRect.size.width
        // 1) Setup keyboard for _jobCategoryTextField to _categoryPickerView
        self._categoryPickerView.backgroundColor = .whiteColor()
        self._categoryPickerView.showsSelectionIndicator = true
        self._categoryPickerView.dataSource = self
        self._categoryPickerView.delegate = self
        self._jobCategoryTextField.inputView = _categoryPickerView
        // 2) Setup keyboard for _jobLifetimeTextfield to _datePickerView
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
        // 3) Setup keyboard for _jobOfferForCompletionTextfield  to DecimalPad
        self._jobOfferForCompletionTextField.keyboardType = UIKeyboardType.DecimalPad
        self._jobOfferForCompletionTextField.addTarget(self, action: "changeToMoneyString:", forControlEvents: UIControlEvents.EditingChanged)
        // 4) Create "Done" button for _jobOfferForCompletionTextField, _jobLifetimeTextField, and _jobCategoryTextField keyboards and set returnkey for other job input textfields to done
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
        // 5) Set job input textfield delegates
        self._jobTitleTextField.delegate = self
        self._jobCategoryTextField.delegate = self
        self._jobOfferForCompletionTextField.delegate = self
        self._jobKeywordsTextField.delegate = self
        self._jobLifetimeTextField.delegate = self
        self._jobDescriptionTextView.delegate = self
        // 6) Add observers to input textfields and textviews to check for textchange and change _postButton accordingly
        self._jobTitleTextField.addTarget(self, action: #selector(EditPendingRequestViewController.jobInputTextFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        self._jobCategoryTextField.addTarget(self, action: #selector(EditPendingRequestViewController.jobInputPickerViewsDidChange(_:)), forControlEvents: UIControlEvents.EditingDidEnd)
        self._jobLifetimeTextField.addTarget(self, action: #selector(EditPendingRequestViewController.jobInputPickerViewsDidChange(_:)), forControlEvents: UIControlEvents.EditingDidEnd)
        self._jobOfferForCompletionTextField.addTarget(self, action: #selector(EditPendingRequestViewController.jobInputTextFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        self._jobKeywordsTextField.addTarget(self, action: #selector(EditPendingRequestViewController.jobInputTextFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
    }
    
    /*
     *
     * OTHER FUNCTIONS
     * section
     *
     */
    func displayRequestUpdatedAlert()
    {
        let alertController = UIAlertController(title: "Request Updated", message: "Request \"\(jobTitle)\" has been updated.", preferredStyle: .Alert)
        
        // Create the actions
        let OkayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        // Add the actions
        alertController.addAction(OkayAction)
        
        // Present the controller
        self.presentViewController(alertController, animated: true, completion: nil)
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
    
    // Name: jobInputTextFieldDidChange
    // Inputs: ...
    // Outputs: ...
    // Function: If any input textfields were changed, make sure the Post button is visible and resets so that is not "verifyPost"
    func jobInputTextFieldDidChange(textField: UITextField) {
        if(self._jobTitleTextField.text == jobTitle && self._jobOfferForCompletionTextField.text == jobOffer && self._jobKeywordsTextField.text == jobKeywords && self._jobCategoryTextField.text == jobCategory && self._jobLifetimeTextField.text == jobAdditionalLifetime && self._jobDescriptionTextView.text == jobDescription) {
            self.commitEditsButton.hidden = true
        } else {
            self.commitEditsButton.hidden = false
        }
        
        if(commitEditsButton.imageView?.image != UIImage(named: "post2")) {
            commitEditsButton.setImage(UIImage(named:"post2"), forState: .Normal)
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        if(self._jobTitleTextField.text == jobTitle && self._jobOfferForCompletionTextField.text == jobOffer && self._jobKeywordsTextField.text == jobKeywords && self._jobCategoryTextField.text == jobCategory && self._jobLifetimeTextField.text == jobAdditionalLifetime && self._jobDescriptionTextView.text == jobDescription) {
            self.commitEditsButton.hidden = true
        } else {
            self.commitEditsButton.hidden = false
        }
        
        if(commitEditsButton.imageView?.image != UIImage(named: "post2")) {
            commitEditsButton.setImage(UIImage(named:"post2"), forState: .Normal)
        }
    }
    
    // Name: jobInputPickerViewsDidChange
    // Inputs: ...
    // Outputs: ...
    // Function: If any input textfields with pickerview keyboards were changed, make sure the Post button is visible and resets so that is not "verifyPost"
    func jobInputPickerViewsDidChange(textField: UITextField) {
        if(self._jobTitleTextField.text == jobTitle && self._jobOfferForCompletionTextField.text == jobOffer && self._jobKeywordsTextField.text == jobKeywords && self._jobCategoryTextField.text == jobCategory && self._jobLifetimeTextField.text == jobAdditionalLifetime && self._jobDescriptionTextView.text == jobDescription) {
            self.commitEditsButton.hidden = true
        } else {
            self.commitEditsButton.hidden = false
        }
        
        if(commitEditsButton.imageView?.image != UIImage(named: "post2")) {
            commitEditsButton.setImage(UIImage(named:"post2"), forState: .Normal)
        }
    }

    // Name: textFieldDidBeginEditing
    // Inputs: ...
    // Outputs: ...
    // Function: Push view up if textField == offerTF || keyTF is edited
    func textFieldDidBeginEditing(textField: UITextField) {
        if(textField == self._jobOfferForCompletionTextField || textField == self._jobKeywordsTextField || textField == self._jobLifetimeTextField) {
            self.animateEditTextField(textField, up:true)
        }
    }
    
    // Name: textFieldDidEndEditing
    // Inputs: ...
    // Outputs: ...
    // Function: Push view down if textfield == offerTF || keyTF is finished editing
    func textFieldDidEndEditing(textField: UITextField) {
        if(textField == self._jobOfferForCompletionTextField || textField == self._jobKeywordsTextField || textField == self._jobLifetimeTextField) {
            self.animateEditTextField(textField, up:false)
        }
    }
    
    // Name: textViewDidBeginEditing
    // Inputs: ...
    // Outputs: ...
    // Function: Push view up if textField == offerTF || keyTF is edited
    func textViewDidBeginEditing(textView: UITextView) {
        self.animateEditTextView(textView, up:true)
    }
    
    // Name: textViewDidEndEditing
    // Inputs: ...
    // Outputs: ...
    // Function: Push view down if textfield == offerTF || keyTF is finished editing
    func textViewDidEndEditing(textView: UITextView) {
        self.animateEditTextView(textView, up:false)
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
        if(textField == self._jobTitleTextField || textField == self._jobKeywordsTextField) {
            let currentCharacterCount = textField.text?.characters.count ?? 0
            if (range.length + range.location > currentCharacterCount){
                return false
            }
            let newLength = currentCharacterCount + string.characters.count - range.length
            return newLength <= 25
        }
        return true
    }
    
    func animateEditTextField(textField: UITextField, up: Bool) {
        let movementDistance:CGFloat = -200
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
    
    func animateEditTextView(textView: UITextView, up: Bool) {
        let movementDistance:CGFloat = -90
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
}
