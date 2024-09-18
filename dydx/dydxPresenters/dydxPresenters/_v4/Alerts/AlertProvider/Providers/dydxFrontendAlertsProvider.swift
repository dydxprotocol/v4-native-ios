//
//  dydxFrontendAlertsProvider.swift
//  dydxPresenters
//
//  Created by John Huang on 8/30/23.
//

import Abacus
import Combine
import dydxStateManager
import dydxViews
import Foundation
import PlatformUI
import RoutingKit
import Utilities

class dydxFrontendAlertsProvider: dydxBaseAlertsProvider, dydxCustomAlertsProviderProtocol {
    var alertType: AlertType = .frontend
    private var subscriptions = Set<AnyCancellable>()

    override init() {
        super.init()

        AbacusStateManager.shared.state.alerts
            .compactMap { $0 }
            .removeDuplicates()
            .sink { [weak self] alerts in
                if let items = self?.createAlertItems(alerts: alerts) {
                    self?._items = items
                }
            }
            .store(in: &subscriptions)
    }

    private func createAlertItems(alerts: [Abacus.Notification]?) -> [PlatformViewModel]? {
        guard let alerts = alerts else {
            return nil
        }

        var items = [PlatformViewModel]()
        for alert in alerts {
            items.append(createAlertItem(alert: alert))
        }
        return items
    }

    private func createAlertItem(alert: Abacus.Notification) -> PlatformViewModel {
        let tapAction: (() -> Void) = {
            if let link = alert.link {
                Router.shared?.navigate(to: RoutingRequest(path: link), animated: true, completion: nil)
            }
        }
        let url = (alert.image != nil) ? URL(string: alert.image!) : nil
        return dydxAlertItemModel(title: alert.title, message: alert.text,
                                  icon: PlatformIconViewModel(type: .url(url: url)),
                                  tapAction: tapAction)
    }
}
