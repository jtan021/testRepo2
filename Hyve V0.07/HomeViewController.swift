//
//  HomeViewController.swift
//  Hyve V0.07
//
//  Created by Jonathan Tan on 6/23/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//
import Bond
import UIKit
import MapKit

class HomeViewController: UIViewController {
    /*
     *
     * CONSTANTS
     * section
     *
     */
    private let _searchLocationAddressViewModel = SearchLocationAddressViewModel()
    private let _requestCategoryViewModel = RequestCategoryViewModel()
    
    /*
     *
     * OUTLETS
     * section
     *
     */
    @IBOutlet weak var _searchTextField: SearchTextField!
    @IBOutlet weak var _searchHYVETextField: SearchTextField!
    @IBOutlet weak var _mapView: MKMapView!
    @IBOutlet weak var _searchLocationAddressTextField: SearchTextField!
//    @IBOutlet weak var _searchLocationAddressTableView: UITableView!
    @IBOutlet weak var _requestCategoryTableView: UITableView!
    @IBOutlet weak var _searchLocationAddressTableView: UITableView!
    
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
        _searchLocationAddressViewModel._mapView = _mapView
        self.bindSearchLocationAddressViewModel()
        self.bindRequestCategoryViewModel()
    }
    
    /*
     *
     * OTHER FUNCTIONS
     * section
     *
     */
    // Name: bindSearchLocationAddressViewModel()
    // Inputs: ...
    // Outputs: ...
    // Function: Binds _searchLocationAddressTextField and _searchLocationAddressTableView to the _searchLocationAddressViewModel to obtain data
    func bindSearchLocationAddressViewModel() {
        _searchLocationAddressViewModel._searchLocationAddress.bidirectionalBindTo(_searchLocationAddressTextField.bnd_text)
        
        _searchLocationAddressViewModel._searchLocationAddressResults.lift().bindTo(_searchLocationAddressTableView) { indexPath, dataSource, tableView in
            let cell = tableView.dequeueReusableCellWithIdentifier("_searchLocationAddressCell", forIndexPath: indexPath)
            let locationTableItem = dataSource[indexPath.section][indexPath.row].placemark
            cell.textLabel!.text = locationTableItem.name
            cell.detailTextLabel!.text = self.parseAddress(locationTableItem)
            print(locationTableItem.name)
            return cell
        }
    }
    
    // Name: bindRequestCategoryViewModel()
    // Inputs: ...
    // Outputs: ...
    // Function: Binds _requestCategoryTableView to the _requestCategoryViewModel to obtain data
    func bindRequestCategoryViewModel() {
        _requestCategoryViewModel._requestCategoryTableData.lift().bindTo(_requestCategoryTableView) { indexPath, dataSource, tableView in
            let cell = tableView.dequeueReusableCellWithIdentifier("_requestCategoryCell", forIndexPath: indexPath) as! RequestCategoryCell
            cell._requestTitle.text = dataSource[indexPath.section][indexPath.row].Title
            cell._requestImage.image = dataSource[indexPath.section][indexPath.row].Image
            return cell
        }
    }
}
