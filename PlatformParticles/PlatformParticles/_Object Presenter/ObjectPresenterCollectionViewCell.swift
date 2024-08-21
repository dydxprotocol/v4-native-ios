//
//  ObjectPresenterCollectionViewCell.swift
//  PresenterLib
//
//  Created by Qiang Huang on 10/10/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit
import UIKit

@objc public class ObjectPresenterCollectionViewCell: UICollectionViewCell, ObjectPresenterProtocol {
    @IBOutlet public var presenterView: UIView?

    public var xib: String? {
        didSet {
            if xib != oldValue {
                uninstallView(xib: oldValue, view: presenterView)
                installView(xib: xib, into: contentView, parentViewController: nil) { [weak self] view in
                    self?.presenterView = view
                }
               
            }
        }
    }

    override public var isSelected: Bool {
        didSet {
            if isSelected != oldValue {
                (presenterView as? SelectableProtocol)?.isSelected = isSelected
            }
        }
    }
    
    @objc public var isCellHighlighted: Bool = false {
        didSet {
            if isCellHighlighted != oldValue {
                (presenterView as? HighlightableProtocol)?.isHighlighted = isCellHighlighted
            }
        }
    }

    public var model: ModelObjectProtocol? {
        get { return (presenterView as? ObjectPresenterView)?.model }
        set { (presenterView as? ObjectPresenterView)?.model = newValue }
    }

    @objc open var selectable: Bool {
        return (presenterView as? ObjectPresenterView)?.selectable ?? false
    }

    override public func awakeFromNib() {
        super.awakeFromNib()

        if #available(iOS 12.0, *) {
            contentView.translatesAutoresizingMaskIntoConstraints = false

            // Code below is needed to make the self-sizing cell work when building for iOS 12 from Xcode 10.0:
            let leftConstraint = contentView.leftAnchor.constraint(equalTo: leftAnchor)
            let rightConstraint = contentView.rightAnchor.constraint(equalTo: rightAnchor)
            let topConstraint = contentView.topAnchor.constraint(equalTo: topAnchor)
            let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
            NSLayoutConstraint.activate([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
        }
    }

    override public func prepareForReuse() {
        isSelected = false
        isHighlighted = false
        model = nil
    }
}
