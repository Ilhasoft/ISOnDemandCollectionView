//
//  ISOnDemandCollectionView.swift
//  ISOnDemandCollectionView
//
//  Created by Yves Bastos on 16/08/17.
//  Copyright © 2017 Yves Bastos. All rights reserved.
//

import Foundation
import UIKit

public class ISOnDemandCollectionView: UICollectionView {
    public var onDemandDelegate: ISOnDemandCollectionViewDelegate?
    public var interactor: ISOnDemandCollectionViewInteractor! {
        didSet {
            interactor?.delegate = self
        }
    }
    fileprivate var showSpinnerFooter = false
    
    //MARK: Init
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        initialize()
    }
    
    fileprivate func initialize() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(onPullToRefresh), for: .valueChanged)
        dataSource = self
        delegate = self
        register(UINib(nibName: "ISOnDemandCollectionLoadingCell", bundle: Bundle(for: ISOnDemandCollectionLoadingCell.self)), forCellWithReuseIdentifier: "ISOnDemandCollectionLoadingCell")
    }
    
    //MARK: Class Methods
    @objc fileprivate func onPullToRefresh() {
        onDemandDelegate?.onDemandWasPulled?(toRefresh: self)
        interactor?.refreshAllContent()
    }
    
    /**
     Loads the contents in the on demand collectionView.
     */
    public func loadContent() {
        guard let _ = onDemandDelegate, let interactor = interactor else {
            fatalError("You must set both ISOnDemandColectionViewDelegate and ISOnDemandCollectionViewInteractor before calling loadContent")
        }
        if !(refreshControl?.isRefreshing ?? false) && supplementaryView(forElementKind: UICollectionElementKindSectionFooter, at: []) == nil {
            interactor.loadItems()
            
            setFooterSpinner(to: true)//interactor.hasMoreItems)
        }
    }
    
    /**
     Forces all items to fetched again, resetting the `collectionView`
     */
    public func refresh() {
        interactor.refreshAllContent()
    }
    
    //MARK: Util
    func setFooterSpinner(to show: Bool) {
        showSpinnerFooter = show
        
        let indexPath = IndexPath(row: 0, section: 1)
        if showSpinnerFooter && !(refreshControl?.isRefreshing ?? false) && numberOfItems(inSection: 1) == 0 {
            insertItems(at: [indexPath])
        } else if !showSpinnerFooter && numberOfItems(inSection: 1) == 1 {
//            deleteItems(at: [indexPath])
        }
    }
}

extension ISOnDemandCollectionView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count: Int!
        if section == 0 {
            count = interactor?.objects.count ?? 0
        } else {
            count = 1
        }
        return count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell!
        guard let collectionView = collectionView as? ISOnDemandCollectionView else {
            fatalError("The collectionView must be of type ISOnDemandCollectionView!")
            return cell
        }
        
        var cellIdentifier: String!
        if indexPath.section == 1 {
            cellIdentifier = "ISOnDemandCollectionLoadingCell"
        } else {
            cellIdentifier = onDemandDelegate?.onDemandCollectionView(collectionView, reuseIdentifierForItemAt: indexPath)
        }
        
        cell = dequeueReusableCell(withReuseIdentifier: cellIdentifier ?? "ISOnDemandCollectionViewCell", for: indexPath)
        if let cell = cell as? ISOnDemandCollectionViewCell {
            let object = interactor.objects[indexPath.row]
            cell.setup(with: object, at: indexPath)
            onDemandDelegate?.onDemandCollectionView?(collectionView, setup: cell, at: indexPath)
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = cellForItem(at: indexPath) as? ISOnDemandCollectionViewCell {
            onDemandDelegate?.onDemandCollectionView?(self, didSelect: cell, at: indexPath)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, at indexPath: IndexPath) {
        if let cell = cell as? ISOnDemandCollectionViewCell {
            onDemandDelegate?.onDemandCollectionView?(self, willDisplayCell: cell, at: indexPath)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ISOnDemandCollectionViewCell {
            onDemandDelegate?.onDemandCollectionView?(self, didEndDisplaying: cell, at: indexPath)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size: CGSize! = onDemandDelegate?.onDemandCollectionView?(self, sizeForItemAt: indexPath)
        if size == nil {
            size = UICollectionViewFlowLayoutAutomaticSize
        }
        return size
    }
    
    //MARK: Scroll methods
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        onDemandDelegate?.onDemandCollectionView?(self, scrollViewDidScroll: scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            onScrollFinish()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        onScrollFinish()
    }
    
    private func onScrollFinish() {
        let scrollDirection = (collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection ?? .vertical
        let contentDirectionalOffset = scrollDirection  == .horizontal ? (contentOffset.x + frame.size.width) : (contentOffset.y + frame.size.height)
        let contentDirectionalSize = scrollDirection == .horizontal ? contentSize.width : contentSize.height
        if contentDirectionalOffset >= contentDirectionalSize {
            loadContent()
        }
    }
}

extension ISOnDemandCollectionView: ISOnDemandCollectionViewInteractorDelegate {
    func onObjectsFetched(lastObjects: [Any]?, error: Error?) {
        if refreshControl?.isRefreshing ?? false {
            refreshControl?.endRefreshing()
        }
        setFooterSpinner(to: false)
        onDemandDelegate?.onDemandCollectionView(self, onContentLoadFinishedWithError: error)
        if error == nil && lastObjects?.count ?? 0 > 0 {
            let lastObjectsRowDelta = Array(0..<lastObjects!.count)
            var indexes = [IndexPath]()
            let initialRow = numberOfItems(inSection: 0)
            lastObjectsRowDelta.forEach {
                rowDelta in
                indexes.append(IndexPath(row: initialRow+rowDelta, section: 0))
            }
            insertItems(at: indexes)
        }
    }
}

//MARK: - Protocols

@objc public protocol ISOnDemandCollectionViewCell {
    func setup(with object: Any, at indexPath: IndexPath)
}

@objc public protocol ISOnDemandCollectionViewDelegate {
    @objc func onDemandCollectionView(_ collectionView: ISOnDemandCollectionView, reuseIdentifierForItemAt indexPath: IndexPath) -> String
    @objc func onDemandCollectionView(_ collectionView: ISOnDemandCollectionView, onContentLoadFinishedWithError error: Error?)
    
    @objc optional func onDemandCollectionView(_ collectionView: ISOnDemandCollectionView, scrollViewDidScroll: UIScrollView)
    @objc optional func onDemandWasPulled(toRefresh: ISOnDemandCollectionView)
    @objc optional func onDemandCollectionView(_ collectionView: ISOnDemandCollectionView, setup cell: ISOnDemandCollectionViewCell, at indexPath: IndexPath)
    @objc optional func onDemandCollectionView(_ collectionView: ISOnDemandCollectionView, didSelect cell: ISOnDemandCollectionViewCell, at indexPath: IndexPath)
    @objc optional func onDemandCollectionView(_ collectionView: ISOnDemandCollectionView, willDisplayCell: ISOnDemandCollectionViewCell, at indexPath: IndexPath)
    @objc optional func onDemandCollectionView(_ collectionView: ISOnDemandCollectionView, didEndDisplaying: ISOnDemandCollectionViewCell, at indexPath: IndexPath)
    @objc optional func onDemandCollectionView(_ collectionView: ISOnDemandCollectionView, sizeForItemAt indexPath: IndexPath) -> CGSize
    
}
