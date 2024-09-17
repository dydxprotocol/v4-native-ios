//
//  dydxGlobalWorkers.swift
//  dydxPresenters
//
//  Created by Rui Huang on 10/12/23.
//

import Foundation
import ParticlesKit
import Utilities

public final class dydxGlobalWorkers: BaseWorker {
    private let globalWorkers: [WorkerProtocol] = [
        dydxAlertsWorker(),
        dydxApiStatusWorker(),
        dydxTransferSubaccountWorker(),
        dydxRestrictionsWorker(),
        dydxCarteraConfigWorker(),
        dydxUpdateWorker(),
        dydxRatingsWorker(),
        dydxGasTokenWorker(),
        dydxPushNotificationToggleWorker()
    ]

    override public func start() {
        super.start()

        globalWorkers.forEach { $0.start() }
    }

    override public func stop() {
        super.stop()

        globalWorkers.forEach { $0.stop() }
    }
}
