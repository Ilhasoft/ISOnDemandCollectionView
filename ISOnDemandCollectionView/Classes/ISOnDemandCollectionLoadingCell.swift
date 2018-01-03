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
        
        NotificationCenter.default.addObserver(self, selector: #selector(setLoadingActivityView(_:)), name: NSNotification.Name("setLoadingActivityView:"), object: nil)

        // Initialization code
    }

    @objc fileprivate func setLoadingActivityView(_ notification: NSNotification) {
        let spin = notification.object as? Bool ?? false
        
        DispatchQueue.main.async {
            spin ? self.spinner.startAnimating() : self.spinner.stopAnimating()
        }
    }
}
