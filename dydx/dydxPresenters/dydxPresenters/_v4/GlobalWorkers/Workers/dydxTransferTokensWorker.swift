//
//  dydxTransferTokensWorker.swift
//  dydxPresenters
//
//  Created by Rui Huang on 23/02/2025.
//

import Foundation
import Combine
import dydxStateManager
import ParticlesKit
import RoutingKit
import Utilities
import dydxAnalytics

public final class dydxTransferTokensWorker: BaseWorker {

    private let transferTokenDetails: TransferTokenDetails?

    public override init() {
        transferTokenDetails = TransferTokenDetails.create(isMainnet: AbacusStateManager.shared.isMainNet)

        super.init()
    }

    public override func start() {
        super.start()

        for token in transferTokenDetails?.infos ?? [] {
            loadTokenInfo(info: token)
        }
    }

    private func loadTokenInfo(info: TransferTokenInfo) {

    }
}
