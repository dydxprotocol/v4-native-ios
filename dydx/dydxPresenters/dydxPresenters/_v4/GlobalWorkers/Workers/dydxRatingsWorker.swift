//
//  dydxRatingsWorker.swift
//  dydxPresenters
//
//  Created by Michael Maguire on 2/28/24.
//

import Abacus
import Combine
import dydxStateManager
import ParticlesKit
import RoutingKit
import Utilities

public final class dydxRatingsWorker: BaseWorker {

    public override func start() {
        super.start()

        AbacusStateManager.shared.state.currentWallet
            .compactMap { $0 }
            .removeDuplicates()
            .sink { _ in
                RatingService.shared?.connectedWallet()
            }
            .store(in: &self.subscriptions)

        AbacusStateManager.shared.state.account
            .compactMap { $0 }
            .removeDuplicates()
            .sink { account in
                let x = account.balances
                RatingService.shared?.portfolioCrossedPositiveFivePercent()
            }
            .store(in: &self.subscriptions)

        AbacusStateManager.shared.state.lastOrder
            .compactMap { $0 }
            .removeDuplicates()
            .sink { _ in
                RatingService.shared?.orderCreated()
            }
            .store(in: &self.subscriptions)

        NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)
            .compactMap { $0 }
            .removeDuplicates()
            .sink { _ in
                RatingService.shared?.capturedScreenshotOrShare()
            }
            .store(in: &self.subscriptions)

    }
}
