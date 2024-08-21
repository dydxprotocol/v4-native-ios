//
//  PrivacyPermissionPresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 7/17/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import UIToolkits
import Utilities

open class PrivacyPermissionPresenter: NSObject {
    @IBOutlet var view: UIView? {
        didSet {
            if view !== oldValue {
                view?.bringToFront()
                updateAuthorization()
            }
        }
    }

    @IBOutlet var title: UILabel? {
        didSet {
            if title !== oldValue {
                updateAuthorization()
            }
        }
    }

    @IBOutlet var detail: UILabel? {
        didSet {
            if detail !== oldValue {
                updateAuthorization()
            }
        }
    }

    @IBOutlet var button: UIButton? {
        didSet {
            if button !== oldValue {
                oldValue?.removeTarget()
                button?.addTarget(self, action: #selector(authorize(_:)))
                updateAuthorization()
            }
        }
    }

    @IBOutlet public var authorization: PrivacyPermission? {
        didSet {
            changeObservation(from: oldValue, to: authorization, keyPath: #keyPath(PrivacyPermission.authorization)) { [weak self] _, _, _, _ in
                self?.updateAuthorization()
            }
        }
    }

    open func updateAuthorization() {
        switch authorization?.authorization {
        case .authorized?:
            view?.isHidden = true

        default:
            title?.text = authorization?.requestTitle
            detail?.text = authorization?.requestMessage
            button?.buttonTitle = (authorization?.authorization == .notDetermined) ? "Permit" : "Go to Settings"
            view?.isHidden = false
        }
    }

    @IBAction func authorize(_ sender: Any?) {
        UIViewController.topmost()?.dismiss(sender)
        if authorization?.authorization == .notDetermined {
            authorization?.promptToAuthorize()
        } else {
            authorization?.promptToSettings()
        }
    }
}
