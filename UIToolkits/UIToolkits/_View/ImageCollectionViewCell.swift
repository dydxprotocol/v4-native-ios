//
//  ImageCollectionViewCell.swift
//  UIToolkits
//
//  Created by Qiang Huang on 10/15/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import UIKit

open class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: CachedImageView? {
        didSet {
            imageView?.backgroundColor = UIColor.black
        }
    }

    public var image: String? {
        didSet {
            if image != oldValue {
                if let image = image, let url = image.components(separatedBy: "@").first {
                    imageUrl = URL(string: url)
                } else {
                    imageUrl = nil
                }
            }
        }
    }

    public var imageUrl: URL? {
        get { return imageView?.imageUrl }
        set { imageView?.imageUrl = newValue }
    }
}
