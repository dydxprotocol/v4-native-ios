//
//  NotificationService.swift
//  Utilities
//
//  Created by Qiang Huang on 7/18/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Foundation

public class FirebaseNotificationConfiguration: NSObject {
    public let subscribedTopics: Set<String>

    public init(subscribedTopics: Set<String> = []) {
        self.subscribedTopics = subscribedTopics
    }

    public override func isEqual(_ object: Any?) -> Bool {
        let other = object as? FirebaseNotificationConfiguration
        return subscribedTopics == other?.subscribedTopics
    }
}

public class NotificationConfiguration: NSObject {
    public let firebase: FirebaseNotificationConfiguration?

    public init(firebase: FirebaseNotificationConfiguration?) {
        self.firebase = firebase
    }

    public override func isEqual(_ object: Any?) -> Bool {
        let other = object as? NotificationConfiguration
        return firebase == other?.firebase
    }
}

@objc public protocol NotificationHandlerDelegate {
    func didReceiveToken(token: String?)
    func didReceivePermission(permission: EPrivacyPermission)
}

@objc public protocol NotificationHandlerProtocol: NSObjectProtocol {
    @objc var authorization: NotificationPermission? { get set }
    @objc var configuration: NotificationConfiguration? { get set }
    @objc var permission: EPrivacyPermission { get set }
    @objc var delegate: NotificationHandlerDelegate? { get set }

    func request()
    func present(message: [AnyHashable: Any])
    func receive(message: [AnyHashable: Any]) -> Bool
}

public class NotificationService: NSObject {
    public static var shared: NotificationHandlerProtocol? {
        didSet {
            shared?.authorization = NotificationPermission.shared
        }
    }
}

@objc open class NotificationHandler: NSObject, NotificationHandlerProtocol {

    public var delegate: NotificationHandlerDelegate?

    @objc open dynamic var authorization: NotificationPermission? {
        didSet {
            changeObservation(from: oldValue, to: authorization, keyPath: #keyPath(PrivacyPermission.authorization)) { [weak self] _, _, _, _ in
                if let self = self {
                    if let permission = self.authorization?.authorization {
                        self.permission = permission
                    }
                }
            }
        }
    }

    @objc open dynamic var configuration: NotificationConfiguration? {
        didSet {
            didSetConfiguration(oldValue: oldValue)
        }
    }

    @objc open dynamic var permission: EPrivacyPermission = .notDetermined {
        didSet {
            if permission != oldValue {
                switch permission {
                case .authorized:
                    request()

                default:
                    break
                }
                delegate?.didReceivePermission(permission: permission)
            }
        }
    }

    @objc open dynamic var token: String? {
        didSet {
            if token != oldValue {
                delegate?.didReceiveToken(token: token)
            }
        }
    }

    open func request() {
    }

    open func present(message: [AnyHashable: Any]) {
    }

    open func receive(message: [AnyHashable: Any]) -> Bool {
        return false
    }

    open func didSetConfiguration(oldValue: NotificationConfiguration?) {
    }
}

open class NotificationUserAssociation: NSObject, AuthProviderAttachmentProtocol {
    public static var shared: NotificationUserAssociation?

    private let userIdentifierTag = "NotificationHandler.userIdentifier"
    private let deviceTokenTag = "NotificationHandler.deviceToken.2"

    @objc open dynamic var userIdentifier: String? {
        didSet {
            if userIdentifier != oldValue {
                dissociate(deviceToken: deviceToken, from: oldValue, userChanged: true)
                associate(deviceToken: deviceToken, with: userIdentifier)
                UserDefaults.standard.set(userIdentifier, forKey: userIdentifierTag)
            }
        }
    }

    @objc open dynamic var deviceToken: String? {
        didSet {
            if deviceToken != oldValue {
                dissociate(deviceToken: oldValue, from: userIdentifier, userChanged: false)
                associate(deviceToken: deviceToken, with: userIdentifier)
                UserDefaults.standard.set(deviceToken, forKey: deviceTokenTag)
            }
        }
    }

    override public init() {
        super.init()
        userIdentifier = UserDefaults.standard.string(forKey: userIdentifierTag)?.trim()
        deviceToken = UserDefaults.standard.string(forKey: deviceTokenTag)?.trim()
    }

    open func dissociate(deviceToken: String?, from userIdentifier: String?, userChanged: Bool) {
        if !userChanged {
            reallyDisassociate(deviceToken: deviceToken, from: userIdentifier, completion: nil)
        }
    }

    private var associateDebouncer: Debouncer = Debouncer()

    open func associate(deviceToken: String?, with userIdentifier: String?) {
        let handler = associateDebouncer.debounce()
        handler?.run({ [weak self] in
            self?.reallyAssociate(deviceToken: deviceToken, with: userIdentifier)
        }, delay: 0.1)
    }

    open func reallyAssociate(deviceToken: String?, with userIdentifier: String?) {
        if let deviceToken = deviceToken, let userIdentifier = userIdentifier {
            Console.shared.log("associate \(deviceToken) with user \(userIdentifier)")
        }
    }

    open func beforeLogin(completion: @escaping AuthAttachmentCompletionBlock) {
        completion(true)
    }

    open func afterLogin() {
        associate(deviceToken: deviceToken, with: userIdentifier)
    }

    open func beforeLogout(token: String, completion: @escaping AuthAttachmentCompletionBlock) {
        completion(true)
        reallyDisassociate(deviceToken: deviceToken, from: token, completion: completion)
    }

    open func afterLogout() {
    }

    open func reallyDisassociate(deviceToken: String?, from userIndentifier: String?, completion: AuthAttachmentCompletionBlock?) {
        if let deviceToken = deviceToken, let userIdentifier = userIdentifier {
            Console.shared.log("dissociate \(deviceToken) from user \(userIdentifier)")
        }
        completion?(true)
    }
}
