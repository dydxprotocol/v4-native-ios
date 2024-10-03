//
//  TrackingViewController.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 12/20/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit
import PlatformRouting
import UIToolkits
import Utilities

open class TrackingViewController: NavigableViewController {

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.setNeedsLayout()
        }
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Tracking.shared?.leave(history?.path)
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let self = self as? TrackingViewProtocol {
            self.logScreenView()
        }
    }
}
