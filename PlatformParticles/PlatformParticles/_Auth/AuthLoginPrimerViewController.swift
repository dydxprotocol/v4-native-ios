//
//  AuthLoginPrimerViewController.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 9/15/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import ParticlesKit
import PlatformRouting
import RoutingKit
import UIToolkits
import Utilities

public class AuthLoginPrimerViewController: NavigableViewController {
    @IBOutlet public var presenter: AuthLoginPresenter? {
        didSet {
            changeObservation(from: oldValue, to: presenter, keyPath: #keyPath(AuthLoginPresenter.loggedIn)) { [weak self] _, _, _, _ in
                if let self = self {
                    self.loggedIn = self.presenter?.loggedIn ?? false
                }
            }
        }
    }

    public var loggedIn: Bool = false {
        didSet {
            if loggedIn != oldValue {
                if loggedIn {
                    dismiss(nil)
                }
            }
        }
    }

    private var completion: RoutingCompletionBlock?

    override public func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        if request?.path == "/login" {
            routingRequest = request
            self.completion = completion
        } else {
            completion?(nil, false)
        }
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        completion?(nil, loggedIn)
        completion = nil
    }
}
