//
//  UpgradeViewController.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 8/24/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import RoutingKit
import UIToolkits
import Utilities

open class UpgradeViewController: TrackingViewController {
    @IBInspectable var url: String?
    @IBInspectable var text: String? {
        didSet {
            if text != oldValue {
                updateButton()
            }
        }
    }

    @IBInspectable var msg: String? {
        didSet {
            if msg != oldValue {
                updateMessage()
            }
        }
    }

    @IBOutlet var messageLabel: LabelProtocol? {
        didSet {
            if messageLabel !== oldValue {
                updateMessage()
            }
        }
    }

    @IBOutlet var upgradeButton: ButtonProtocol? {
        didSet {
            if upgradeButton !== oldValue {
                updateButton()
                oldValue?.removeTarget()
                upgradeButton?.addTarget(self, action: #selector(upgrade(_:)))
            }
        }
    }

    open override func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/upgrade" {
            if let text = parser.asString(request?.params?["texts"]) {
                self.text = text
            }
            if let url = parser.asString(request?.params?["url"]) {
                self.url = url
            }
            return true
        }
        return false
    }

    private func updateButton() {
        if upgradeButton?.buttonImage == nil {
            upgradeButton?.buttonTitle = text
        }
    }

    private func updateMessage() {
        messageLabel?.text = msg
    }

    @IBAction func upgrade(_ sender: Any?) {
        if let url = url, let upgradeUrl = URL(string: url) {
            URLHandler.shared?.open(upgradeUrl, completionHandler: nil)
        }
    }
}
