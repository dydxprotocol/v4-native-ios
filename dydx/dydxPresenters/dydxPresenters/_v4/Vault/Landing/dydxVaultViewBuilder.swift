//
//  dydxVaultViewBuilder.swift
//  dydxUI
//
//  Created by Michael Maguire on 7/30/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//
// Move the builder code to the dydxPresenters module for v4, or dydxUI modules for v3

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import DGCharts
import dydxStateManager
import Abacus
import Combine

public class dydxVaultViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxVaultViewBuilderPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxVaultViewController(presenter: presenter, view: view, configuration: .tabbarItemView) as? T
    }
}

private class dydxVaultViewController: HostingViewController<PlatformView, dydxVaultViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/vault" {
            return true
        }
        return false
    }
}

private protocol dydxVaultViewBuilderPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxVaultViewModel? { get }
}

private class dydxVaultViewBuilderPresenter: HostedViewPresenter<dydxVaultViewModel>, dydxVaultViewBuilderPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxVaultViewModel()
        viewModel?.vaultChart = dydxVaultChartViewModel()
    }

    override func start() {
        super.start()

        Publishers.CombineLatest3(
            AbacusStateManager.shared.state.vault,
            AbacusStateManager.shared.state.assetMap,
            AbacusStateManager.shared.state.marketMap
        )
        .sink(receiveValue: { [weak self] vault, assetMap, marketMap in
            self?.updateState(vault: vault, assetMap: assetMap, marketMap: marketMap)
        })
        .store(in: &subscriptions)

        if let chartViewModel = viewModel?.vaultChart {
            Publishers.CombineLatest3(
                AbacusStateManager.shared.state.vault,
                chartViewModel.$selectedValueType,
                chartViewModel.$selectedValueTime
            )
            .sink(receiveValue: { [weak self] vault, valueType, timeType in
                self?.updateChartState(vault: vault, valueType: valueType, timeType: timeType)
            })
            .store(in: &subscriptions)
        }

        AbacusStateManager.shared.state.onboarded
            .sink { [weak self] onboarded in
                if onboarded {
                    self?.viewModel?.depositAction = { Router.shared?.navigate(to: RoutingRequest(path: "/vault/deposit"), animated: true, completion: nil) }
                    self?.viewModel?.withdrawAction = { Router.shared?.navigate(to: RoutingRequest(path: "/vault/withdraw"), animated: true, completion: nil) }
                } else {
                    self?.viewModel?.depositAction = nil
                    self?.viewModel?.withdrawAction = nil
                }
            }
            .store(in: &subscriptions)
    }

    private func updateState(vault: Abacus.Vault?, assetMap: [String: Asset], marketMap: [String: PerpetualMarket]) {
        viewModel?.totalValueLocked = vault?.details?.totalValue?.doubleValue
        viewModel?.thirtyDayReturnPercent = vault?.details?.thirtyDayReturnPercent?.doubleValue
        viewModel?.vaultBalance = vault?.account?.balanceUsdc?.doubleValue
        viewModel?.allTimeReturnUsdc = vault?.account?.allTimeReturnUsdc?.doubleValue

        viewModel?.positions = vault?.positions?.positions?.map { (position) -> dydxVaultPositionViewModel? in
            guard let leverage = position.currentLeverageMultiple?.doubleValue,
                  let notionalValue = position.currentPosition?.usdc?.doubleValue,
                  let positionSize = position.currentPosition?.asset?.doubleValue,
                  let marketId = position.marketId,
                  // special case for fake USDC market to show unused margin
                  let assetId = marketId == "USDC-USD" ? "USDC" : marketMap[marketId]?.assetId
            else { return nil }
            let iconType: PlatformIconViewModel.IconType
            if marketId == "USDC-USD" {
                iconType = .asset(name: "symbol_USDC", bundle: .dydxView)
            } else {
                iconType = .init(url: URL(string: assetMap[assetId]?.resources?.imageUrl ?? ""), placeholderText: assetId.first?.uppercased())
            }
            return dydxVaultPositionViewModel(assetId: assetId,
                                              iconType: iconType,
                                              side: positionSize > 0 ? .long : .short,
                                              leverage: leverage,
                                              notionalValue: notionalValue,
                                              positionSize: positionSize.magnitude,
                                              tokenUnitPrecision: 2,
                                              pnlAmount: position.thirtyDayPnl?.absolute?.doubleValue,
                                              pnlPercentage: position.thirtyDayPnl?.percent?.doubleValue,
                                              sparklineValues: position.thirtyDayPnl?.sparklinePoints?.map({ $0.doubleValue }))
        }
        .compactMap { $0 }
        .sorted(by: { $0.notionalValue > $1.notionalValue })
    }

    private func updateChartState(vault: Abacus.Vault?, valueType: dydxVaultChartViewModel.ValueTypeOption, timeType: dydxVaultChartViewModel.ValueTimeOption) {
        let entries: [dydxVaultChartViewModel.Entry] = vault?.details?.history?.reversed()
            .compactMap { entry in
                let secondsSince1970 = (entry.date?.doubleValue ?? 0) / 1000.0
                let minSecondsSince1970: Double
                switch timeType {
                case .oneDay:
                    minSecondsSince1970 = Date().addingTimeInterval(-24 * 60 * 60).timeIntervalSince1970
                case .sevenDays:
                    minSecondsSince1970 = Date().addingTimeInterval(-7 * 24 * 60 * 60).timeIntervalSince1970
                case .thirtyDays:
                    minSecondsSince1970 = Date().addingTimeInterval(-30 * 24 * 60 * 60).timeIntervalSince1970
                }

                if minSecondsSince1970 <= secondsSince1970,
                    let value = valueType == .equity ? entry.equity?.doubleValue : entry.totalPnl?.doubleValue {
                    return .init(date: secondsSince1970, value: value)
                } else {
                    return nil
                }
            } ?? []
        viewModel?.vaultChart?.entries = entries
    }
}
