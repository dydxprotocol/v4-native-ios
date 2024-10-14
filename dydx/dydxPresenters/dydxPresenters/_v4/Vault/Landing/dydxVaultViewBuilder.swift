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
        // return HostingViewController(presenter: presenter, view: view) as? T
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

        viewModel?.depositAction = { Router.shared?.navigate(to: RoutingRequest(path: "/vault/deposit"), animated: true, completion: nil) }
        viewModel?.withdrawAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/vault/withdraw"), animated: true, completion: nil)
        }
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
                  let assetId = marketMap[marketId]?.assetId,
                  let asset = assetMap[assetId]
            else { return nil }
            return dydxVaultPositionViewModel(assetId: assetId,
                                              iconUrl: URL(string: asset.resources?.imageUrl ?? ""),
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
    }

    // TODO: remove, just for testing
    private func generateEntries() -> [ChartDataEntry] {
        let selectedValueTime = viewModel?.vaultChart?.selectedValueTime ?? .oneDay
        let now = Date().timeIntervalSince1970
        let finalTimeSecondsAway = selectedValueTime == .oneDay ? 3600.0*24.0 : selectedValueTime == .sevenDays ? 3600.0*24.0*7.0 : 3600.0*24.0*30.0
        let numEntries = Int.random(in: 0..<100)
        let entries = (0..<numEntries).map { i in
            ChartDataEntry(x: now + Double(i)/Double(numEntries) * finalTimeSecondsAway, y: Double.random(in: 0..<100))
        }
        return entries
    }

    // TODO: remove
    // this is just for testing
    private func generatePositions() -> [dydxVaultPositionViewModel] {
        return [
            dydxVaultPositionViewModel(assetId: "logo_bitcoin", iconUrl: nil, side: .long, leverage: 10.80, notionalValue: 100000, positionSize: 10000, tokenUnitPrecision: 6, pnlAmount: 1000, pnlPercentage: 10, sparklineValues: (0..<10).map { _ in Double.random(in: 0.0...1.0) }),
            dydxVaultPositionViewModel(assetId: "logo_ethereum", iconUrl: nil, side: .short, leverage: 88.88, notionalValue: 50000, positionSize: 10000, tokenUnitPrecision: -1, pnlAmount: -500, pnlPercentage: -1, sparklineValues: (0..<10).map { _ in Double.random(in: 0.0...1.0) }),
            dydxVaultPositionViewModel(assetId: "logo_bitcoin", iconUrl: nil, side: .long, leverage: 10.80, notionalValue: 100000, positionSize: 10000, tokenUnitPrecision: 6, pnlAmount: 1000, pnlPercentage: 10, sparklineValues: (0..<10).map { _ in Double.random(in: 0.0...1.0) }),
            dydxVaultPositionViewModel(assetId: "logo_ethereum", iconUrl: nil, side: .short, leverage: 88.88, notionalValue: 50000, positionSize: 10000, tokenUnitPrecision: -1, pnlAmount: -500, pnlPercentage: -1, sparklineValues: (0..<10).map { _ in Double.random(in: 0.0...1.0) }),
            dydxVaultPositionViewModel(assetId: "logo_bitcoin", iconUrl: nil, side: .long, leverage: 10.80, notionalValue: 100000, positionSize: 10000, tokenUnitPrecision: 6, pnlAmount: 1000, pnlPercentage: 10, sparklineValues: (0..<10).map { _ in Double.random(in: 0.0...1.0) }),
            dydxVaultPositionViewModel(assetId: "logo_ethereum", iconUrl: nil, side: .short, leverage: 88.88, notionalValue: 50000, positionSize: 10000, tokenUnitPrecision: -1, pnlAmount: -500, pnlPercentage: -1, sparklineValues: (0..<10).map { _ in Double.random(in: 0.0...1.0) }),
            dydxVaultPositionViewModel(assetId: "logo_bitcoin", iconUrl: nil, side: .long, leverage: 10.80, notionalValue: 100000, positionSize: 10000, tokenUnitPrecision: 6, pnlAmount: 1000, pnlPercentage: 10, sparklineValues: (0..<10).map { _ in Double.random(in: 0.0...1.0) }),
            dydxVaultPositionViewModel(assetId: "logo_ethereum", iconUrl: nil, side: .short, leverage: 88.88, notionalValue: 50000, positionSize: 10000, tokenUnitPrecision: -1, pnlAmount: -500, pnlPercentage: -1, sparklineValues: (0..<10).map { _ in Double.random(in: 0.0...1.0) }),
            dydxVaultPositionViewModel(assetId: "logo_bitcoin", iconUrl: nil, side: .long, leverage: 10.80, notionalValue: 100000, positionSize: 10000, tokenUnitPrecision: 6, pnlAmount: 1000, pnlPercentage: 10, sparklineValues: (0..<10).map { _ in Double.random(in: 0.0...1.0) }),
            dydxVaultPositionViewModel(assetId: "logo_ethereum", iconUrl: nil, side: .short, leverage: 88.88, notionalValue: 50000, positionSize: 10000, tokenUnitPrecision: -1, pnlAmount: -500, pnlPercentage: -1, sparklineValues: (0..<10).map { _ in Double.random(in: 0.0...1.0) }),
            dydxVaultPositionViewModel(assetId: "logo_bitcoin", iconUrl: nil, side: .long, leverage: 10.80, notionalValue: 100000, positionSize: 10000, tokenUnitPrecision: 6, pnlAmount: 1000, pnlPercentage: 10, sparklineValues: (0..<10).map { _ in Double.random(in: 0.0...1.0) }),
            dydxVaultPositionViewModel(assetId: "logo_ethereum", iconUrl: nil, side: .short, leverage: 88.88, notionalValue: 50000, positionSize: 10000, tokenUnitPrecision: -1, pnlAmount: -500, pnlPercentage: -1, sparklineValues: (0..<10).map { _ in Double.random(in: 0.0...1.0) })
        ]

    }
}
