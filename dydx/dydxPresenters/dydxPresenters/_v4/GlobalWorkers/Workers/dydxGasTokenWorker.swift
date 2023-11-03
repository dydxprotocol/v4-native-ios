//
//  dydxGasTokenWorker.swift
//  dydxPresenters
//
//  Created by Rui Huang on 10/06/2024.
//

import Abacus
import Combine
import dydxStateManager
import ParticlesKit
import RoutingKit
import Utilities

public final class dydxGasTokenWorker: BaseWorker {

    public override func start() {
        super.start()

        // set the gas token to the user preference
        if let tokenName = SettingsStore.shared?.gasToken,
            let token = GasToken.from(tokenName: tokenName) {
            AbacusStateManager.shared.setGasToken(token: token)
        }
    }
}
