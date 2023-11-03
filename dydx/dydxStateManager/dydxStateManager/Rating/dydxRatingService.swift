//
//  RatingService.swift
//  Utilities
//
//  Created by Qiang Huang on 9/19/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation
import Utilities

public protocol dydxRatingProtocol {
    var stateData: [String: Any] { get }

    func connectedWallet()
    func launchedApp()
    func orderCreated(orderId: String, orderCreatedTimestampMillis: TimeInterval)
    func transferCreated(transferId: String, transferCreatedTimestampMillis: TimeInterval)
    func capturedScreenshotOrShare()
    func disablePreprompting()

    func promptForRating()
    func tryPromptForRating()
}

public class dydxRatingService {
    public static var shared: dydxRatingProtocol?
}
