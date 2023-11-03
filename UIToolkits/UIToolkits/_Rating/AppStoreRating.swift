//
//  AppStoreRating.swift
//  UIAppToolkits
//
//  Created by Qiang Huang on 9/19/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import StoreKit
import UIKit
import Utilities

public class AppStoreRating: PointsRating {
    override public func promptForRating() {
        #if DEBUG
        #else
            SKStoreReviewController.requestReview()
        #endif
    }
}
