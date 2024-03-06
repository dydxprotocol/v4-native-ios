//
//  dydxAmplitudeTracking.swift
//  dydx
//
//  Created by John Huang on 4/26/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import AmplitudeInjections
import UIKit

public class dydxAmplitudeTracking: AmplitudeTracking {
    override open func view(_ path: String?, action: String?, data: [String: Any]?, from: String?, time: Date?, revenue: NSNumber?, contextViewController: UIViewController?) {
        // Only track the ones required by growth
    }

    override open func log(event: String, data: [String: Any]?, revenue: NSNumber?) {
        if event.first?.isUppercase ?? false {
            super.log(event: event, data: data, revenue: nil)
        }
    }

    override open func leave(_ path: String?) {
    }
}
