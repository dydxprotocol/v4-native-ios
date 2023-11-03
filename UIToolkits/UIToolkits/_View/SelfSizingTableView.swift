//
//  SelfSizingTableView.swift
//  UIToolkits
//
//  Created by Qiang Huang on 1/19/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import UIKit

open class SelfSizingTableView: UITableView {
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
