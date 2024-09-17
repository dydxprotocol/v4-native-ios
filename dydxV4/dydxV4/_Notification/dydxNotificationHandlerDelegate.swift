//
//  dydxNotificationHandler.swift
//  dydx
//
//  Created by Rui Huang on 7/11/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import Utilities
import FirebaseMessaging
import dydxAnalytics
import dydxStateManager
import Combine

final class dydxNotificationHandlerDelegate: NSObject, NotificationHandlerDelegate {

    private let userPermissionTag = "NotificationHandler.permission"
    private var subscriptions = Set<AnyCancellable>()

    private var token: String? {
        didSet {
            sendTokenUpdate()
        }
    }
    
    private var languageCode: String? {
        didSet {
            sendTokenUpdate()
        }
    }
    
    private var permission: EPrivacyPermission? {
        didSet {
            didSetPermission()
        }
    }

    override init() {
        super.init()
        
        DataLocalizer.shared?.languagePublisher
            .sink { [weak self] languageCode in
                self?.languageCode = languageCode
            }
            .store(in: &subscriptions)
    }

    // MARK: NotificationHandlerDelegate

    func didReceiveToken(token: String?) {
        if token != self.token {
            self.token = token
        }
    }

    func didReceivePermission(permission: EPrivacyPermission) {
        if permission != self.permission {
            self.permission = permission
        }
    }

    // MARK: Private

    private func didSetPermission() {
        let lastPermission = EPrivacyPermission(rawValue: UserDefaults.standard.integer(forKey: userPermissionTag))
        if lastPermission != permission {
            if permission == .denied {
                if lastPermission == .notDetermined || lastPermission == .authorized {
                    Tracking.shared?.log(event: AnalyticsEventV2.NotificationPermissionsChanged(isAuthorized: false))
                }
                if lastPermission == .authorized {
                    sendTokenDeletion()
                }
            } else if permission == .authorized {
                if lastPermission == .notDetermined || lastPermission == .denied {
                    Tracking.shared?.log(event: AnalyticsEventV2.NotificationPermissionsChanged(isAuthorized: true))
                }
                sendTokenUpdate()
            }
            UserDefaults.standard.set(permission?.rawValue, forKey: userPermissionTag)
            UserDefaults.standard.synchronize()
        } else if (permission == .authorized) {
            sendTokenUpdate()
        }
    }

    private func sendTokenUpdate() {
        if let token = token, permission == .authorized {
            AbacusStateManager.shared.registerPushNotification(token: token, languageCode: languageCode)
        }
    }

    private func sendTokenDeletion() {
        if let token = token {
            // Not supported yet
        }
    }
}
