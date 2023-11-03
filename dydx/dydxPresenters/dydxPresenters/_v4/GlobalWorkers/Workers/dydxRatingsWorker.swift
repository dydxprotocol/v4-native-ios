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
                dydxRatingService.shared?.connectedWallet()
            }
            .store(in: &self.subscriptions)

        AbacusStateManager.shared.state.transfers
            .compactMap { $0 }
            .removeDuplicates()
            .sink { transfers in
                for transfer in transfers {
                    dydxRatingService.shared?.transferCreated(transferId: transfer.id, transferCreatedTimestampMillis: transfer.updatedAtMilliseconds)
                }
            }
            .store(in: &self.subscriptions)

        AbacusStateManager.shared.state.selectedSubaccountFills
            .sink { fills in
                for fill in fills {
                    guard let orderId = fill.orderId else { return }
                    dydxRatingService.shared?.orderCreated(orderId: orderId, orderCreatedTimestampMillis: fill.createdAtMilliseconds)
                }
            }
            .store(in: &self.subscriptions)

        NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)
            .compactMap { $0 }
            .sink { _ in
                dydxRatingService.shared?.capturedScreenshotOrShare()
            }
            .store(in: &self.subscriptions)

    }
}
