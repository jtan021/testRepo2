//
//  LoginRegisterView.swift
//  Hyve V0.07
//
//  Created by Jonathan Tan on 6/23/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import THLabel
import UIKit
import Parse

class LoginRegisterViewController: UIViewController, UITextFieldDelegate {

    /*
     *
     * CONSTANTS
     * section
     *
     */
    
    /*
     *
     * OUTLETS
     * section
     *
     */
    // Login View
    @IBOutlet weak var _hyveLabel: THLabel!
    @IBOutlet weak var _loginUsernameTextField: UITextField!
    @IBOutlet weak var _loginPasswordTextField: UITextField!
    // Registration View
    @IBOutlet weak var _hyveRegistrationLabel: UILabel!
    @IBOutlet weak var _registrationView: UIView!
    @IBOutlet weak var _viewToDim: UIView!
    @IBOutlet weak var _registrationFirstNameTextField: UITextField!
    @IBOutlet weak var _registrationLastNameTextField: UITextField!
    @IBOutlet weak var _registrationEmailAddressTextField: UITextField!
    @IBOutlet weak var _registrationConfirmPasswordTextField: UITextField!
    
    /*
     *
     * ACTION FUNCTIONS
     * section
     *
     */
    @IBAction func LoginDidTouch(sender: AnyObject) {
        // First check that all fields are filled out.
        if (_loginUsernameTextField.text == "" || _loginPasswordTextField.text == "") {
            self.displayAlert("Missing field(s)", message: "All fields must be filled out.")
        } else {
            // If fields are all filled out, attempt to log user in
            PFUser.logInWithUsernameInBackground(_loginUsernameTextField.text!, password:_loginPasswordTextField.text!) {
                (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    self.performSegueWithIdentifier("successfulLoginSegue", sender: self)
                    print("Login Successful")
                } else {
                    if let errorString = error?.userInfo["error"] as? NSString {
                        self.displayAlert("Login failed", message: errorString as String)
                    }
                }
            }
        }
    }
    
