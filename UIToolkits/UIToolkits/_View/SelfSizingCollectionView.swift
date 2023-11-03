//
//  SelfSizingCollectionView.swift
//  UIToolkits
//
//  Created by Qiang Huang on 9/1/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import UIKit

open class SelfSizingCollectionView: UICollectionView {
    open override func layoutSubviews() {
        super.layoutSubviews()
        if !__CGSizeEqualToSize(bounds.size, intrinsicContentSize) {
            invalidateIntrinsicContentSize()
        }
    }

    open override var intrinsicContentSize: CGSize {
        return contentSize
    }
}
