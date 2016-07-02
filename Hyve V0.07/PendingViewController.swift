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
    private var _pendingRequestData:AnyObject?
    
    /*
     *
     * OUTLETS
     * section
     *
     */
    @IBOutlet weak var _pendingRequestTableView: UITableView!
    
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
        // Setup TableView
        self._pendingRequestTableView.dataSource = self
        self._pendingRequestTableView.delegate = self
        self._pendingRequestData = _pendingRequestViewModel._pendingRequestTableData
        
        // Add refresh to TableView
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshPendingRequestsTableView:", forControlEvents: .ValueChanged)
        self._pendingRequestTableView.addSubview(refreshControl)
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
        return _pendingRequestViewModel._pendingRequestTableData.count
    }
    
    // Name: tableView -- didSelectRowAtIndexPath
    // Inputs: ...
    // Outputs: ...
    // Function: Defines what happens when the tableView's cells are tapped
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("selected")
    }
    
    // Name: tableView -- cellForRowAtIndexPath
    // Inputs: ...
    // Outputs: ...
    // Function: Sets up the tableView and the right/left buttons
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let reuseIdentifier = "_pendingRequestCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! PendingRequestCell!
        cell._pendingRequestTitle.text =  _pendingRequestViewModel._pendingRequestTableData[indexPath.row].Title
        cell._pendingRequestLifetime.text = _pendingRequestViewModel._pendingRequestTableData[indexPath.row].LifeRemaining
        cell._pendingRequestEmployeeNotification.text = "0"
        cell._pendingRequestImage.image = _pendingRequestViewModel._pendingRequestTableData[indexPath.row].Image
        cell.delegate = self //optional
        
        //configure left buttons
        cell.leftButtons = [MGSwipeButton(title: "  Share", icon: UIImage(named:"megaphone"), backgroundColor: self.colorWithHexString("82A2E5"), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            print("Share delete Convenience callback for swipe buttons!")
            return true
        })]
        cell.leftSwipeSettings.transition = MGSwipeTransition.Rotate3D
        
        //configure right buttons
        cell.rightButtons = [MGSwipeButton(title: " Delete ", icon: UIImage(named:"delete-1"), backgroundColor: self.colorWithHexString("E54637"), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            print("delete Convenience callback for swipe buttons!")
            self.ConfirmDeletePendingRequestAction(indexPath.row)
            return true
        }),MGSwipeButton(title: "  Edit", icon: UIImage(named:"edit"), backgroundColor: self.colorWithHexString("8FE257"), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            print("edit Convenience callback for swipe buttons!")
            return true
        })]
        cell.rightSwipeSettings.transition = MGSwipeTransition.Drag
        
        return cell
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
