//
//  CurrentUser.swift
//  Hyve V0.07
//
//  Created by Jonathan Tan on 6/27/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import Parse

struct CurrentUser {
    public let CurrentUser = PFUser.currentUser()
    public var Username:String = ""
    public var FirstName:String = ""
    public var LastName:String = ""
    public var FullName:String = ""
    
    init() {
        if CurrentUser?.username != nil {
            self.Username = CurrentUser!.username! 
            self.FirstName = (CurrentUser!["firstName"] as! String)
            self.LastName = (CurrentUser!["lastName"] as! String)
            self.FullName = self.FirstName + " " + self.LastName
        }
    }
}
