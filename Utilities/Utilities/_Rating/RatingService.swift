//
//  RatingService.swift
//  Utilities
//
//  Created by Qiang Huang on 9/19/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

public protocol RatingProtocol: NSObjectProtocol {
    func connectedWallet()
    func launchedApp()
    func orderCreated(orderId: String, orderCreatedTimestampMillis: TimeInterval)
    func transferCreated(transferId: String, transferCreatedTimestampMillis: TimeInterval)
    func capturedScreenshotOrShare()
    func disablePrompting()
    
    func promptForRating()
    func tryPromptForRating()
}

public class RatingService {
    public static var shared: RatingProtocol?
}
