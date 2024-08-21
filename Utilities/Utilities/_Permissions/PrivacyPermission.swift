//
//  PrivacyPermission.swift
//  Utilities
//
//  Created by Qiang Huang on 7/18/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Foundation

@objc public enum EPrivacyPermission: Int {
    case unknown = 0
    case notDetermined
    case restricted
    case denied
    case authorized
}

public typealias PermissionStatusCompletionHandler = (_ authorization: EPrivacyPermission, _ background: NSNumber?) -> Void

@objc public protocol PrivacyPermissionProtocol {
    var authorization: EPrivacyPermission { get set }
    var requestTitle: String? { get }
    var requestMessage: String? { get }

    func currentAuthorizationStatus(completion: @escaping PermissionStatusCompletionHandler)
    func promptToAuthorize()
    func promptToSettings(requestTitle: String?, requestMessage: String?, requestCTA: String, cancelTitle: String)
    func promptWithRestriction()
    func performWithAuthorization()
}

@objc open class PrivacyPermission: NSObject, PrivacyPermissionProtocol {
    open var requestTitle: String? {
        return nil
    }

    open var requestMessage: String? {
        return nil
    }

    @objc open dynamic var authorization: EPrivacyPermission = .unknown {
        didSet {
            if authorization != oldValue {
                switch authorization {
                case .notDetermined:
//                    promptToAuthorize()
                    break

                case .denied:
//                    promptToSettings()
                    break

                case .restricted:
//                    promptWithRestriction()
                    break

                case .authorized:
//                    performWithAuthorization()
                    break

                default:
                    break
                }
            }
        }
    }

    @objc open dynamic var background: NSNumber?

    private var foregroundToken: NotificationToken?

    override public init() {
        super.init()
        DispatchQueue.main.async { [weak self] in
            self?.refreshStatus()
        }

        foregroundToken = NotificationCenter.default.observe(notification: UIApplication.willEnterForegroundNotification, do: { [weak self] _ in
            if let self = self {
                self.refreshStatus()
            }
        })
    }

    open func refreshStatus() {
        currentAuthorizationStatus { [weak self] authorization, background in
            if let self = self {
                DispatchQueue.main.async { [weak self] in
                    if let self = self {
                        if self.authorization != authorization {
                            self.authorization = authorization
                        }
                        if self.background != background {
                            self.background = background
                        }
                    }
                }
            }
        }
    }

    open func currentAuthorizationStatus(completion: @escaping PermissionStatusCompletionHandler) {
        completion(.notDetermined, nil)
    }

    open func promptToAuthorize() {
    }

    open func promptWithRestriction() {
    }

    open func promptToSettings(requestTitle: String? = nil, requestMessage: String? = nil, requestCTA: String = "Settings", cancelTitle: String = "Cancel") {
        if let prompter = PrompterFactory.shared?.prompter() {
            prompter.title = requestTitle ?? self.requestTitle
            prompter.message = requestMessage ?? self.requestMessage
            prompter.style = .selection
            let cancel = PrompterAction.cancel()
            let settings = PrompterAction(title: requestCTA) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    URLHandler.shared?.open(url, completionHandler: nil)
                }
            }
            prompter.prompt([cancel, settings])
        }
    }

    open func performWithAuthorization() {
    }
}
