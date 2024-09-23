//
//  dydxTransferAlertsProvider.swift
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
import dydxFormatter
import RoutingKit

class dydxTransferAlertsProvider: dydxBaseAlertsProvider, dydxCustomAlertsProviderProtocol {
    var alertType: AlertType = .transfer

    private var subscriptions = Set<AnyCancellable>()

    override init() {
        super.init()

//        let t = dydxTransferInstance(transferType: .deposit,
//                                     transactionHash: "0x7a6257c3499b4307cf5a4e398f6cb87ce03db7706fa3f2669d8be3bcc461432e",
//                                     date: Date().addingTimeInterval(-1300),
//                                     usdcSize: 13.00)
//        let instance = createTransferStatusAlertItem(transfer: t)!
//        _items = [ instance ]

        AbacusStateManager.shared.state.transferState
            .compactMap { $0 }
            .removeDuplicates()
            .sink { [weak self] transferState in
                self?._items = transferState.transfers.compactMap { transfer in
                    self?.createTransferStatusAlertItem(transfer: transfer)
                }
            }
            .store(in: &subscriptions)
    }

    private func createTransferStatusAlertItem(transfer: dydxTransferInstance) -> PlatformViewModel? {
        let usdcSize = dydxFormatter.shared.dollar(number: transfer.usdcSize)
        let size = dydxFormatter.shared.raw(number: Parser.standard.asNumber(transfer.size), digits: 2)

        let title: String?
        let message: String? = nil
        let iconName: String?
        switch transfer.transferType {
        case .deposit:
            title = DataLocalizer.localize(path: "APP.ONBOARDING.DEPOSIT_ALERT_TITLE",
                                           params: [
                                                "PENDING_DEPOSITS": usdcSize ?? "0",
                                                "SOURCE_CHAIN": transfer.fromChainName ?? ""
                                           ])
            // message = DataLocalizer.localize(path: "APP.ONBOARDING.DEPOSIT_ALERT_SUBTITLE")
            iconName = "icon_transfer_deposit"
        case .withdrawal:
            title = DataLocalizer.localize(path: "APP.ONBOARDING.WITHDRAWAL_ALERT_TITLE",
                                           params: [
                                                "PENDING_WITHDRAWALS": usdcSize ?? "0",
                                                "DESTINATION_CHAIN": transfer.toChainName ?? ""
                                           ])
            // message = DataLocalizer.localize(path: "APP.ONBOARDING.WITHDRAWAL_ALERT_SUBTITLE")
            iconName = "icon_transfer_withdrawal"
        case .transferOut:
            let tokenName = usdcSize != nil ? dydxTokenConstants.usdcTokenName : dydxTokenConstants.nativeTokenName
            title = DataLocalizer.localize(path: "APP.ONBOARDING.TRANSFEROUT_ALERT_TITLE",
                                           params: [
                                                "PENDING_TRANSFERS": usdcSize ?? (size ?? "0"),
                                                "TOKEN": tokenName,
                                                "SOURCE_CHAIN": transfer.fromChainName ?? ""
                                           ])
            // message = DataLocalizer.localize(path: "APP.ONBOARDING.TRANSFEROUT_ALERT_SUBTITLE")
            iconName = "icon_transfer"
            break
        }
        if let title = title {
            let icon = PlatformIconViewModel(type: .asset(name: iconName, bundle: Bundle.dydxView),
                                             size: CGSize(width: 24, height: 24),
                                             templateColor: .textSecondary)
            return dydxAlertItemModel(title: title, message: message, icon: icon, tapAction: {
                let params = [
                    "hash": transfer.transactionHash
                ] as [String: Any?]
                Router.shared?.navigate(to: RoutingRequest(path: "/transfer/status", params: params.filterNils() as [String: Any]), animated: true, completion: nil)
            }, deletionAction: {
                AbacusStateManager.shared.removeTransferInstance(transfer: transfer)
            })
        } else {
            return nil
        }
    }
}
