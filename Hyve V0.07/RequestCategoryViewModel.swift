//
//  SearchLocationAddressViewModel.swift
//  Hyve V0.07
//
//  Created by Jonathan Tan on 6/23/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import Bond
import UIKit

struct RequestMenuItem {
    var Title: String = ""
    var Image: UIImage?
}

class RequestCategoryViewModel {
    /*
     *
     * CONSTANTS
     * section
     *
     */
    let _requestCategoryTableData = ObservableArray<RequestMenuItem>()
    var RequestCategoryArray = [RequestMenuItem]()
    
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
        // Setup Request Category Array
        self.RequestCategoryArray.removeAll()
        self.RequestCategoryArray.append(RequestMenuItem(Title: "Food delivery", Image: UIImage(named:"food")))
        self.RequestCategoryArray.append(RequestMenuItem(Title: "Drink delivery", Image: UIImage(named:"drink")))
        self.RequestCategoryArray.append(RequestMenuItem(Title: "Grocery delivery", Image: UIImage(named:"grocery")))
        self.RequestCategoryArray.append(RequestMenuItem(Title: "Wait-in-line", Image: UIImage(named:"wait")))
        self.RequestCategoryArray.append(RequestMenuItem(Title: "Laundry", Image: UIImage(named:"laundry")))
        self.RequestCategoryArray.append(RequestMenuItem(Title: "Special Request", Image: UIImage(named:"specialRequest")))
        
        // Setup _requestCategoryTableData
        self._requestCategoryTableData.extend(self.RequestCategoryArray)
    }
}
