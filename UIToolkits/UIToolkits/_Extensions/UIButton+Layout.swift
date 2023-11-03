//
//  UIButton+Layout.swift
//  UIToolkits
//
//  Created by Qiang Huang on 11/23/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import UIKit

public extension UIButton {
    func centerImageAndButton(_ gap: CGFloat, imageOnTop: Bool) {
        guard let imageView = currentImage,
              let titleLabel = self.titleLabel?.text else { return }

        let sign: CGFloat = imageOnTop ? 1 : -1
        titleEdgeInsets = UIEdgeInsets(top: (imageView.size.height + gap) * sign, left: -imageView.size.width, bottom: 0, right: 0)

        let titleSize = titleLabel.size(withAttributes: [NSAttributedString.Key.font: self.titleLabel!.font!])
        imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + gap) * sign, left: 0, bottom: 0, right: -titleSize.width)
    }

    func setInsets(forContentPadding contentPadding: UIEdgeInsets, imageTitlePadding: CGFloat) {
        contentEdgeInsets = UIEdgeInsets(top: contentPadding.top, left: contentPadding.left, bottom: contentPadding.bottom, right: contentPadding.right + imageTitlePadding)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: imageTitlePadding, bottom: 0, right: -imageTitlePadding)
    }

    func setImages(right: UIImage? = nil, left: UIImage? = nil) {
        if let leftImage = left, right == nil {
            setImage(leftImage, for: .normal)
            imageEdgeInsets = UIEdgeInsets(top: 5, left: bounds.width - 35, bottom: 5, right: 5)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: (imageView?.frame.width)!)
            contentHorizontalAlignment = .left
        }
        if let rightImage = right, left == nil {
            setImage(rightImage, for: .normal)
            imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: bounds.width - 35)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: (imageView?.frame.width)!, bottom: 0, right: 16)
            contentHorizontalAlignment = .right
        }

        if let rightImage = right, let leftImage = left {
            setImage(rightImage, for: .normal)
            imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: bounds.width - 35)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: (imageView?.frame.width)!, bottom: 0, right: 16)
            contentHorizontalAlignment = .left

            let leftImageView = UIImageView(frame: CGRect(x: bounds.maxX - 30,
                                                          y: (titleLabel?.bounds.midY)! - 5,
                                                          width: 20,
                                                          height: frame.height - 16))
            leftImageView.image?.withRenderingMode(.alwaysOriginal)
            leftImageView.image = leftImage
            leftImageView.contentMode = .scaleAspectFit
            leftImageView.layer.masksToBounds = true
            addSubview(leftImageView)
        }
    }

    func imageToRight() {
        transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
    }
}
