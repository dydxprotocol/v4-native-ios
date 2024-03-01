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

class dydxPointsRating: PointsRating {
    override func tryPromptForRating() {
        if shouldStopPrompting {
            return
        }
        super.tryPromptForRating()
    }
    
    override func promptForRating() {
        Router.shared?.navigate(to: RoutingRequest(path: "/rate_app"), animated: true, completion: nil)
    }
}
