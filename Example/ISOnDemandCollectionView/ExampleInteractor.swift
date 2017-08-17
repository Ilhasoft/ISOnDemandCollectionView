//
//  ExampleInteractor.swift
//  ISOnDemandCollectionView
//
//  Created by Yves on 17/08/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import ISOnDemandCollectionView

class ExampleInteractor: ISOnDemandCollectionViewInteractor {
    let paginationOfChoice = 5
    
    init() {
        super.init(pagination: paginationOfChoice)
    }
    
    override open func fetchObjects(forPage: Int, completion: @escaping (([Any]?, Error?) -> Void)) {
        // Simulate network delay times
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            var objects: [Any] = []
            let lowerBound = forPage * self.pagination
            let upperBound = (forPage + 1) * self.pagination
            for index in lowerBound..<upperBound {
                if index > 100 {
                    break
                }
                objects.append(index)
            }
            
            completion(objects, nil)
        })
    }
}
