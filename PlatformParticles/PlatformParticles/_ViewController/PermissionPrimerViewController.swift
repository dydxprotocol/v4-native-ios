//
//  PrivacyAuthorizationViewController.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 9/1/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import RoutingKit
import UIToolkits
import Utilities

open class PermissionPrimerViewController: TrackingViewController {
    @IBInspectable var path: String?
    @IBInspectable var hideNavBar: Bool = false
    @IBOutlet var presenter: PrivacyPermissionPresenter?

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if hideNavBar {
            navigationController?.navigationBar.transparent = true
        }
    }

    open override func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        return request?.path == path
    }
}
