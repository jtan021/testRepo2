//
//  PendingRequestCell.swift
//  Hyve V0.07
//
//  Created by Jonathan Tan on 7/1/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import MGSwipeTableCell

class PendingRequestCell: MGSwipeTableCell {
    
    @IBOutlet weak var _pendingRequestImage: UIImageView!
    @IBOutlet weak var _pendingRequestTitle: UILabel!
    @IBOutlet weak var _pendingRequestLifetime: UILabel!
    @IBOutlet weak var _pendingRequestEmployeeNotification: UILabel!
}
