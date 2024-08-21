//
//  ImageAddCollectionViewCell.swift
//  UIToolkits
//
//  Created by Qiang Huang on 11/28/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import UIKit

open class ImageAddCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var spinner: SpinnerProtocol?

    public var spinning: Bool = false {
        didSet {
            if spinning != oldValue {
                if spinning {
                    spinner?.visible = true
                    spinner?.spinning = true
                    imageView?.visible = false
                } else {
                    spinner?.visible = false
                    spinner?.spinning = false
                    imageView?.visible = true
                }
            }
        }
    }
}
