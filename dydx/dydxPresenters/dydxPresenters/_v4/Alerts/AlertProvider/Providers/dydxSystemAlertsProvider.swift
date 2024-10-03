//
//  dydxSystemAlertsProvider.swift
//  dydxPresenters
//
//  Created by Rui Huang on 7/11/23.
//

import Foundation
import dydxStateManager
import Combine
import dydxViews
import Abacus
import Utilities
import PlatformUI
import RoutingKit

class dydxSystemAlertsProvider: dydxBaseAlertsProvider, dydxCustomAlertsProviderProtocol {
    var alertType: AlertType = .system

    private var subscriptions = Set<AnyCancellable>()

    private var hadError: Bool = false

    override init() {
        super.init()

        AbacusStateManager.shared.state.apiState
            .compactMap { $0 }
            .removeDuplicates()
            .sink { [weak self] apiState in
                if let apiAlertItem = self?.createApiStatusAlertItem(apiState: apiState) {
                    self?._items = [ apiAlertItem ]
                }
            }
            .store(in: &subscriptions)
    }

    private func createApiStatusAlertItem(apiState: ApiState) -> PlatformViewModel? {
        guard let status = apiState.status else {
            return nil
        }

        let tapAction: (() -> Void) = {
            Router.shared?.navigate(to: RoutingRequest(path: "/settings/status"), animated: true, completion: nil)
        }
        switch status {
        case .indexerDown:
            hadError = true
            return
                dydxAlertItemModel(title: DataLocalizer.localize(path: "APP.V4.INDEXER_ALERT"),
                                   message: DataLocalizer.localize(path: "APP.V4.INDEXER_DOWN"),
                                   icon: PlatformIconViewModel(type: .system(name: "exclamationmark.triangle"), templateColor: .colorRed),
                                   tapAction: tapAction)
        case .indexerHalted:
            hadError = true
            return
                dydxAlertItemModel(title: DataLocalizer.localize(path: "APP.V4.INDEXER_ALERT"),
                                   message: DataLocalizer.localize(path: "APP.V4.INDEXER_HALTED",
                                                                   params: ["HALTED_BLOCK": "\(apiState.haltedBlock?.intValue ?? 0)"]),
                                   icon: PlatformIconViewModel(type: .system(name: "exclamationmark.triangle"), templateColor: .colorYellow),
                                   tapAction: tapAction)
        case .indexerTrailing:
            hadError = true
            return
                dydxAlertItemModel(title: DataLocalizer.localize(path: "APP.V4.INDEXER_ALERT"),
                                   message: DataLocalizer.localize(path: "APP.V4.INDEXER_TRAILING",
                                                                   params: ["TRAILING_BLOCKS": "\(apiState.trailingBlocks?.intValue ?? 0)"]),
                                   icon: PlatformIconViewModel(type: .system(name: "exclamationmark.triangle"), templateColor: .colorYellow),
                                   tapAction: tapAction)
        case .validatorDown:
            hadError = true
            return
                dydxAlertItemModel(title: DataLocalizer.localize(path: "APP.V4.VALIDATOR_ALERT"),
                                   message: DataLocalizer.localize(path: "APP.V4.VALIDATOR_DOWN"),
                                   icon: PlatformIconViewModel(type: .system(name: "exclamationmark.triangle"), templateColor: .colorRed),
                                   tapAction: tapAction)
        case .validatorHalted:
            hadError = true
            return
                dydxAlertItemModel(title: DataLocalizer.localize(path: "APP.V4.VALIDATOR_ALERT"),
                                   message: DataLocalizer.localize(path: "APP.V4.VALIDATOR_HALTED",
                                                          params: ["HALTED_BLOCK": "\(apiState.haltedBlock?.intValue ?? 0)"]),
                                   icon: PlatformIconViewModel(type: .system(name: "exclamationmark.triangle"), templateColor: .colorYellow),
                                   tapAction: tapAction)
                                   case .normal:
            if hadError {
                return
                    dydxAlertItemModel(title: DataLocalizer.localize(path: "APP.V4.NETWORK_OPERATIONAL"),
                                       message: DataLocalizer.localize(path: "APP.V4.NETWORK_RECOVERED"),
                                       icon: PlatformIconViewModel(type: .system(name: "arrow.left.arrow.right"), templateColor: .colorGreen),
                                       tapAction: tapAction)
            } else {
                return nil
            }
        case .unknown:
            break
        default:
            break
        }

        return nil
    }
}
