//
//  ISOnDemandCollectionLoadingCell.swift
//  Pods
//
//  Created by Yves on 17/08/17.
//
//

import UIKit

class ISOnDemandCollectionLoadingCell: UICollectionViewCell {
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        spinner.startAnimating()
        // Initialization code
    }

}
