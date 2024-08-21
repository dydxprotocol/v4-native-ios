//
//  ObjectPresenterTableViewCell.swift
//  PresenterLib
//
//  Created by John Huang on 10/10/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import UIKit

@objc open class ObjectPresenterTableViewCell: UITableViewCell, ObjectPresenterProtocol {
    @IBOutlet public var presenterView: UIView?
    
    public func setXib(_ xib: String?, parentViewController: UIViewController?) {
        if xib != self.xib {
            uninstallView(xib: self.xib, view: presenterView)
            self.xib = xib
            installPresenterView(xib: xib, parentViewController: parentViewController)
        }
    }
    
    private var xib: String?
    /*
    public var xib: String? {
        didSet {
            if xib != oldValue {
                uninstallView(xib: xib, view: presenterView)
                installPresenterView(xib: xib)
            }
        }
    }
    */
    public var model: ModelObjectProtocol? {
        get { return (presenterView as? ObjectPresenterView)?.model }
        set {
            if let presenter = presenterView as? ObjectPresenterProtocol {
                presenter.model = newValue
                if let selectable = presenter.selectable {
                    selectionStyle = selectable ? .default : .none
                } else {
                    selectionStyle = .none
                }
            } else {
                selectionStyle = .none
            }
        }
    }

    @objc open var selectable: Bool {
        return (presenterView as? ObjectPresenterView)?.selectable ?? false
    }

    open var showDisclosure: Bool? {
        if let presetingView = presenterView as? ObjectPresenterView {
            return presetingView.showDisclosure
        }
        return nil
    }

    open override var isSelected: Bool {
        didSet {
            if isSelected != oldValue {
                (presenterView as? SelectableProtocol)?.isSelected = isSelected
            }
        }
    }

    @objc open dynamic var isFirst: Bool = false {
        didSet {
            (presenterView as? ObjectPresenterView)?.isFirst = isFirst
        }
    }

    @objc open dynamic var isLast: Bool = false {
        didSet {
            (presenterView as? ObjectPresenterView)?.isLast = isLast
        }
    }

    open override func prepareForReuse() {
        model = nil
        isSelected = false
        isHighlighted = false
        isFirst = false
        isLast = false
    }

    open func installPresenterView(xib: String?, parentViewController: UIViewController?) {
        installView(xib: xib, into: contentView, parentViewController: parentViewController) { [weak self] view in
            self?.presenterView = view
        }
    }

    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        (presenterView as? SelectableProtocol)?.isSelected = isSelected
    }
    
    open override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        (presenterView as? HighlightableProtocol)?.isHighlighted = highlighted
    }
}
