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

    override open func log(event: String, data: [String: Any]?, revenue: NSNumber?) {
        if event.first?.isUppercase ?? false {
            super.log(event: event, data: data, revenue: nil)
        }
    }

    override open func leave(_ path: String?) {
    }
}
