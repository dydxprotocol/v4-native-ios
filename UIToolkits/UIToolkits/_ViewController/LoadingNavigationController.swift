//
//  LoadingNavigationController.swift
//  UIToolkits
//
//  Created by Qiang Huang on 11/20/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import UIKit
import Utilities

open class LoadingNavigationController: UXNavigationController, LoadingIndicatorProtocol {
    public var status: LoadingStatusProtocol? {
        didSet {
            changeObservation(from: oldValue, to: status, keyPath: #keyPath(LoadingStatusProtocol.running)) { [weak self] _, _, _, _ in
                self?.update()
            }
        }
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .lightContent
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        status = LoadingStatus.shared
    }

    open func update() {
    }
}
