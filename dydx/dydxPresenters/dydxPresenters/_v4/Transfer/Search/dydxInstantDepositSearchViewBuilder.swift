//
//  dydxInstantDepositSearchViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 21/02/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxFormatter
import dydxStateManager
import Combine
import Abacus

public class dydxInstantDepositSearchViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxInstantDepositSearchViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxInstantDepositSearchViewController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxInstantDepositSearchViewController: HostingViewController<PlatformView, dydxInstantDepositSearchViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/transfer/deposit/search" {
            return true
        }
        return false
    }
}

private protocol dydxInstantDepositSearchViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxInstantDepositSearchViewModel? { get }
}

private class dydxInstantDepositSearchViewPresenter: HostedViewPresenter<dydxInstantDepositSearchViewModel>, dydxInstantDepositSearchViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxInstantDepositSearchViewModel()
        viewModel?.cancelAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }
    }

    override func start() {
        super.start()

        guard let transferTokenDetails = TransferTokenDetails.shared else {
            return
        }

        Publishers
            .CombineLatest3(
                transferTokenDetails.infos.removeDuplicates(),
                transferTokenDetails.$defaultToken,
                transferTokenDetails.$selectedToken
            )
            .sink { [weak self]  tokens, defaultToken, selectedToken in
                guard let self else { return }

                let selected = selectedToken ?? defaultToken

                var tokenViewModels = [dydxInstantDepositSearchItemViewModel]()
                var nullViewModels = [dydxInstantDepositSearchItemViewModel]()
                for token in tokens {
                    let itemViewModel = self.createItemViewModel(token: token, selected: selected)
                    if (token.amount ?? 0) > 0 || (token.usdcAmount ?? 0) > 0 {
                        tokenViewModels.append(itemViewModel)
                    } else {
                        nullViewModels.append(itemViewModel)
                    }
                }
                viewModel?.tokens = tokenViewModels
                viewModel?.otherTokens = nullViewModels
            }
            .store(in: &subscriptions)

        AbacusStateManager.shared.state.currentWallet
            .sink { [weak self] wallet in
                guard let self else { return }
                if wallet != nil {
                    self.viewModel?.nobleItem = dydxTransferNobleItemViewModel()
                    self.viewModel?.nobleItem?.nobleAdddressAction = {
                        Router.shared?.navigate(to: RoutingRequest(path: "/transfer/deposit/noble"), animated: true, completion: nil)
                    }
                    if dydxBoolFeatureFlag.fiat_deposit.isEnabled {
                        self.viewModel?.fiatItem = dydxTransferFiatItemViewModel()
                        self.viewModel?.fiatItem?.selectAction = {
                            Router.shared?.navigate(to: RoutingRequest(path: "/transfer/deposit/fiat"), animated: true, completion: nil)
                        }
                    } else {
                        self.viewModel?.fiatItem = nil
                    }
                } else {
                    self.viewModel?.nobleItem = nil
                    self.viewModel?.fiatItem = nil
                }
             }
            .store(in: &subscriptions)
    }

    private func createItemViewModel(token: TransferTokenInfo, selected: TransferTokenInfo?) -> dydxInstantDepositSearchItemViewModel {
        let viewModel = dydxInstantDepositSearchItemViewModel()
        viewModel.chain = token.chain.rawValue
        viewModel.chainIcon = URL(string: token.chainLogoUrl)
        viewModel.token = token.token.rawValue
        viewModel.tokenIcon = URL(string: token.tokenLogoUrl)
        if let amount = token.amount, amount > 0 {
            viewModel.tokenSize = dydxFormatter.shared.raw(number: amount, digits: 4)
        }
        if let usdcAmount = token.usdcAmount, usdcAmount > 0 {
            viewModel.usdcSize = dydxFormatter.shared.dollar(number: usdcAmount, digits: 2)
        }
        viewModel.selected = token.tokenAddress == selected?.tokenAddress && token.chainId == selected?.chainId
        if let amount = token.amount, amount > 0 {
            viewModel.selectAction = {
                TransferTokenDetails.shared?.selectedToken = token
                Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
            }
        }
        return viewModel
    }
}
