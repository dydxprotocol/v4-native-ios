//
//  dydxVaultHistoryViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 31/10/2024.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager
import Abacus
import dydxFormatter

public class dydxVaultHistoryViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxVaultHistoryViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxVaultHistoryViewController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxVaultHistoryViewController: HostingViewController<PlatformView, dydxVaultHistoryViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/vault/history" {
            return true
        }
        return false
    }
}

private protocol dydxVaultHistoryViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxVaultHistoryViewModel? { get }
}

private class dydxVaultHistoryViewPresenter: HostedViewPresenter<dydxVaultHistoryViewModel>, dydxVaultHistoryViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxVaultHistoryViewModel()

        viewModel?.headerViewModel?.title = DataLocalizer.shared?.localize(path: "APP.VAULTS.YOUR_DEPOSITS_AND_WITHDRAWALS", params: nil)
        viewModel?.headerViewModel?.backButtonAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.vault
            .compactMap(\.?.account?.vaultTransfers)
            .sink { [weak self] transfers in
                guard let self else { return }
                self.viewModel?.historyItems.items = transfers.compactMap {
                    self.createItemViewModel(transfer: $0)
                }
            }
            .store(in: &subscriptions)
    }

    private func createItemViewModel(transfer: VaultTransfer) -> dydxVaultHistoryItemViewModel? {
        guard let timestamp = transfer.timestampMs else { return nil }
        let date = Date(timeIntervalSince1970: Double(truncating: timestamp) / 1000)
        let dateString = dydxFormatter.shared.epoch(date: date)
        let timeString = dydxFormatter.shared.clock(time: date)
        let action: String?
        switch transfer.type {
        case .deposit:
            action = DataLocalizer.shared?.localize(path: "APP.GENERAL.DEPOSIT", params: nil)
        case .withdrawal:
            action = DataLocalizer.shared?.localize(path: "APP.GENERAL.WITHDRAW", params: nil)
        default:
            action = nil
        }
        let viewModel = dydxVaultHistoryItemViewModel()
        viewModel.date = dateString
        viewModel.time = timeString
        viewModel.action = action
        viewModel.amount = dydxFormatter.shared.dollar(number: transfer.amountUsdc, digits: 2)
        viewModel.onTapAction = {
            let mintscanUrl = AbacusStateManager.shared.environment?.links?.mintscan
            if let mintscanUrl, let txHash = transfer.transactionHash {
                let urlString = mintscanUrl.replacingOccurrences(of: "{tx_hash}", with: txHash)
                if let url = URL(string: urlString), URLHandler.shared?.canOpenURL(url) ?? false {
                    URLHandler.shared?.open(url, completionHandler: nil)
                }
            }
        }
        return viewModel
    }
}
