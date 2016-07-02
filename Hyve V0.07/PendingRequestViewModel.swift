//
//  PendingRequestViewModel.swift
//  Hyve V0.07
//
//  Created by Jonathan Tan on 6/26/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import Bond
import Parse

struct PendingRequestItem {
    var JobID: String = ""
    var Title: String = ""
    var Address: String = ""
    var Category: String = ""
    var Description: String = ""
    var LifeRemaining: String = ""
    var OfferForCompletion: String = ""
    var Keywords: String = ""
    var Status: String = ""
    var CompletionStatus: Bool?
    var Employee: String = ""
    var Image:UIImage?
}

class PendingRequestViewModel {
    /*
     *
     * CONSTANTS
     * section
     *
     */
    let _currentUser = PFUser.currentUser()
    let _pendingRequestTableData = ObservableArray<PendingRequestItem>()
    var PendingRequestArray = [PendingRequestItem]()
    let FoodDeliveryImage = UIImage(named:"food")
    let DrinkDeliveryImage = UIImage(named:"drink")
    let GroceryDeliveryImage = UIImage(named: "grocery")
    let WaitInLineImage = UIImage(named: "wait")
    let LaundryImage = UIImage(named: "laundry")
    let SpecialRequestImage = UIImage(named:"specialRequest")
    
    
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
        self.fetchDataFromDataBase()
    }
    
    // Name: fetchDataFromDataBase
    // Inputs: ...
    // Outputs: ...
    // Function: Reloads _pendingRequestTableData 
    func fetchDataFromDataBase() -> Void {
        self._pendingRequestTableData.removeAll()
        self.PendingRequestArray.removeAll()
        let query = PFQuery(className:"JobRequest")
        query.whereKey("username", equalTo:_currentUser!.username!)
        query.orderByDescending("jobLastUpdated")
        query.findObjectsInBackgroundWithBlock {
            (usersRequests: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                // The find succeeded.
                // Do something with the found objects
                if let requests = usersRequests {
                    for request in requests {
                        // 1) Check if that the job is not expired
                        let jobStatus = request["jobStatus"] as! String
                        let jobLastUpdated = request["jobLastUpdated"] as! String
                        let totalJobLifetime = request["jobLifetime"] as! Int
                        var daysPassed: Int = 0
                        var hoursPassed: Int = 0
                        var minutesPassed: Int = 0
                        var daysRemaining: Int = 0
                        var hoursRemaining: Int = 0
                        var minutesRemaining: Int = 0
                        
                        // Get lifeRemaining
                        var lifeRemaining:String = ""
                        // 1) Convert string UTC lastUpdated to a local time NSDate object
                        let localLastUpdated:NSDate = self.getLocalFromUTCDate(jobLastUpdated)
                        // 2) Get current date in local time
                        let dateFormat: NSDateFormatter = NSDateFormatter()
                        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let currentDate = dateFormat.dateFromString(self.getDate())! as NSDate
                        
                        
                        // 3) Find difference between dates
                        daysPassed = currentDate.daysFrom(localLastUpdated)
                        hoursPassed = currentDate.hoursFrom(localLastUpdated)
                        minutesPassed = currentDate.minutesFrom(localLastUpdated)
                        
                        // 4) Calculate the time remaining = totalLife - timePassed
                        let totalTimePassed = daysPassed*24*60 + hoursPassed*60 + minutesPassed
                        var totalTimeRemaining = totalJobLifetime - totalTimePassed
                        
                        // 5) Update status if lifeRemaining <= 0 && status != working -> job expired
                        if ((totalTimeRemaining <= 0) && (jobStatus != "Working")) {
                            request["jobStatus"] = "Expired"
                            request.saveInBackground()
                            
                            // If job is not expired, continue to add it to the TableViewData
                        } else {
                            let jobID = request.objectId
                            let jobTitle = request["jobTitle"] as! String
                            let jobAddress = request["jobAddress"] as! String
                            let jobCategory = request["jobCategory"] as! String
                            let jobDescription = request["jobDescription"] as! String
                            let jobOfferForCompletion = request["jobOfferForCompletion"] as! String
                            let jobKeywords = request["jobKeywords"] as! String
                            let jobCompletionStatus = request["jobCompleted"] as! Bool
                            let jobEmployee = request["jobEmployee"] as! String
                            var jobImage: UIImage?
                            
                            var currentStatus = request["jobStatus"] as! String
                            
                            // 6) Calculate the total days, hours, and minutes remaining from totalTimeRemaining
                            daysRemaining = totalTimeRemaining/(24*60)
                            hoursRemaining = totalTimeRemaining%(24*60)/60
                            minutesRemaining = totalTimeRemaining%(24*60)%60
                            // 7) Update lifeRemaining string
                            if daysRemaining > 1 {
                                lifeRemaining = "\(daysRemaining) days"
                            } else {
                                lifeRemaining = "\(daysRemaining) day"
                            }
                            if hoursRemaining > 1 {
                                lifeRemaining = "\(lifeRemaining), \(hoursRemaining) hours"
                            } else {
                                lifeRemaining = "\(lifeRemaining), \(hoursRemaining) hour"
                            }
                            if minutesRemaining > 1 {
                                lifeRemaining = "\(lifeRemaining), \(minutesRemaining) minutes."
                            } else {
                                lifeRemaining = "\(lifeRemaining), \(minutesRemaining) minute."
                            }
                            // End get lifeRemaining
                            
                            // 8) Select image depending on category
                            switch jobCategory {
                                case "Food delivery":
                                    jobImage = self.FoodDeliveryImage
                                case "Drink delivery":
                                    jobImage = self.DrinkDeliveryImage
                                case "Grocery delivery":
                                    jobImage = self.GroceryDeliveryImage
                                case "Wait-in-line":
                                    jobImage = self.WaitInLineImage
                                case "Laundry":
                                    jobImage = self.LaundryImage
                                case "Special Request":
                                    jobImage = self.SpecialRequestImage
                                default:
                                    jobImage = self.SpecialRequestImage
                            }

                            // if status: active put a green dot form jobStatus image
                            // if status: working put a yellow dot for jobStatus image
                            // if status: expired put a red dot for jobStatus image
                            
                            // Create PendingRequestItem
                            let newPendingRequestItem = PendingRequestItem(JobID: jobID!, Title: jobTitle, Address: jobAddress, Category: jobCategory, Description: jobDescription, LifeRemaining: lifeRemaining, OfferForCompletion: jobOfferForCompletion, Keywords: jobKeywords, Status: currentStatus, CompletionStatus: jobCompletionStatus, Employee: jobEmployee, Image: jobImage)
                            // Append PendingRequestItem to PendingRequestArray then to _pendingRequestTableData
                            dispatch_async(dispatch_get_main_queue()) {
                                self.PendingRequestArray.append(newPendingRequestItem)
                                self._pendingRequestTableData.insertContentsOf(self.PendingRequestArray, atIndex: 0)
                                self.PendingRequestArray.removeAll()
                            }
                        }
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    // Name: getLocalFromUTCDate
    // Inputs: strDate: String
    // Outputs: NSDate
    // Function: Take an input string which is in UTC time and convert it to local time as an NSDate object
    func getLocalFromUTCDate(strDate: String) -> NSDate {
        let dateFormat: NSDateFormatter = NSDateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormat.timeZone = NSTimeZone(name: "UTC")
        let aDate: NSDate = dateFormat.dateFromString(strDate)!
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormat.timeZone = NSTimeZone.systemTimeZone()
        return aDate
    }
    
    // Name: getDate
    // Inputs: ...
    // Outputs: String
    // Function: Gets current date and output in format yyyy-MM-dd HH:mm:ss
    func getDate() -> String {
        let currentDate = NSDate()
        let dateFormat: NSDateFormatter = NSDateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let convertedDate = dateFormat.stringFromDate(currentDate)
        return convertedDate
    }
    
    
}
