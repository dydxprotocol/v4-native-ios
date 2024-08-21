//
//  PrivacyAuthorizationAction.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 8/5/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import RoutingKit
import Utilities

open class PrivacyPermissionAction: NSObject, NavigableProtocol {
    @IBInspectable public var required: Bool = false
    public var primer: String? {
        return nil
    }

    private var completion: RoutingCompletionBlock?
    private var pending: PrivacyPermission? {
        didSet {
            changeObservation(from: oldValue, to: pending, keyPath: #keyPath(PrivacyPermission.authorization)) { [weak self] _, _, _, _ in
                if let self = self {
                    switch self.pending?.authorization {
                    case .unknown:
                        break

                    case .notDetermined:
                        if let primer = self.primer {
                            Router.shared?.navigate(to: RoutingRequest(path: primer, params: nil), animated: true, completion: nil)
                        } else {
                            self.pending?.promptToAuthorize()
                        }

                    case .restricted:
                        if self.required {
                            self.completion?(nil, false)
                            self.completion = nil
                            if let primer = self.primer {
                                Router.shared?.navigate(to: RoutingRequest(path: primer, params: nil), animated: true, completion: nil)
                            } else {
                                self.pending?.promptWithRestriction()
                            }
                        } else {
                            self.completion?(nil, false)
                            self.completion = nil
                        }

                    case .authorized:
                        self.completion?(nil, true)
                        self.completion = nil

                    default:
                        if self.required {
                            self.completion?(nil, false)
                            self.completion = nil
                            if let primer = self.primer {
                                Router.shared?.navigate(to: RoutingRequest(path: primer, params: nil), animated: true, completion: nil)
                            } else {
                                self.pending?.promptToSettings()
                            }
                        } else {
                            self.completion?(nil, false)
                            self.completion = nil
                        }
                    }
                }
            }
        }
    }

    open var path: String? {
        return nil
    }

    open func authorization() -> PrivacyPermission? {
        return nil
    }

    open func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        if request?.path == path, let authorization = authorization() {
            self.completion = completion
            pending = authorization
        } else {
            completion?(nil, false)
        }
    }
}
