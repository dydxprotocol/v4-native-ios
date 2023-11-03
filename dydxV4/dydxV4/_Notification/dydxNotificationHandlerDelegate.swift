//
//  dydxNotificationHandler.swift
//  dydx
//
//  Created by Rui Huang on 7/11/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import Utilities
import FirebaseMessaging

final class dydxNotificationHandlerDelegate: NSObject, NotificationHandlerDelegate {

    private let userPermissionTag = "NotificationHandler.permission"
//
//    private let walletConnections = dydxWalletConnectionsInteractor.shared
//
//    private var walletConnectionInteractor: dydxWalletConnectionInteractor? {
//        didSet {
//            didSetWalletConnectionInteractor(oldValue: oldValue)
//        }
//    }

    private var token: String? {
        didSet {
            // sendTokenUpdate()
        }
    }

    private var permission: EPrivacyPermission? {
        didSet {
            didSetPermission()
        }
    }

    override init() {
        super.init()

//        changeObservation(from: nil, to: walletConnections, keyPath: #keyPath(dydxWalletConnectionsInteractor.current)) { [weak self] _, _, _, _ in
//            self?.walletConnectionInteractor = self?.walletConnections.current
//        }
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
                    Tracking.shared?.view("/notification/switch/denied", data: nil, from: nil, time: nil)
                }
                if lastPermission == .authorized {
                    // sendTokenDeletion()
                }
            } else if permission == .authorized {
                if lastPermission == .notDetermined || lastPermission == .denied {
                    Tracking.shared?.view("/notification/switch/authorized", data: nil, from: nil, time: nil)
                }
                // sendTokenUpdate()
            }
            UserDefaults.standard.set(permission?.rawValue, forKey: userPermissionTag)
            UserDefaults.standard.synchronize()
        }
    }

//    private func sendTokenUpdate() {
//        if let token = token, let ethereumAddress = walletConnectionInteractor?.walletConnection?.ethereumAddress,
//           permission == .authorized {
//            sendNotificationTokenUpdate(token: token, ethereumAddress: ethereumAddress)
//        }
//    }
//
//    private func sendTokenDeletion() {
//        if let token = token, let ethereumAddress = walletConnectionInteractor?.walletConnection?.ethereumAddress {
//            sendNotificationTokenDeletion(token: token, ethereumAddress: ethereumAddress)
//        }
//    }
//
//    private func didSetWalletConnectionInteractor(oldValue: dydxWalletConnectionInteractor?) {
//        // send token update or deletion when user sign-in or sign-out
//        if let token = token {
//            if let ethereumAddress = walletConnectionInteractor?.walletConnection?.ethereumAddress, permission == .authorized {
//                sendNotificationTokenUpdate(token: token, ethereumAddress: ethereumAddress)
//            } else if let ethereumAddress = oldValue?.walletConnection?.ethereumAddress {
//                sendNotificationTokenDeletion(token: token, ethereumAddress: ethereumAddress)
//            }
//        }
//    }
//
//    private var tokenApi: dydxPrivateApi?
//
//    private func sendNotificationTokenUpdate(token: String, ethereumAddress: String) {
//        if dydxBoolFeatureFlag.push_notification.isEnabled,
//           let path = dydxPrivateApi.endpointResolver.path(for: "registration-tokens") {
//            let api = dydxPrivateApi(ethereumAddress: ethereumAddress)
//            api.post(path: path, params: nil, data: ["token": token]) { [weak self] _, error in
//                if let error = error {
//                    Console.shared.log("Firebase token registration failed: \(error.localizedDescription)")
//                }
//                self?.tokenApi = nil
//            }
//            tokenApi = api
//        }
//    }
//
//    private func sendNotificationTokenDeletion(token: String, ethereumAddress: String) {
//        if dydxBoolFeatureFlag.push_notification.isEnabled,
//           let path = dydxPrivateApi.endpointResolver.path(for: "registration-tokens"),
//           let encodedToken = token.encodeBase64() {
//            let api = dydxPrivateApi(ethereumAddress: ethereumAddress)
//            api.delete(path: path + "/" + encodedToken, params: nil) { [weak self] _, error in
//                if let error = error {
//                    Console.shared.log("Firebase token deletion failed: \(error.localizedDescription)")
//                }
//                self?.tokenApi = nil
//            }
//            tokenApi = api
//        }
//    }
}
