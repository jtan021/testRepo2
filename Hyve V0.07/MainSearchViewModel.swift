//
//  MainSearchViewModel.swift
//  Hyve V0.07
//
//  Created by Jonathan Tan on 6/25/16.
//  Copyright © 2016 Jonathan Tan. All rights reserved.
//

import Bond
import Foundation

class MainSearchViewModel {
    
    /*
     *
     * CONSTANTS
     * section
     *
     */
    let _searchText = Observable<String?>("")
    let _searchDidBegin = Observable<Bool>(false)
    var _searchNavigationBarOriginY:NSLayoutConstraint?
    
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
        _searchText
            .map { $0!.characters.count > 0 }
            .bindTo(_searchDidBegin)
        
        _searchText
            .filter { $0!.characters.count > 0 }
            .observe {
                [unowned self] text in
                self._searchNavigationBarOriginY?.constant += 154
        }
    }
    
}
