//
//  ISOnDemandCollectionViewInteractor.swift
//  ISOnDemandCollectionView
//
//  Created by Yves Bastos on 16/08/17.
//  Copyright © 2017 Yves Bastos. All rights reserved.
//

import Foundation

protocol ISOnDemandCollectionViewInteractorDelegate {
    func onObjectsFetched(lastObjects: [Any]?, error: Error?)
    func reloadCollectionView()
}

open class ISOnDemandCollectionViewInteractor {
    var delegate: ISOnDemandCollectionViewInteractorDelegate?
    public var objects = [Any]()
    public var pagination: Int = 0
    public var currentPage: Int = 0
    var hasMoreItems = true
    var isFetching = false
    
    
    //MARK: Init
    public init(pagination: Int) {
        self.pagination = pagination
    }
    
    //MARK: Class Methods
    func loadItems() {
        guard !isFetching && hasMoreItems else {
            let message = isFetching ? "Still fetching items, wait..." : "All items were already fetched"
            NSLog(message)
            
            if isFetching {
                isFetching = false
                self.delegate?.onObjectsFetched(lastObjects: [], error: nil)
            }
            return
        }
        isFetching = true 
        fetchObjects(forPage: currentPage) {
            lastObjects, error in
            let lastObjects = lastObjects ?? []
            self.objects += lastObjects
            self.onObjectsLoaded(lastObjectsCount: lastObjects.count)
            self.delegate?.onObjectsFetched(lastObjects: lastObjects, error: error)
        }
    }
    
    func refreshAllContent() {
        guard !isFetching else {
            NSLog("Still fetching items, wait...")
            return
        }
        
        currentPage = 0
        hasMoreItems = true
        objects = []
        delegate?.reloadCollectionView()
        fetchObjects(forPage: currentPage) {
            objects, error in
            let newObjects = objects ?? []
            self.objects = newObjects
            self.onObjectsLoaded(lastObjectsCount: newObjects.count)
            self.delegate?.onObjectsFetched(lastObjects: newObjects, error: error)
        }
    }
    
    /**
     * 
     Override this method to return the new objects fetched every time a new page is loaded or returns an error
     
        - Parameter forPage: the page to load the items for
        - Parameter completion: the function to be called within `ISOnDemandCollectionView` when the user-implemented interactor returns with new items
     */
    open func fetchObjects(forPage: Int, completion: @escaping ((_ result: [Any]?, _ error: Error?)->Void)) { }
    
    
    //MARK: Util
    fileprivate func onObjectsLoaded(lastObjectsCount: Int) {
        isFetching = false
        hasMoreItems = lastObjectsCount >= pagination
        currentPage += 1
    }
}
