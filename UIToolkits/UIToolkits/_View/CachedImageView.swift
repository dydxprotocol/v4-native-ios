//
//  CachedImageView.swift
//  UIToolkits
//
//  Created by Qiang Huang on 10/29/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import SDWebImage
import SVGKit
import UIKit

//  The converted code is limited to 2 KB.
//  Upgrade your plan to remove this limitation.
//
open class CachedImageView: UXImageView {
    public var imageUrl: URL? {
        didSet {
            if imageUrl != oldValue {
                if let imageUrl = imageUrl {
                    if imageUrl.absoluteString.lowercased().ends(with: ".svg") {
                        SVGCache.shared.image(url: imageUrl, completion: { [weak self] image, _ in
                            DispatchQueue.runInMainThread { [weak self] in
                                self?.image = image
                            }
                        })
                    } else {
                        sd_setImage(with: imageUrl, completed: nil)
                    }
                } else {
                    image = nil
                }
            }
        }
    }

    override open var image: UIImage? {
        get { return super.image }
        set {
            if imageUrl != nil {
                self.set(image: newValue, animated: true)
            } else {
                set(image: newValue)
            }
        }
    }

    open func set(image: UIImage?, animated: Bool) {
        DispatchQueue.runInMainThread { [weak self] in
            if animated && image != nil && self?.window != nil {
                UIView.animate(self, type: .fade, direction: .none, duration: UIView.defaultAnimationDuration, animations: { [weak self] in
                    self?.set(image: image)
                }, completion: nil)
            } else {
                self?.set(image: image)
            }
        }
    }

    open func set(image: UIImage?) {
        super.image = image
    }
}
