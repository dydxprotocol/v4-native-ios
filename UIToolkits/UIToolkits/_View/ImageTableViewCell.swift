//
//  ImageTableViewCell.swift
//  UIToolkits
//
//  Created by Qiang Huang on 11/28/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import UIKit

open class ImageTableViewCell: UITableViewCell {
    @IBOutlet var imageUrlView: CachedImageView? {
        didSet {
            imageUrlView?.backgroundColor = UIColor.black
        }
    }

    public var imageUrl: URL? {
        get { return imageUrlView?.imageUrl }
        set { imageUrlView?.imageUrl = newValue }
    }
}
