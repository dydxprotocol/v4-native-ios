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
    public var trackingData: TrackingData?
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.setNeedsLayout()
        }
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        logView(path: history?.path, data: history?.params, from: nil, time: nil)
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Tracking.shared?.leave(trackingData?.path)
        trackingData = nil
    }

    open func logView(path: String?, data: [String: Any]?, from: String?, time: Date?) {
        if let path = path, trackingData?.path != path {
            trackingData = TrackingData(path: path, data: data)
            Tracking.shared?.view(path, data: data, from: from, time: time)
        }
    }
}
