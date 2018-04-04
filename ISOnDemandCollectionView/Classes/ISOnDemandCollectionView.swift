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
    fileprivate var firstLoad = true
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
        dataSource = self
        delegate = self
        
        register(UINib(nibName: "ISOnDemandCollectionLoadingCell", bundle: Bundle(for: ISOnDemandCollectionLoadingCell.self)), forCellWithReuseIdentifier: "ISOnDemandCollectionLoadingCell")
    }
    
    //MARK: Class Methods
    public func setLayout(to layout: UICollectionViewFlowLayout) {
        collectionViewLayout = layout
    }
    
    /**
     Loads the contents in the on demand collectionView.
     */
    public func loadContent() {
        guard let _ = onDemandDelegate, let interactor = interactor else {
            fatalError("You must set both ISOnDemandColectionViewDelegate and ISOnDemandCollectionViewInteractor before calling loadContent")
        }
        if !interactor.isFetching {
            onDemandDelegate?.onDemandWillStartLoading?(self)
            interactor.loadItems()
        }
    }
    
    /**
     Forces all items to fetched again, resetting the `collectionView`
     */
    public func refresh() {
        interactor.refreshAllContent()
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
        
        let cellIdentifier = onDemandDelegate?.onDemandCollectionView(collectionView, reuseIdentifierForItemAt: indexPath)
        if indexPath.section == 1 {
            cell = dequeueReusableCell(withReuseIdentifier: "ISOnDemandCollectionLoadingCell", for: indexPath)
            (cell as? ISOnDemandCollectionLoadingCell)?.animate = interactor?.isFetching ?? false
        } else {
            cell = dequeueReusableCell(withReuseIdentifier: cellIdentifier ?? "ISOnDemandCollectionViewCell", for: indexPath)
        }
        
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
            if #available(iOS 10.0, *) {
                size = UICollectionViewFlowLayoutAutomaticSize
            } else {
                size = CGSize(width: 50, height: 50)
            }
        }
        return size
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let spacing: CGFloat! = onDemandDelegate?.onDemandCollectionView?(self, layout: collectionViewLayout, minimumLineSpacingForSection: section) ?? 0
        return spacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = onDemandDelegate?.onDemandCollectionView?(self, collectionViewLayout: collectionViewLayout, insetForSectionAt: section) ?? UIEdgeInsetsMake(0, 0, 0, 0)
        return inset
    }
    
    //MARK: Scroll methods
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        onDemandDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            onScrollFinish()
        }
        onDemandDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        onDemandDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        onDemandDelegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        onScrollFinish()
        onDemandDelegate?.scrollViewDidEndDecelerating?(scrollView)
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
        if #available(iOS 10.0, *) {
            if refreshControl?.isRefreshing ?? false {
                refreshControl?.endRefreshing()
            }
        }
        
        let lastObjectsCount = lastObjects?.count ?? 0
        if error == nil && lastObjectsCount > 0 {
            let lastObjectsRowDelta = Array(0..<lastObjects!.count)
            var indexes = [IndexPath]()
            let initialRow = numberOfItems(inSection: 0) //- lastObjectsCount
            lastObjectsRowDelta.forEach {
                rowDelta in
                indexes.append(IndexPath(row: initialRow+rowDelta, section: 0))
            }
            
            if firstLoad {
                firstLoad = false
            }
            reloadCollectionView()
//            } else if indexes.count > 0 {
//                insertItems(at: indexes)
//            }
        }
        onDemandDelegate?.onDemandCollectionView(self, onContentLoadFinishedWithNewObjects: lastObjects, error: error)
    }
    
    func setSpinnerCell(to animate: Bool) {
        DispatchQueue.main.async {
            let loadingCell = (self.cellForItem(at: IndexPath(item: 0, section: 1)) as? ISOnDemandCollectionLoadingCell)
            loadingCell?.animate = animate
        }
    }
    
    func reloadCollectionView() {
        self.reloadData()
    }
}

//MARK: - Protocols

@objc public protocol ISOnDemandCollectionViewCell {
    func setup(with object: Any, at indexPath: IndexPath)
}

@objc public protocol ISOnDemandCollectionViewDelegate: UIScrollViewDelegate {
    @objc func onDemandCollectionView(_ collectionView: ISOnDemandCollectionView, reuseIdentifierForItemAt indexPath: IndexPath) -> String
    @objc func onDemandCollectionView(_ collectionView: ISOnDemandCollectionView, onContentLoadFinishedWithNewObjects objects: [Any]?, error: Error?)
    
    @objc optional func onDemandWillStartLoading(_ collectionView: ISOnDemandCollectionView)
    @objc optional func onDemandCollectionView(_ collectionView: ISOnDemandCollectionView, setup cell: ISOnDemandCollectionViewCell, at indexPath: IndexPath)
    @objc optional func onDemandCollectionView(_ collectionView: ISOnDemandCollectionView, didSelect cell: ISOnDemandCollectionViewCell, at indexPath: IndexPath)
    @objc optional func onDemandCollectionView(_ collectionView: ISOnDemandCollectionView, willDisplayCell: ISOnDemandCollectionViewCell, at indexPath: IndexPath)
    @objc optional func onDemandCollectionView(_ collectionView: ISOnDemandCollectionView, didEndDisplaying: ISOnDemandCollectionViewCell, at indexPath: IndexPath)
    
    @objc optional func onDemandCollectionView(_ collectionView: ISOnDemandCollectionView, sizeForItemAt indexPath: IndexPath) -> CGSize
    @objc optional func onDemandCollectionView(_ collectionView: ISOnDemandCollectionView, layout: UICollectionViewLayout, minimumLineSpacingForSection: Int) -> CGFloat
    @objc optional func onDemandCollectionView(_ collectionView: ISOnDemandCollectionView, collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    
}

