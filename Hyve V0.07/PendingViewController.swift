//
//  PendingViewController.swift
//  Hyve V0.07
//
//  Created by Jonathan Tan on 7/1/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import Parse

class PendingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate {

    /*
     *
     * CONSTANTS
     * section
     *
     */
    private let _pendingRequestViewModel = PendingRequestViewModel()
    private let _pendingAvailableViewModel = PendingAvailabeViewModel()
    
    /*
     *
     * OUTLETS
     * section
     *
     */
    @IBOutlet weak var _pendingRequestTableView: UITableView!
    @IBOutlet weak var _viewToDim: UIView!
    @IBOutlet weak var _pendingAvailableView: UIView!
    @IBOutlet weak var _pendingAvailableTitle: UILabel!
    @IBOutlet weak var _pendingAvailableUsersTableView: UITableView!
    
    /*
     *
     * ACTION FUNCTIONS
     * section
     *
     */
    @IBAction func closePendingAvailableViewDidTouch(sender: AnyObject) {
        print("We have this many employees: \(self._pendingAvailableViewModel._pendingAvailableEmployeeTableData.count)")
        self._pendingAvailableView.hidden = true
        self._viewToDim.hidden = true
    }
    
    
    /*
     *
     * OVERRIDED FUNCTIONS
     * section
     *
     */
    override func viewDidLoad() {
        // Setup TableViews
        self._pendingRequestTableView.dataSource = self
        self._pendingRequestTableView.delegate = self
        self._pendingRequestViewModel._pendingTableView = self._pendingRequestTableView
        self._pendingAvailableUsersTableView.dataSource = self
        self._pendingAvailableUsersTableView.delegate = self
        self._pendingAvailableViewModel._pendingAvailableEmployeeTableView = self._pendingAvailableUsersTableView
        
        // Add refresh to TableView
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshPendingRequestsTableView:", forControlEvents: .ValueChanged)
        self._pendingRequestTableView.addSubview(refreshControl)
    
        // Hide _pendingAvailableView and _viewToDim
        self._pendingAvailableView.hidden = true
        self._viewToDim.hidden = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewUserSegue" {
            print("I AM INNNNN")
            let destinationViewController = segue.destinationViewController as! ViewUserViewController
            let indexPath = self._pendingAvailableUsersTableView.indexPathForSelectedRow
            let firstName = _pendingAvailableViewModel._pendingAvailableEmployeeTableData[indexPath!.row].FirstName
            let lastName = _pendingAvailableViewModel._pendingAvailableEmployeeTableData[indexPath!.row].LastName
            let username = _pendingAvailableViewModel._pendingAvailableEmployeeTableData[indexPath!.row].Username
            let profilePicture = _pendingAvailableViewModel._pendingAvailableEmployeeTableData[indexPath!.row].ProfilePicture
            destinationViewController._userFullName = "\(firstName) \(lastName)"
            destinationViewController._userUsername = username
            destinationViewController._userProfilePictureImage = profilePicture
            destinationViewController._userAboutMe = "About me: This is me! Fix this later"
        }
//        
//        if(segue == "viewUserSegue") {
//            print("I AM INNNNN")
//            let destinationViewController = segue.destinationViewController as! ViewUserViewController
//            let indexPath = self._pendingAvailableUsersTableView.indexPathForSelectedRow!
//            let firstName = _pendingAvailableViewModel._pendingAvailableEmployeeTableData[indexPath.row].FirstName
//            let lastName = _pendingAvailableViewModel._pendingAvailableEmployeeTableData[indexPath.row].LastName
//            let username = _pendingAvailableViewModel._pendingAvailableEmployeeTableData[indexPath.row].Username
//            let profilePicture = _pendingAvailableViewModel._pendingAvailableEmployeeTableData[indexPath.row].ProfilePicture
//            destinationViewController._userFullNameLabel.text = "\(firstName) \(lastName)"
//            destinationViewController._userUsernameLabel.text = username
//            print("picture \(profilePicture)")
//            destinationViewController._userProfilePicture.image = profilePicture
//            destinationViewController._userAboutMeTextView.text = "About me: This is me! Fix this later"
//        }
    }
    
    /*
     *
     * OTHER FUNCTIONS
     * section
     *
     */
    // Name: tableView -- numberOfRowsInSection
    // Inputs: ...
    // Outputs: ...
    // Function: Defines the number of rows in the tableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == _pendingRequestTableView) {
            return _pendingRequestViewModel._pendingRequestTableData.count
        } else if(tableView == _pendingAvailableUsersTableView) {
            return _pendingAvailableViewModel._pendingAvailableEmployeeTableData.count
        } else {
            return 3
        }
    }
    
    // Name: tableView -- didSelectRowAtIndexPath
    // Inputs: ...
    // Outputs: ...
    // Function: Defines what happens when the tableView's cells are tapped
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(tableView == _pendingRequestTableView) {
            self._pendingAvailableTitle.text = _pendingRequestViewModel._pendingRequestTableData[indexPath.row].Title
            
            let pendingAvailableEmployees = _pendingRequestViewModel._pendingRequestTableData[indexPath.row].AvailableEmployees
            
            self._pendingAvailableViewModel.fetchDataFromDataBase(pendingAvailableEmployees)
            self._viewToDim.hidden = false
            self._pendingAvailableView.hidden = false
        } else {
            print("selected")
            self.performSegueWithIdentifier("viewUserSegue", sender: self)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // Name: tableView -- cellForRowAtIndexPath
    // Inputs: ...
    // Outputs: ...
    // Function: Sets up the tableView and the right/left buttons
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if(tableView == _pendingRequestTableView) {
            let reuseIdentifier = "_pendingRequestCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! PendingRequestCell!
            let availableEmployees = _pendingRequestViewModel._pendingRequestTableData[indexPath.row].AvailableEmployees
            let availableEmployeesArray = availableEmployees.componentsSeparatedByString(",")
            
            cell._pendingRequestTitle.text =  _pendingRequestViewModel._pendingRequestTableData[indexPath.row].Title
            cell._pendingRequestLifetime.text = _pendingRequestViewModel._pendingRequestTableData[indexPath.row].LifeRemaining
            cell._pendingRequestEmployeeNotification.text = "\(availableEmployeesArray.count - 1)"
            cell._pendingRequestImage.image = _pendingRequestViewModel._pendingRequestTableData[indexPath.row].Image
            cell.delegate = self //optional
            
            //configure left buttons
            cell.leftButtons = [MGSwipeButton(title: " Share ", backgroundColor: self.colorWithHexString("82A2E5"), callback: {
                (sender: MGSwipeTableCell!) -> Bool in
                print("Share delete Convenience callback for swipe buttons!")
                return true
            })]
            cell.leftSwipeSettings.transition = MGSwipeTransition.Rotate3D
            
            //configure right buttons
            cell.rightButtons = [MGSwipeButton(title: " Delete ", backgroundColor: self.colorWithHexString("E54637"), callback: {
                (sender: MGSwipeTableCell!) -> Bool in
                print("delete Convenience callback for swipe buttons!")
                self.ConfirmDeletePendingRequestAction(indexPath.row)
                return true
            }),MGSwipeButton(title: " Edit ", backgroundColor: self.colorWithHexString("8FE257"), callback: {
                (sender: MGSwipeTableCell!) -> Bool in
                print("edit Convenience callback for swipe buttons!")
                return true
            })]
            cell.rightSwipeSettings.transition = MGSwipeTransition.Rotate3D
            
            return cell
            
        } else if (tableView == _pendingAvailableUsersTableView) {
            let reuseIdentifier = "_pendingAvailableCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! PendingAvailableCell!
            let employeeFirstName = _pendingAvailableViewModel._pendingAvailableEmployeeTableData[indexPath.row].FirstName
            let employeeLastName = _pendingAvailableViewModel._pendingAvailableEmployeeTableData[indexPath.row].LastName
            cell._pendingAvailableFullName.text = "\(employeeFirstName) \(employeeLastName)"
            print(_pendingAvailableViewModel._pendingAvailableEmployeeTableData[indexPath.row].ProfilePicture)
            cell._pendingAvailableImage.image = _pendingAvailableViewModel._pendingAvailableEmployeeTableData[indexPath.row].ProfilePicture
            cell._pendingAvailableUsername.text = _pendingAvailableViewModel._pendingAvailableEmployeeTableData[indexPath.row].Username
            cell.delegate = self
            
//            
//            //configure left buttons
//            cell.leftButtons = [MGSwipeButton(title: "", icon: UIImage(named:"accept"), backgroundColor: self.colorWithHexString("8FE257"), callback: {
//                (sender: MGSwipeTableCell!) -> Bool in
//                print("accept Convenience callback for swipe buttons!")
//                return true
//            })]
//            cell.leftSwipeSettings.transition = MGSwipeTransition.Drag
//            
//            
//            //configure right buttons
//            cell.rightButtons = [MGSwipeButton(title: "", icon: UIImage(named:"remove5"), backgroundColor: self.colorWithHexString("E56F69"), callback: {
//                (sender: MGSwipeTableCell!) -> Bool in
//                print("remove Convenience callback for swipe buttons!")
//                return true
//            })]
//            cell.rightSwipeSettings.transition = MGSwipeTransition.Drag
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("kaboom") as! PendingAvailableCell!
            return cell
        }
    }

    // Name: tableView -- willDisplayCell
    // Inputs: ...
    // Outputs: ...
    // Function: Sets up the background color for selected cells in UITableView
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let selectionColor = UIView() as UIView
        selectionColor.layer.borderWidth = 2
