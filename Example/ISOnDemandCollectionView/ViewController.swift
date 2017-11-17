//
//  ViewController.swift
//  ISOnDemandCollectionView
//
//  Created by yvesbastos on 08/17/2017.
//  Copyright (c) 2017 yvesbastos. All rights reserved.
//

import UIKit
import ISOnDemandCollectionView

class ViewController: UIViewController {
    @IBOutlet var collectionView: ISOnDemandCollectionView!

    //MARK: Init/Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }

    fileprivate func setupCollectionView() {
        collectionView.register(UINib(nibName: "ExampleCollectionViewCell", bundle: Bundle(for: ExampleCollectionViewCell.self)), forCellWithReuseIdentifier: "ExampleCollectionViewCell")
        collectionView.onDemandDelegate = self
        collectionView.interactor = ExampleInteractor()
        collectionView.loadContent()
    }
}

extension ViewController: ISOnDemandCollectionViewDelegate {
    func onDemandCollectionView(_ collectionView: ISOnDemandCollectionView, reuseIdentifierForItemAt indexPath: IndexPath) -> String {
        return "ExampleCollectionViewCell"
    }
    
    func onDemandCollectionView(_ collectionView: ISOnDemandCollectionView, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func onDemandCollectionView(_ collectionView: ISOnDemandCollectionView, onContentLoadFinishedWithNewObjects objects: [Any]?, error: Error?) {
        print(error ?? "No error")
    }
}
