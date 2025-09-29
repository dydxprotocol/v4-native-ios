//
//  dydxTurnkeyDepositViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 04/08/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager
import dydxFormatter

protocol dydxTurnkeyDepositViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTurnkeyDepositViewModel? { get }
}

class dydxTurnkeyDepositViewPresenter: HostedViewPresenter<dydxTurnkeyDepositViewModel>, dydxTurnkeyDepositViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxTurnkeyDepositViewModel()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            AbacusStateManager.shared.startTrade()
            AbacusStateManager.shared.startTransfer()
        }

        let allChains = TransferTokenDetails.shared?.turnkeyInfos
        let chainOrders: [TransferChain] = [
            .Solana,
            .Ethereum,
            .Arbitrum,
            .Base,
            .Optimism,
            .Avalanche
        ]
        viewModel?.items = chainOrders.compactMap { chain in
            let info = allChains?.first { $0.chain == chain }
            if let info {
                return createItem(for: info)
            } else {
                return nil
            }
        }

        if dydxBoolFeatureFlag.fiat_deposit.isEnabled {
            viewModel?.fiatAction = {
                Router.shared?.navigate(to: RoutingRequest(path: "/transfer/deposit/fiat"), animated: true, completion: nil)
            }
        }
    }

    private func createItem(for tokenInfo: TransferTokenInfo) -> dydxTurnkeyDepositViewModel.Item {
        dydxTurnkeyDepositViewModel.Item(
            title: tokenInfo.chain.rawValue,
            subtitle: tokenInfo.chain.supportedDepositTokenString,
            tag: tokenInfo.chain.depositFeesString,
            icon: URL(string: tokenInfo.chainLogoUrl),
            action: {
                Router.shared?.navigate(to: RoutingRequest(path: "/transfer/deposit/qr_code", params: ["chain": tokenInfo.chain.rawValue]), animated: true, completion: nil)
            }
        )
    }
}