//        selectionColor.layer.borderColor = UIColor.blueColor().CGColor
        selectionColor.backgroundColor = self.colorWithHexString("F9E93B")
        cell.selectedBackgroundView = selectionColor
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection) -> Bool {
        return true
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, swipeButtonsForDirection direction: MGSwipeDirection, swipeSettings: MGSwipeSettings!, expansionSettings: MGSwipeExpansionSettings!) -> [AnyObject]! {
        swipeSettings.transition = MGSwipeTransition.ClipCenter
        swipeSettings.keepButtonsSwiped = false
        expansionSettings.buttonIndex = 0
        expansionSettings.threshold = 1.0
        expansionSettings.expansionLayout = MGSwipeExpansionLayout.Center
        expansionSettings.triggerAnimation.easingFunction = MGSwipeEasingFunction.CubicOut
        expansionSettings.fillOnTrigger = false

        if direction == MGSwipeDirection.RightToLeft {
            expansionSettings.expansionColor = self.colorWithHexString("E56F69")
            let declineButton: MGSwipeButton = MGSwipeButton(title: "", icon: UIImage(named:"remove5"), backgroundColor: self.colorWithHexString("E56F69"), padding: 15, callback: {
                (sender: MGSwipeTableCell!) -> Bool in
                print("remove Convenience callback for swipe buttons!")
                return true
            })
            return [declineButton]
        } else {
            expansionSettings.expansionColor = self.colorWithHexString("8FE257")
            let acceptButton: MGSwipeButton = MGSwipeButton(title: "", icon: UIImage(named:"accept"), backgroundColor: self.colorWithHexString("8FE257"),  padding: 15, callback: {
                (sender: MGSwipeTableCell!) -> Bool in
                print("accept Convenience callback for swipe buttons!")
                return true
            })
            return [acceptButton]
        }
    }
    
    // Name: ConfirmDeletePendingRequestAction
    // Inputs: index: Int
    // Outputs: ...
    // Function: Displays an alert asking user for deletion confirmation and deletes the user's pending request from the database if "Yes" is selected.
    func ConfirmDeletePendingRequestAction(index: Int) {
        // Create the alert controller
        let alertController = UIAlertController(title: "Confirm Delete", message: "Are you sure you want to permanently delete this request?", preferredStyle: .Alert)
        
        // Create the actions
        let YesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            // Attempt remove from Parse Database
            let jobId = self._pendingRequestViewModel._pendingRequestTableData[index].JobID
            let query = PFQuery(className: "JobRequest")
            query.whereKey("objectId", equalTo: jobId)
            query.getFirstObjectInBackgroundWithBlock {
                (object: PFObject?, error: NSError?) -> Void in
                if (object == nil) {
                    self.displayAlert("Request not found", message: "We don't see your request in the Hyve. Try refreshing the table.")
                } else {
                    // The find succeeded.
                    // Remove from Parse
                    object?.deleteInBackgroundWithBlock({ (success: Bool?, error: NSError?) in
                        if(success == true) {
                            // Refresh _pendingRequestTableView
                            dispatch_async(dispatch_get_main_queue()) {
                                self.refreshPendingRequestsTableView(UIRefreshControl())
                            }
                            self.DeleteConfirmationAlert(self._pendingRequestViewModel._pendingRequestTableData[index].Title)
                        } else {
                            self.displayAlert("Oops, something went wrong", message: "Please try again later.")
                        }
                    })
                }
            }
        }
        let NoAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            print("No pressed")
            return
        }
        
        // Add the actions
        alertController.addAction(YesAction)
        alertController.addAction(NoAction)
        
        // Present the controller
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Name: DeleteConfirmationAlert
    // Inputs: title:String
    // Outputs: ...
    // Function: Displays a confirmation alert that the user's pending request has been deleted and refreshes the tableview when "Okay" is tapped.
    func DeleteConfirmationAlert(title: String) {
        // Create the alert controller
        let alertController = UIAlertController(title: "Request Deleted", message: "Your request \"\(title)\" has been removed from the Hyve.", preferredStyle: .Alert)
        
        // Create the actions
        let OkayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self._pendingRequestTableView.reloadData()
            return
        }
        
        // Add the actions
        alertController.addAction(OkayAction)
        
        // Present the controller
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Name: refreshPendingRequestsTableView()
    // Inputs: ...
    // Outputs: ...
    // Function: Fetches new data from database and refreshes the _pendingRequestTableView
    func refreshPendingRequestsTableView(refreshControl: UIRefreshControl) {
        dispatch_async(dispatch_get_main_queue()) {
            self._pendingRequestViewModel.fetchDataFromDataBase()
        }
        self._pendingRequestTableView.reloadData()
        refreshControl.endRefreshing()
    }
}
