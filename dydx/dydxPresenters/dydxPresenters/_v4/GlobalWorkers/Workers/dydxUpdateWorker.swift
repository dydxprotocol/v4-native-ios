//
//  dydxUpdateWorker.swift
//  dydxPresenters
//
//  Created by John Huang on 10/24/23.
//

import Abacus
import Combine
import dydxStateManager
import ParticlesKit
import RoutingKit
import Utilities

public final class dydxUpdateWorker: BaseWorker {

    public override func start() {
        super.start()

        AbacusStateManager.shared.state.environment
            .compactMap { $0 }
            .removeDuplicates()
            .sink { environment in
                Self.handle(environment: environment)
            }
            .store(in: &subscriptions)
    }

    public static func handle(environment: V4Environment?) {
        let parser = Utilities.Parser()
        if let desired = environment?.apps?.ios?.build, let mine = parser.asNumber(Bundle.main.build)?.intValue, desired > mine {
            Router.shared?.navigate(to: RoutingRequest(path: "/update"), animated: true, completion: nil)
        }
    }
}
