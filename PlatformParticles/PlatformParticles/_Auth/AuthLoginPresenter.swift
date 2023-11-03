//
//  AuthLoginPresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 9/15/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import ParticlesKit
import UIToolkits
import Utilities

public class AuthLoginPresenter: ObjectPresenter {
    @objc public dynamic var auth: AuthService? {
        didSet {
            if auth !== oldValue {
                changeObservation(from: oldValue, to: auth, keyPath: #keyPath(AuthService.provider)) { [weak self] _, _, _, _ in
                    if let self = self {
                        self.provider = self.auth?.provider
                    }
                }
            }
        }
    }

    @objc public dynamic var provider: AuthProviderProtocol? {
        didSet {
            changeObservation(from: oldValue, to: provider, keyPath: #keyPath(AuthProviderProtocol.token)) { [weak self] _, _, _, _ in
                DispatchQueue.main.async { [weak self] in
                    if let self = self {
                        self.loggedIn = (self.provider?.token != nil)
                    }
                }
            }
        }
    }

    @objc public dynamic var loggedIn: Bool = false {
        didSet {
            if loggedIn != oldValue {
                updateLoggedIn()
            } else if !updated {
                updateLoggedIn()
                updated = true
            }
        }
    }

    private var updated: Bool = false

    @IBOutlet private var view: UIView?

    private var embedded: UIView? {
        didSet {
            if embedded !== oldValue {
                oldValue?.removeFromSuperview()
                if let view = view, let embedded = embedded {
                    embedded.frame = view.bounds
                    view.addSubview(embedded)
                }
            }
        }
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        auth = AuthService.shared
    }

    private func updateLoggedIn() {
        embedded = nil
        if let xib: String = loggedIn ? provider?.logoutXib : provider?.loginXib {
            if let embedded: UIView = XibLoader.load(from: xib) {
                self.embedded = embedded
            }
        }
    }
}
