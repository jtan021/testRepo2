//
//  ViewUserViewController.swift
//  Hyve V0.07
//
//  Created by Jonathan Tan on 7/2/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import UIKit

class ViewUserViewController: UIViewController {

    /*
     *
     * CONSTANTS
     * section
     *
     */
    var _userFullName:String = ""
    var _userUsername:String = ""
    var _userProfilePictureImage: UIImage?
    var _userAboutMe:String = ""
    
    /*
     *
     * OUTLETS
     * section
     *
     */
    @IBOutlet weak var _userFullNameLabel: UILabel!
    @IBOutlet weak var _userUsernameLabel: UILabel!
    @IBOutlet weak var _userProfilePicture: UIImageView!
    @IBOutlet weak var _userAboutMeTextView: UITextView!
    
    /*
     *
     * ACTION FUNCTIONS
     * section
     *
     */
    @IBAction func backButtonDidTouch(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    

    /*
     *
     * OVERRIDED FUNCTIONS
     * section
     *
     */
    override func viewDidLoad() {
        self.navigationController?.navigationBarHidden = true
        self.navigationItem.hidesBackButton = false
        
        self._userFullNameLabel.text = _userFullName
        self._userUsernameLabel.text = _userUsername
        self._userProfilePicture.image = _userProfilePictureImage
        self._userAboutMeTextView.text = _userAboutMe
    }
    
    override func viewDidAppear(animated: Bool) {
        self._userFullNameLabel.text = _userFullName
        self._userUsernameLabel.text = _userUsername
        self._userProfilePicture.image = _userProfilePictureImage
        self._userAboutMeTextView.text = _userAboutMe
    }

    /*
     *
     * OTHER FUNCTIONS
     * section
     *
     */
    
}
