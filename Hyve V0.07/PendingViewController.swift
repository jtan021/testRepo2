//
//  SecondViewController.swift
//  Hyve V0.07
//
//  Created by Jonathan Tan on 6/21/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import UIKit

class PendingViewController: UIViewController {

    /*
     *
     * CONSTANTS
     * section
     *
     */
    private let _pendingRequestViewModel = PendingRequestViewModel()
    
    /*
     *
     * OUTLETS
     * section
     *
     */
    @IBOutlet weak var _pendingRequestsTableView: UITableView!
    
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
        // Bind _pendingRequestsTableView to __pendingRequestTableData from _pendingRequestViewModel to obtain initial data
        self.BindPendingRequestViewModel()
        // Add pull-down to refresh gesture for _pendingRequestsTableView
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshPendingRequestsTableView:", forControlEvents: .ValueChanged)
        _pendingRequestsTableView.addSubview(refreshControl)
    }
    
    /*
     *
     * OTHER FUNCTIONS
     * section
     *
     */
    // Name: BindSearchLocationAddressViewModel()
    // Inputs: ...
    // Outputs: ...
    // Function: Binds _pendingRequestsTableView to the _pendingRequestViewModel to obtain data
    func BindPendingRequestViewModel() {
        _pendingRequestViewModel._pendingRequestTableData.lift().bindTo(_pendingRequestsTableView) { indexPath, dataSource, tableView in
            let cell = tableView.dequeueReusableCellWithIdentifier("_pendingRequestCell", forIndexPath: indexPath) as! PendingRequestCell
            let pendingRequestItem = dataSource[indexPath.section][indexPath.row]
            cell.Title.text = "\(pendingRequestItem.Title) -- \(pendingRequestItem.OfferForCompletion)"
            cell.Address.text = "Job Address: \(pendingRequestItem.Address)"
            cell.TimeRemaining.text =  "Lifetime: \(pendingRequestItem.LifeRemaining)"
            cell.Employee.text =  "Employee: \(pendingRequestItem.Employee)"
            return cell
        }
        self._pendingRequestsTableView.reloadData()
    }
    
    // Name: refreshPendingRequestsTableView()
    // Inputs: ...
    // Outputs: ...
    // Function: Fetches new data from database and refreshes the _pendingRequestsTableView
    func refreshPendingRequestsTableView(refreshControl: UIRefreshControl) {
        _pendingRequestViewModel.fetchDataFromDataBase()
        self.BindPendingRequestViewModel()
        refreshControl.endRefreshing()
    }

}

