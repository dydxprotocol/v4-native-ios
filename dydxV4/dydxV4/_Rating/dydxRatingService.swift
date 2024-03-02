//
//  dydxRatingService.swift
//  dydxV4
//
//  Created by Michael Maguire on 2/28/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import Utilities
import dydxPresenters
import RoutingKit
import dydxFormatter

class dydxPointsRating: PointsRating {    
    override func promptForRating() {
        // feature flag in case the prompt has issues
        if dydxBoolFeatureFlag.disable_app_rating.isEnabled { return }
        Tracking.shared?.log(event: "PrepromptedForRating", data: stateData)
        Router.shared?.navigate(to: RoutingRequest(path: "/rate_app"), animated: true, completion: nil)
    }
}
