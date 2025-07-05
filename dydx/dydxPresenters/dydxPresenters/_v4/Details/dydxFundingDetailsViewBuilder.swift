//
//  dydxFundingDetailsViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 17/06/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxFormatter
import dydxStateManager
import Abacus
import Combine

public class dydxFundingDetailsViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxFundingDetailsViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        let configuration = HostingViewControllerConfiguration(fixedHeight: UIScreen.main.bounds.height)
        return dydxFundingDetailsViewController(presenter: presenter, view: view, configuration: configuration) as? T
    }
}

private class dydxFundingDetailsViewController: HostingViewController<PlatformView, dydxFundingDetailsViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/funding" {
            if let presenter = presenter as? dydxFundingDetailsViewPresenter,
               let fundingPayment = request?.params?["item"] as? SubaccountFundingPayment {
                presenter.fundingPayment = fundingPayment
                return true
            }

            return true
        }
        return false
    }
}

private protocol dydxFundingDetailsViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxFundingDetailsViewModel? { get }
}

private class dydxFundingDetailsViewPresenter: HostedViewPresenter<dydxFundingDetailsViewModel>, dydxFundingDetailsViewPresenterProtocol {

    @Published var fundingPayment: SubaccountFundingPayment?

    override init() {
        super.init()

        viewModel = dydxFundingDetailsViewModel()
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest(
                $fundingPayment,
                AbacusStateManager.shared.state.configsAndAssetMap)
            .sink { [weak self] funding, configsAndAssetMap in
                self?.update(funding: funding, configsAndAssetMap: configsAndAssetMap)
            }
            .store(in: &subscriptions)
    }

    private func update(funding: SubaccountFundingPayment?, configsAndAssetMap: [String: MarketConfigsAndAsset]) {
        guard let funding else {
            return
        }
        guard let configsAndAsset = configsAndAssetMap[funding.marketId], let configs = configsAndAsset.configs, let asset = configsAndAsset.asset else {
            return
        }

        if let url = asset.resources?.imageUrl {
            viewModel?.logoUrl = URL(string: url)
        } else {
            viewModel?.logoUrl = nil
        }

        if funding.payment >= 0.0 {
            viewModel?.status = .earned
        } else {
            viewModel?.status = .paid
        }

        let amount = dydxFormatter.shared.dollar(number: funding.payment, size: "0.0001")

        let rate = dydxFormatter.shared.percent(number: funding.rate, digits: 6)

        let position = dydxFormatter.shared.raw(number: NSNumber(value: abs(funding.positionSize)), digits: configs.displayStepSizeDecimals?.intValue ?? 1)

        let price = dydxFormatter.shared.dollar(number: funding.price, digits: configs.displayTickSizeDecimals?.intValue ?? 2)

        let token = TokenTextViewModel(symbol: asset.displayableAssetId)

        let side: String
        if funding.positionSize >= 0 {
            side = DataLocalizer.localize(path: "APP.GENERAL.BUY")
        } else {
            side = DataLocalizer.localize(path: "APP.GENERAL.SELL")
        }

        let items: [dydxFundingDetailsViewModel.Item] = [
            .init(title: DataLocalizer.localize(path: "APP.GENERAL.MARKET"),
                  value: .any(token)),

            .init(title: DataLocalizer.localize(path: "APP.GENERAL.AMOUNT"),
                  value: .number(amount)),

            .init(title: DataLocalizer.localize(path: "APP.TRADE.RATE"),
                  value: .number(rate)),

            .init(title: DataLocalizer.localize(path: "APP.GENERAL.SIZE"),
                  value: .number(position)),

            .init(title: DataLocalizer.localize(path: "APP.GENERAL.SIDE"),
                 value: .string(side)),

            .init(title: DataLocalizer.localize(path: "APP.GENERAL.PRICE"),
                  value: .number(price)),

            .init(title: DataLocalizer.localize(path: "APP.GENERAL.CREATED_AT"),
                  value: .string(dydxFormatter.shared.dateAndTime(date: Date(milliseconds: funding.createdAtMilliseconds))))
        ]

        viewModel?.items = items
    }
}
