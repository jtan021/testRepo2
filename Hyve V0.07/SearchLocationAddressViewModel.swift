//
//  SearchLocationAddressViewModel.swift
//  Hyve V0.07
//
//  Created by Jonathan Tan on 6/23/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import Bond
import MapKit
import UIKit

class SearchLocationAddressViewModel {
    /*
     *
     * CONSTANTS
     * section
     *
     */
    let _searchLocationAddress = Observable<String?>("")
    let _searchDidBegin = Observable<Bool>(false)
    let _searchLocationAddressResults = ObservableArray<MKMapItem>()
    var _mapView:MKMapView?
    
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
        _searchLocationAddress
            .filter { $0!.characters.count > 0 }
            .observe {
                [unowned self] text in
                print(text!)
                self.executeLocationSearch(text!)
            }
        
        _searchLocationAddress
            .map { $0!.characters.count > 0 }
            .bindTo(_searchDidBegin)
    }
    
    func executeLocationSearch(text: String) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = text
        request.region = self._mapView!.region
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { response, _ in
            guard let response = response else {
                return
            }
            //print(response.mapItems)
            self._searchLocationAddressResults.applyOperation(ObservableArrayOperation.Reset(array: response.mapItems))
        }
    }
}
