//
//  MyAccountViewController.swift
//  Hyve V0.07
//
//  Created by Jonathan Tan on 6/27/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import Bond
import Parse

class MyAccountViewController: UIViewController, UITableViewDelegate {

    /*
     *
     * CONSTANTS
     * section
     *
     */
    private let _myAccountViewModel = MyAccountViewModel()
    
    /*
     *
     * OUTLETS
     * section
     *
     */
    @IBOutlet weak var _myAccountTableView: UITableView!
    @IBOutlet weak var _myAccountProfilePictureImageView: UIImageView!
    @IBOutlet weak var _myAccountFullNameLabel: UILabel!
    @IBOutlet weak var _myAccountUsernameLabel: UILabel!
    @IBOutlet weak var _myAccountWalletLabel: UILabel!

    /*
     *
     * ACTION FUNCTIONS
     * section
     *
     */
    
    /*
     *
     * OVERRIDED FUNCTIONS
     * section
     *
     */
    override func viewDidLoad() {
        // Setup the navigation bar
        self._myAccountUsernameLabel.text = CurrentUser.init().Username
        self._myAccountFullNameLabel.text = CurrentUser.init().FullName
        self._myAccountWalletLabel.text = "Amount in Wallet: $0.00"
        
        // Bind to MyAccountViewModel and setup tableview
        self.BindMyAccountViewModel()
        self._myAccountTableView.delegate = self
    }
    
    /*
     *
     * OTHER FUNCTIONS
     * section
     *
     */
    // Name: BindRequestCategoryViewModel()
    // Inputs: ...
    // Outputs: ...
    // Function: Binds _requestCategoryTableView to the _requestCategoryViewModel to obtain data
    func BindMyAccountViewModel() {
        _myAccountViewModel._myAccountTableData.lift().bindTo(_myAccountTableView) { indexPath, dataSource, tableView in
            let cell = tableView.dequeueReusableCellWithIdentifier("_myAccountCell", forIndexPath: indexPath) as! MyAccountCell
            cell._accountTitle.text = dataSource[indexPath.section][indexPath.row].itemTitle
            cell._accountImage.image = dataSource[indexPath.section][indexPath.row].itemImage
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(self._myAccountViewModel._myAccountTableData[indexPath.row].itemTitle == "Logout") {
            PFUser.logOut()
            let currentUser = PFUser.currentUser()
            if(currentUser?.username == nil) {
                print("\nLogout Successful\n")
                self.performSegueWithIdentifier("successfulLogOutSegue", sender: self)
            }
        }
    }
    

    
}
