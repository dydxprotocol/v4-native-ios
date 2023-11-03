//
//  TabSegmentCollectionViewCell.swift
//  UIToolkits
//
//  Created by Qiang Huang on 10/30/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import UIKit

open class TabSegmentCollectionViewCell: SegmentCollectionViewCell {
    override open func updateSelected(animated: Bool) {
        super.updateSelected(animated: animated)
        let collectionView: UICollectionView? = parent()
        if let textLabel = textLabel {
            if let collectionView = collectionView, animated {
                collectionView.performBatchUpdates {
                    textLabel.visible = isSelected
                } completion: { _ in
                }
            } else {
                textLabel.visible = isSelected
            }
        }
    }
}
