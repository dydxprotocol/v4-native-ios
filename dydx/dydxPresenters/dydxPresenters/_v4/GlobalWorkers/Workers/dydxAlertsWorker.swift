//
//  dydxAlertsWorker.swift
//  dydxPresenters
//
//  Created by John Huang on 8/31/23.
//

import Abacus
import Combine
import dydxStateManager
import Foundation
import ParticlesKit
import RoutingKit
import Utilities

extension Abacus.NotificationType {
    var infoType: EInfoType {
        switch self {
        case .info:
            return EInfoType.info

        case .error:
            return EInfoType.error

        case .warning:
            return EInfoType.warning

        default:
            return EInfoType.info
        }
    }
}

final class dydxAlertsWorker: BaseWorker {
    private var handledAlertHashes = Set<Int>()

    override func start() {
        super.start()

        AbacusStateManager.shared.state.alerts
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] alerts in
                self?.updateAlerts(alerts: alerts)
            }
            .store(in: &subscriptions)
    }

    private func updateAlerts(alerts: [Abacus.Notification]) {
        alerts
            // don't display an alert which has already been handled
            .filter { !handledAlertHashes.contains($0.hashValue) }
            // display alerts in chronological order they were received
            .sorted { $0.updateTimeInMilliseconds < $1.updateTimeInMilliseconds }
            .forEach { alert in
                let link = alert.link
                let actions = (link != nil) ? [ErrorAction(text: DataLocalizer.localize(path: "APP.GENERAL.VIEW")) {
                    Router.shared?.navigate(to: RoutingRequest(path: link!), animated: true, completion: nil)
                }] : nil
                if SettingsStore.shared?.shouldDisplayInAppNotifications ?? true {
                    ErrorInfo.shared?.info(title: alert.title,
                                           message: alert.text,
                                           type: alert.type.infoType,
                                           error: nil, time: 3.0, actions: actions)
                }
                // add to alert ids set to avoid double handling
                handledAlertHashes.insert(alert.hashValue)
            }
    }
}
