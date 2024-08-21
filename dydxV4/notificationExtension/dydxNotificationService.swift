//
//  NotificationService.swift
//  NotificationExtension
//
//  Created by Rui Huang on 6/14/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import UserNotifications
import FirebaseMessaging

class dydxNotificationService: UNNotificationServiceExtension, URLSessionDelegate {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        Messaging.serviceExtension().exportDeliveryMetricsToBigQuery(withMessageInfo: request.content.userInfo)

        if let bestAttemptContent = bestAttemptContent {
            Messaging.serviceExtension().populateNotificationContent(bestAttemptContent, withContentHandler: contentHandler)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
