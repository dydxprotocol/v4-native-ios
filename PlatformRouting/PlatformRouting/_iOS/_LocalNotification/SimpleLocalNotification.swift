//
//  SimpleLocalNotification.swift
//  RoutingKit
//
//  Created by Qiang Huang on 11/4/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import RoutingKit
import UIKit
import Utilities
import Combine

public class SimpleLocalNotification: NSObject, LocalNotificationProtocol, CombineObserving {
    public var cancellableMap = [AnyKeyPath : AnyCancellable]()
    
    private var appState: AppState? {
        didSet {
            changeObservation(from: oldValue, to: appState, keyPath: #keyPath(AppState.background)) { [weak self] _, _, _, animated in
                self?.backgrounded = self?.appState?.background ?? false
            }
        }
    }
    private var backgroundId: String?

    private var outstandingIds: [String]?
    
    private let handler = SimpleLocalNotificationHandler()

    public var background: LocalNotificationMessage? {
        didSet {
            if background !== oldValue {
                if let backgroundId = backgroundId {
                    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [backgroundId])
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [backgroundId])
                }
                if backgrounded {
                    backgroundId = sending(message: background)
                }
            }
        }
    }

    public var backgrounded: Bool = false {
        didSet {
            if backgrounded != oldValue {
                if backgrounded {
                    sendBackgrounding()
                } else {
                    removeBackgrounding()
                }
            }
        }
    }
    
    public override init() {
        super.init()
        DispatchQueue.main.async {[weak self] in
            self?.appState = AppState.shared
        }
    }

    public func sending(message: LocalNotificationMessage?) -> String? {
        if let message = message {
            let content = UNMutableNotificationContent()
            content.title = message.title

            if let subtitle = message.subtitle {
                content.subtitle = subtitle
            }
            if let text = message.text {
                content.body = text
            }
            if let link = message.link {
                content.userInfo = ["data": ["firebase": ["link": link]]]
            }
            content.sound = UNNotificationSound.default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: message.delay ?? 0.5, repeats: false)

            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [UNAuthorizationOptions.alert]) { success, error in
                if success {
                    UNUserNotificationCenter.current().delegate = self.handler
                    center.add(request) { error in
                        if error != nil {
                            print("error \(String(describing: error))")
                        }
                    }
                }
            }
            return uuidString
        }
        return nil
    }

    public func send(message: LocalNotificationMessage) {
        if let identifier = sending(message: message) {
            if outstandingIds == nil {
                outstandingIds = [String]()
            }
            outstandingIds?.append(identifier)
        }
    }

    private func sendBackgrounding() {
        backgroundId = sending(message: background)
    }

    private func removeBackgrounding() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        backgroundId = nil
        outstandingIds = nil
    }
}

extension SimpleLocalNotification: NotificationBridgeProtocol {
    public func launched() {
    }

    public func registered(deviceToken: Data) {
    }

    public func failed(error: Error) {
    }

    public func received(userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let routing = userInfo["routing"] as? String {
            Router.shared?.navigate(to: RoutingRequest(url: routing), animated: true, completion: nil)
            completionHandler(.newData)
        } else {
            completionHandler(.noData)
        }
    }
    
    public func receivedDeeplink(userInfo: [AnyHashable : Any]) -> URL? {
        if let routing = userInfo["routing"] as? String {
            return RoutingRequest(url: routing).url
        }
        return nil
    }
}

public class SimpleLocalNotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        ErrorInfo.shared?.info(title: notification.request.content.title, message: notification.request.content.body, type: EInfoType.info, error: nil)
        completionHandler([])
    }
}
