//
//  FirebaseNotification.swift
//  FirebaseInjections
//
//  Created by John Huang on 12/31/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import FirebaseMessaging
import PlatformRouting
import RoutingKit
import UserNotifications
import Utilities

public class FirebaseNotificationHandler: NotificationHandler {
    public let tag: String

    override public var permission: EPrivacyPermission {
        didSet {
            if permission != oldValue {
                updateAssociation()
            }
        }
    }

    override public var token: String? {
        didSet {
            if token != oldValue {
                updateAssociation()
                if let token = token {
                    NSLog("Firebase registration token: \(token)")
                }
                switch Installation.source {
                case .debug, .testFlight:
                    DebugSettings.shared?.debug?["push_token"] = token
                case .appStore, .jailBroken:
                    break
                }
            }
        }
    }

    public init(tag: String) {
        self.tag = tag
        super.init()

        _ = FirebaseRunner.shared
        Messaging.messaging().delegate = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.token = Messaging.messaging().fcmToken
        }
    }

    override public func request() {
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        UIApplication.shared.registerForRemoteNotifications()
    }

    func updateAssociation() {
        if authorization != nil {
            switch permission {
            case .authorized:
                NotificationUserAssociation.shared?.deviceToken = token
            default:
                NotificationUserAssociation.shared?.deviceToken = nil
            }
        }
    }

    override public func present(message: [AnyHashable: Any]) {
        if let aps = message["aps"] as? [String: Any], let alert = aps["alert"] as? [String: Any] {
            let title = parser.asString(alert["title"])
            let text = parser.asString(alert["body"])
            var actions: [ErrorAction]?
            if let _ = link(message: message) {
                let action = ErrorAction(text: DataLocalizer.localize(path: "APP.GENERAL.GO", params: nil)) {
                    _ = self.receive(message: message)
                }
                actions = [action]
            }
            if let actions = actions {
                ErrorInfo.shared?.info(title: title, message: text, type: .info, error: nil, actions: actions)
            } else {
                ErrorInfo.shared?.info(title: title, message: text, type: .info, error: nil)
            }
        }
    }

    override public func receive(message: [AnyHashable: Any]) -> Bool {
        if let link = link(message: message) {
            Router.shared?.navigate(to: URL(string: link), completion: nil)
            return true
        }
        return false
    }

    override public func didSetConfiguration(oldValue: NotificationConfiguration?) {
        if configuration != oldValue {
            updateConfiguration(previous: oldValue?.firebase, current: configuration?.firebase)
        }
    }

    private func link(message: [AnyHashable: Any]) -> String? {
        if let data = parser.asDictionary(message["data"]), let custom = parser.asDictionary(data[tag]) {
            return parser.asString(custom["link"])
        }
        return nil
    }

    fileprivate func updateConfiguration(previous: FirebaseNotificationConfiguration?, current: FirebaseNotificationConfiguration?) {
        let previousTopics = previous?.subscribedTopics ?? []
        let currentTopics = current?.subscribedTopics ?? []

        let newTopics = currentTopics.subtracting(previousTopics)
        for topic in newTopics {
            Messaging.messaging().subscribe(toTopic: topic) { error in
                if let error = error {
                    Console.shared.log("Firebase topic subscription failed: \(String(describing: error))")
                }
            }
        }

        let deletedTopics = previousTopics.subtracting(currentTopics)
        for topic in deletedTopics {
            Messaging.messaging().unsubscribe(fromTopic: topic) { error in
                if let error = error {
                    Console.shared.log("Firebase topic unsubscription failed: \(String(describing: error))")
                }
            }
        }
    }
}

extension FirebaseNotificationHandler: MessagingDelegate {
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let fcmToken = fcmToken {
            Console.shared.log("Firebase registration token: \(fcmToken)")

            token = fcmToken

            let dataDict: [String: String] = ["token": fcmToken]
            NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)

            // TODO: If necessary send token to application server.
            // Note: This callback is fired at each app startup and whenever a new token is generated.

            #if DEBUG
//                InstanceID.instanceID().instanceID { result, error in
//                    if let error = error {
//                        Console.shared.log("Error fetching remote instance ID: \(error)")
//                    } else if let result = result {
//                        Console.shared.log("Remote instance ID token: \(result.token)")
//                    }
//                    let apns = Messaging.messaging().apnsToken
//                    if let apns = apns {
//                        let string = String(data: apns, encoding: .utf16)
//                        Console.shared.log("ASPN token: \(String(describing: string))")
//                    }
//                }
            #endif
        }
    }

//    public func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
//        Console.shared.log("Received data message: \(remoteMessage.appData)")
//    }
}

extension FirebaseNotificationHandler: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        present(message: userInfo)
        completionHandler([])
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        _ = receive(message: userInfo)
        completionHandler()
    }
}

extension FirebaseNotificationHandler: NotificationBridgeProtocol {
    public func launched() {
    }

    public func registered(deviceToken: Data) {
    }

    public func failed(error: Error) {
    }

    public func received(userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Messaging.serviceExtension().exportDeliveryMetricsToBigQuery(withMessageInfo: userInfo)
        if receive(message: userInfo) {
            completionHandler(.newData)
        } else {
            completionHandler(.noData)
        }
    }

    public func receivedDeeplink(userInfo: [AnyHashable: Any]) -> URL? {
        if let link = link(message: userInfo) {
            return URL(string: link)
        }
        return nil
    }
}
