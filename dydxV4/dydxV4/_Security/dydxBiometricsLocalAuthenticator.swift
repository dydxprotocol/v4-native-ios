//
//  dydxBiometricsLocalAuthenticator.swift
//  dydxPlatformParticles
//
//  Created by John Huang on 3/16/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import PlatformParticles
import RoutingKit
import Utilities

public class dydxBiometricsLocalAuthenticator: TimedLocalAuthenticator {
    override public func trigger() {
        if !UIDevice.current.isSimulator {
//            if dydxWalletConnectionsInteractor.shared.current !== nil {
//                Router.shared?.navigate(to: RoutingRequest(path: "/security"), animated: true, completion: nil)
//            }
        }
    }
}
