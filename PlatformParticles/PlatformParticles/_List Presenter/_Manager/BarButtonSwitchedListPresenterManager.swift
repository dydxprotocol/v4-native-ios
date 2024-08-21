//
//  BarButtonSwitchedListPresenterManager.swift
//  PresenterLib
//
//  Created by John Huang on 10/12/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import UIToolkits

@objc open class BarButtonSwitchedListPresenterManager: ListPresenterManager {
    @objc open dynamic override var current: ListPresenter? {
        didSet {
            updateBarButton()
        }
    }

    @IBOutlet public var barButton: ButtonProtocol? {
        didSet {
            if barButton !== oldValue {
                oldValue?.removeTarget()
                barButton?.addTarget(self, action: #selector(view(_:)))
            }
            updateBarButton()
        }
    }

    private func updateBarButton() {
        if let barButton = barButton {
            if let icon = current?.icon {
                barButton.buttonTitle = nil
                barButton.buttonImage = icon
            } else if let title = current?.title {
                barButton.buttonTitle = title
                barButton.buttonImage = nil
            } else {
                barButton.buttonTitle = nil
                barButton.buttonImage = nil
            }
        }
    }

    @IBAction public func view(_ sender: Any?) {
        let count = presenters?.count ?? 0
        if count > 0 {
            var next: Int = 0
            if let index = index {
                next = index.intValue + 1
            }
            if next >= count {
                next = 0
            }
            index = NSNumber(value: next)
        } else {
            index = nil
        }
    }
}
