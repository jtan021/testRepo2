//
//  MyAccountViewModel.swift
//  Hyve V0.07
//
//  Created by Jonathan Tan on 6/27/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import UIKit
import Bond
import Parse

struct MyAccountTableItem {
    var itemTitle: String?
    var itemImage: UIImage?
}

class MyAccountViewModel {
    
    /*
     *
     * CONSTANTS
     * section
     *
     */
    let _currentUser = PFUser.currentUser()
    let _myAccountTableData = ObservableArray<MyAccountTableItem>()
    var MyAccountArray = [MyAccountTableItem]()
    
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
    init() {
        // Setup _myAccountArray
        self.MyAccountArray.append(MyAccountTableItem(itemTitle: "Logout", itemImage: UIImage(named: "logOut")))
        
        // Setup _myAccountTableData
        self._myAccountTableData.extend(self.MyAccountArray)
    }
    
    /*
     *
     * OTHER FUNCTIONS
     * section
     *
     */

}
