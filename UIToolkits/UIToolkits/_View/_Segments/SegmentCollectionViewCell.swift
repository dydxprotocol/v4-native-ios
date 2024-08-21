//
//  TextCollectionViewCell.swift
//  UIToolkits
//
//  Created by Qiang Huang on 10/15/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import SwiftMessages
import UIKit

open class SegmentCollectionViewCell: UICollectionViewCell {
    @IBInspectable public var unselectedBackgroundColor: UIColor?
    @IBInspectable public var selectedBackgroundColor: UIColor?
    @IBInspectable public var unselectedTextColor: UIColor?
    @IBInspectable public var selectedTextColor: UIColor?
    @IBInspectable public var unselectedBorderColor: UIColor?
    @IBInspectable public var selectedBorderColor: UIColor?

    @IBOutlet var view: UIView? {
        didSet {
            updateSelected(animated: false)
        }
    }

    @IBOutlet var selectionBar: UIView? {
        didSet {
            updateSelected(animated: false)
        }
    }

    @IBOutlet var textLabel: LabelProtocol? {
        didSet {
            updateSelected(animated: false)
        }
    }

    @IBOutlet var textLabel2: LabelProtocol? {
        didSet {
            textLabel2?.text = nil
        }
    }

    @IBOutlet var imageView: UIImageView?

    override open var isSelected: Bool {
        didSet {
            if isSelected != oldValue {
                updateSelected(animated: true)
            }
        }
    }

    public var text: String? {
        get {
            if let text = textLabel?.text {
                if let text2 = textLabel2?.text {
                    return [text, text2].joined(separator: "\n")
                } else {
                    return textLabel?.text
                }
            } else {
                return nil
            }
        }
        set {
            let lines = newValue?.components(separatedBy: "\n")
            textLabel?.text = lines?.first
            if lines?.count == 2 {
                textLabel2?.text = lines?.last
            } else {
                textLabel2?.text = nil
            }
            updateImage()
        }
    }

    public var image: String? {
        didSet {
            if image != oldValue {
                if let image = image {
                    imageObj = UIImage.named(image, bundles: Bundle.particles)
                } else {
                    imageObj = nil
                }
            }
        }
    }

    public var selectedImage: String? {
        didSet {
            if selectedImage != oldValue {
                if let selectedImage = selectedImage {
                    selectedImageObj = UIImage.named(selectedImage, bundles: Bundle.particles)
                } else {
                    selectedImageObj = nil
                }
            }
        }
    }

    private var imageObj: UIImage? {
        didSet {
            if imageObj !== oldValue {
                updateImage()
            }
        }
    }

    private var selectedImageObj: UIImage? {
        didSet {
            if selectedImageObj !== oldValue {
                updateImage()
            }
        }
    }

    open func updateTextColor() {
        textLabel?.textColor = view?.borderColor
    }

    open func updateSelected(animated: Bool) {
        if isSelected {
            if let selectedTextColor = selectedTextColor {
                textLabel?.textColor = selectedTextColor
                imageView?.tintColor = selectedTextColor
            }
            if let selectedBackgroundColor = selectedBackgroundColor {
                if let selectionBar = selectionBar {
                    selectionBar.backgroundColor = selectedBackgroundColor
                } else {
                    view?.backgroundColor = selectedBackgroundColor
                }
            }
            if let selectedBorderColor = selectedBorderColor {
                view?.borderColor = selectedBorderColor
            }
        } else {
            if let unselectedTextColor = unselectedTextColor {
                textLabel?.textColor = unselectedTextColor
                imageView?.tintColor = unselectedTextColor
            }
            if let unselectedBackgroundColor = unselectedBackgroundColor {
                if let selectionBar = selectionBar {
                    selectionBar.backgroundColor = unselectedBackgroundColor
                } else {
                    view?.backgroundColor = unselectedBackgroundColor
                }
            }
            if let unselectedBorderColor = unselectedBorderColor {
                view?.borderColor = unselectedBorderColor
            }
        }
        updateImage()
    }

    open func updateImage() {
        if imageObj != nil {
            imageView?.visible = true
            if isSelected {
                if let selectedImageObj = selectedImageObj {
                    imageView?.image = selectedImageObj
                }
            } else {
                if imageView?.image !== imageObj {
                    imageView?.image = imageObj
                }
            }
        } else {
            imageView?.visible = false
        }
    }
}
