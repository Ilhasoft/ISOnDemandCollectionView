//
//  ExampleCollectionViewCell.swift
//  ISOnDemandCollectionView
//
//  Created by Yves on 17/08/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import ISOnDemandCollectionView

class ExampleCollectionViewCell: UICollectionViewCell, ISOnDemandCollectionViewCell {
    @IBOutlet var lbTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //MARK: ISOnDemand
    func setup(with object: Any, at indexPath: IndexPath) {
        let value = object as? Int ?? 0
        lbTitle.text = String(value)
    }
}