    @IBAction func RegisterDidTouch(sender: AnyObject) {
        // First check that all fields are filled out.
        if (_loginUsernameTextField.text == "" || _loginPasswordTextField.text == "") {
            self.displayAlert("Missing field(s)", message: "Please enter your desired username & password to continue.")
        } else if (_loginUsernameTextField.text!.rangeOfCharacterFromSet(Constants.characterSet.invertedSet) != nil) {
            self.displayAlert("Invalid username", message: "Acceptable characters for a Hyve account username include letters a-z, A-Z, and numbers 0-9")
        } else {
            // Second check that the entered username is not taken
            let query = PFQuery(className: "_User")
            query.whereKey("username", equalTo: _loginUsernameTextField.text!)
            query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    if (objects!.count > 0) {
                        print("username is taken")
                        self.displayAlert("Account unavailable", message: "Username is already in use.")
                    } else {
                        print("username is available")
                        
                        // Since fields are not nil and username is available, show the registrationView
                        self._viewToDim.hidden = false
                        self._registrationView.hidden = false
                    }
                } else {
                    print(error)
                }
            }
        }
    }
    
    @IBAction func CreateAccountDidTouch(sender: AnyObject) {
        // First check that all fields are filled out.
        if (_registrationFirstNameTextField.text == "" || _registrationLastNameTextField.text == "" || _registrationConfirmPasswordTextField.text == "" || _registrationEmailAddressTextField.text == "") {
            self.displayAlert("Missing field(s)", message: "All fields must be filled out.")
            return
        } else {
            // Second check that the two passwords entered match
            if (_loginPasswordTextField.text != _registrationConfirmPasswordTextField.text) {
                self.displayAlert("Invalid password", message: "The confirmed password must be identical to the previously entered password.")
                return
            } else {
                // Since fields are not nil and the passwords match, attempt to create the account
                let user = PFUser()
                user.username = _loginUsernameTextField.text
                user.password = _registrationConfirmPasswordTextField.text
                user.email = _registrationEmailAddressTextField.text
                user["firstName"] = _registrationFirstNameTextField.text
                user["lastName"] = _registrationLastNameTextField.text
                user["currentLAT"] = 0
                user["currentLONG"] = 0
                let image = UIImagePNGRepresentation(UIImage(named: "gender_neutral_user")!)
                let profilePic = PFFile(name: "profile.png", data: image!)
                user["profilePic"] = profilePic
                user.signUpInBackgroundWithBlock {
                    (succeeded, error) -> Void in
                    // If account creation failed, display error
                    if let error = error {
                        if let errorString = error.userInfo["error"] as? NSString {
                            self.displayAlert("Registration failed", message: errorString as String)
                        }
                    } else {
                        // Else account has been successfully registered, hide registrationView
                        let newFriendObject = PFObject(className: "friends")
                        newFriendObject["username"] = self._loginUsernameTextField.text
                        newFriendObject["friendsList"] = ""
                        newFriendObject["pendingFrom"] = ""
                        newFriendObject["pendingTo"] = ""
                        let defaultACL = PFACL()
                        defaultACL.publicWriteAccess = true
                        defaultACL.publicReadAccess = true
                        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)
                        newFriendObject.ACL = defaultACL
                        newFriendObject.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            if (success) {
                                print("Successful registration")
                                self._viewToDim.hidden = true
                                self._registrationView.hidden = true
                                self.displayAlert("\(self._loginUsernameTextField.text!) successfully registered", message: "Welcome to Hyve.")
                                self.performSegueWithIdentifier("successfulLoginSegue", sender: self)
                            } else {
                                print("registerDidTouch(1): \(error!) \(error!.description)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func ReturnToLoginViewDidTouch(sender: AnyObject) {
        self._registrationView.hidden = true
        self._viewToDim.hidden = true
    }
    
    
    /*
     *
     * OVERRIDED FUNCTIONS
     * section
     *
     */
    override func viewDidLoad() {
        // Hide registrationView
        self._viewToDim.hidden = true
        self._registrationView.hidden = true
        
        // Customize THLabels (HYVELabel & HYVERegistrationLabel)
        self._hyveLabel.shadowColor = Constants.kShadowColor2
        self._hyveLabel.shadowOffset = Constants.kShadowOffset
        self._hyveLabel.shadowBlur = Constants.kShadowBlur
        self._hyveLabel.innerShadowColor = Constants.kShadowColor2
        self._hyveLabel.innerShadowOffset = Constants.kInnerShadowOffset
        self._hyveLabel.innerShadowBlur = Constants.kInnerShadowBlur
        self._hyveLabel.strokeColor = Constants.kStrokeColor
        self._hyveLabel.strokeSize = Constants.kStrokeSize
        self._hyveLabel.gradientStartColor = Constants.kGradientStartColor
        self._hyveLabel.gradientEndColor = Constants.kGradientEndColor
        
//        self._hyveRegistrationLabel.shadowColor = Constants.kShadowColor2
//        self._hyveRegistrationLabel.shadowOffset = Constants.kShadowOffset
//        self._hyveRegistrationLabel.shadowBlur = Constants.kShadowBlur
//        self._hyveRegistrationLabel.innerShadowColor = Constants.kShadowColor2
//        self._hyveRegistrationLabel.innerShadowOffset = Constants.kInnerShadowOffset
//        self._hyveRegistrationLabel.innerShadowBlur = Constants.kInnerShadowBlur
//        self._hyveRegistrationLabel.strokeColor = Constants.kStrokeColor
//        self._hyveRegistrationLabel.strokeSize = Constants.kStrokeSize
//        self._hyveRegistrationLabel.gradientStartColor = Constants.kGradientStartColor
//        self._hyveRegistrationLabel.gradientEndColor = Constants.kGradientEndColor
        
        // Adds gesture so keyboard is dismissed when areas outside of editable text are tapped
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Set textfield delegates
        self._loginUsernameTextField.delegate = self
        self._loginPasswordTextField.delegate = self
        self._registrationFirstNameTextField.delegate = self
        self._registrationLastNameTextField.delegate = self
        self._registrationEmailAddressTextField.delegate = self
        self._registrationConfirmPasswordTextField.delegate = self
        
        // Add Done button to all textfield keyboards
        self._loginUsernameTextField.returnKeyType = UIReturnKeyType.Done
        self._loginPasswordTextField.returnKeyType = UIReturnKeyType.Done
        self._registrationFirstNameTextField.returnKeyType = UIReturnKeyType.Done
        self._registrationLastNameTextField.returnKeyType = UIReturnKeyType.Done
        self._registrationEmailAddressTextField.returnKeyType = UIReturnKeyType.Done
        self._registrationConfirmPasswordTextField.returnKeyType = UIReturnKeyType.Done
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check if user is already logged in
        let currentUser = PFUser.currentUser()
        if currentUser?.username != nil {
            // If yes, skip login page and go to main view
            performSegueWithIdentifier("successfulLoginSegue", sender: self)
        }
    }
    
    /*
     *
     * OTHER FUNCTIONS
     * section
     *
     */
}
