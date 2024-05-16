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

open class TrackingViewController: NavigableViewController, TrackingViewProtocol {
    
    open private(set) var navigationEvent: TrackableEvent?
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.setNeedsLayout()
        }
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let navigationEvent {
            Tracking.shared?.log(trackableEvent: navigationEvent)
        }
    }
}
