//
//  CollectionViewXibRegister.swift
//  PresenterLib
//
//  Created by Qiang Huang on 10/12/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit
import Utilities

internal class CollectionViewXibRegister: NSObject & XibRegisterProtocol {
    private let kCellName = "CollectionViewCell"
    internal weak var collectionView: UICollectionView?
    internal var registeredXibs: Set<String> = []

    internal func register(xib: String) {
        if let nib = UINib.safeLoad(xib: kCellName, bundles: Bundle.particles) {
            collectionView?.register(nib, forCellWithReuseIdentifier: xib)
        }
    }
}
