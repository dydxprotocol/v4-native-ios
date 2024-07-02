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
    static let userDefaultsKey: String = "dydxAlertsWorker"

    // do not set directly, use `markAlertAsHandled` instead
    private var handledAlertIds = {
        if let handledAlertIds = UserDefaults.standard.array(forKey: dydxAlertsWorker.userDefaultsKey) as? [String] {
            return Set(handledAlertIds)
        } else {
            return Set<String>()
        }
    }()

    private func markAlertAsHandled(_ alert: Abacus.Notification) {
        if handledAlertIds.insert(alert.betterId).inserted {
            var handledAlerts = Array(handledAlertIds)
            handledAlerts.append(alert.betterId)
            UserDefaults.standard.set(handledAlerts, forKey: dydxAlertsWorker.userDefaultsKey)
        }
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.alerts
            .removeDuplicates()
            .sink { [weak self] alerts in
                self?.updateAlerts(alerts: alerts)
            }
            .store(in: &subscriptions)
    }

    private func updateAlerts(alerts: [Abacus.Notification]) {
        alerts
            // don't display an alert which has already been handled
            .filter { !handledAlertIds.contains($0.betterId) }
            // display alerts in chronological order they were received
            .sorted { $0.updateTimeInMilliseconds < $1.updateTimeInMilliseconds }
            .forEach { alert in
                let link = alert.link
                let actions = (link != nil) ? [ErrorAction(text: DataLocalizer.localize(path: "APP.GENERAL.VIEW")) {
                    Router.shared?.navigate(to: RoutingRequest(path: link!), animated: true, completion: nil)
                }] : nil
                if SettingsStore.shared?.shouldDisplayInAppNotifications != false {
                    DispatchQueue.main.async {
                        ErrorInfo.shared?.info(title: alert.title,
                                               message: alert.text,
                                               type: alert.type.infoType,
                                               error: nil, time: nil, actions: actions)
                    }
                }
                // add to alert ids set to avoid double handling
                markAlertAsHandled(alert)
            }
    }
}

private extension Abacus.Notification {
    // id is just the fill id which is not guaranteed unique
    var betterId: String {
        "\(self.id)\(self.updateTimeInMilliseconds)\(self.title)"
    }
}
