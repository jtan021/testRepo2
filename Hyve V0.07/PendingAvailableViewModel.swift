//
//  PendingAvailableViewModel.swift
//  Hyve V0.07
//
//  Created by Jonathan Tan on 7/1/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import Parse
import Bond

struct PendingEmployeeItem {
    var UserId:String = ""
    var FirstName:String = ""
    var LastName:String = ""
    var Username:String = ""
    var ProfilePicture:UIImage?
}

class PendingAvailabeViewModel {
    /*
     *
     * CONSTANTS
     * section
     *
     */
    let _currentUser = PFUser.currentUser()
    let _pendingAvailableEmployeeTableData = ObservableArray<PendingEmployeeItem>()
    var PendingAvailableEmployeeArray = [PendingEmployeeItem]()
    var _pendingAvailableEmployeeTableView: UITableView?
    
    /*
     *
     * OUTLETS
     * section
     *
     */
    
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
    
    /*
     *
     * OTHER FUNCTIONS
     * section
     *
     */
    init() {
        
    }
    
    // Name: fetchDataFromDataBase
    // Inputs: ...
    // Outputs: ...
    // Function: Reloads _pendingRequestTableData
    func fetchDataFromDataBase(availableEmployees: String) -> Void {
        self._pendingAvailableEmployeeTableData.removeAll()
        self.PendingAvailableEmployeeArray.removeAll()
        
        let availableEmployeesArray = availableEmployees.componentsSeparatedByString(",")
        for employee in availableEmployeesArray {
            if(employee != "") {
                print("Employee username = \(employee)")
                let query = PFQuery(className:"_User")
                query.whereKey("username", equalTo: employee)
                query.getFirstObjectInBackgroundWithBlock {
                    (employee: PFObject?, error: NSError?) -> Void in
                    if error != nil {
                        print(error)
                    } else if let employee = employee {
                        let employeeUsername = employee["username"] as! String
                        let employeeId = employee.objectId!
                        let employeeFirstName = employee["firstName"] as! String
                        let employeeLastName = employee["lastName"] as! String
                        let employeeProfilePictureData = employee["profilePic"] as! PFFile
                        var employeeProfilePicture: UIImage?
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            employeeProfilePictureData.getDataInBackgroundWithBlock({
                                (imageData: NSData?, error: NSError?) -> Void in
                                if (error == nil) {
                                    employeeProfilePicture = UIImage(data:imageData!)
                                } else {
                                    employeeProfilePicture = UIImage(named: "Hyve Symbol")
                                }
                                let newPendingEmployeeItem = PendingEmployeeItem(UserId: employeeId, FirstName: employeeFirstName, LastName: employeeLastName, Username: employeeUsername, ProfilePicture: employeeProfilePicture)
                                self.PendingAvailableEmployeeArray.append(newPendingEmployeeItem)
                                self._pendingAvailableEmployeeTableData.insertContentsOf(self.PendingAvailableEmployeeArray, atIndex: 0)
                                self._pendingAvailableEmployeeTableView?.reloadData()
                                self.PendingAvailableEmployeeArray.removeAll()
                            })
                        }
                    }
                }
            }
        }
    }
    
}
