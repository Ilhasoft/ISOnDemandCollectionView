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
    var animate: Bool = false {
        didSet {
            setLoadingActivityView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    fileprivate func setLoadingActivityView() {
        DispatchQueue.main.async {
            self.animate ? self.spinner?.startAnimating() : self.spinner?.stopAnimating()
        }
    }
}

