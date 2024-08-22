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
import Charts
import dydxStateManager

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
        
        let usdcToken = AbacusStateManager.shared.environment?.usdcTokenInfo?.denom
        AbacusStateManager.shared.state.accountBalance(of: usdcToken)
            .sink {[weak self] usdcBalance in
                if usdcBalance ?? 0 > 0 {
                    self?.viewModel?.withdrawAction = {}
                }
            }
            .store(in: &subscriptions)
        viewModel?.depositAction = {}
        
        //TODO: remove & replace, test only
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel?.vaultChart?.setEntries(entries: self.generateEntries())
            self.viewModel?.positions = self.generatePositions()
        }
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
            dydxVaultPositionViewModel(assetName: "logo_bitcoin", market: "BTC", side: .long, leverage: 10.80, notionalValue: 100000, positionSize: 10000, token: "BTC", tokenUnitPrecision: 6, pnlAmount: 1000, pnlPercentage: 10, sparklineValues: (0..<10).map { _ in Double.random(in: 0.0...1.0) }),
            dydxVaultPositionViewModel(assetName: "logo_ethereum", market: "ETH", side: .short, leverage: 88.88, notionalValue: 50000, positionSize: 10000, token: "ETH", tokenUnitPrecision: -1, pnlAmount: -500, pnlPercentage: -1, sparklineValues: (0..<10).map { _ in Double.random(in: 0.0...1.0) }),
            dydxVaultPositionViewModel(assetName: "logo_bitcoin", market: "BTC", side: .long, leverage: 10.80, notionalValue: 100000, positionSize: 10000, token: "BTC", tokenUnitPrecision: 6, pnlAmount: 1000, pnlPercentage: 10, sparklineValues: (0..<10).map { _ in Double.random(in: 0.0...1.0) }),
            dydxVaultPositionViewModel(assetName: "logo_ethereum", market: "ETH", side: .short, leverage: 88.88, notionalValue: 50000, positionSize: 10000, token: "ETH", tokenUnitPrecision: -1, pnlAmount: -500, pnlPercentage: -1, sparklineValues: (0..<10).map { _ in Double.random(in: 0.0...1.0) }),
            dydxVaultPositionViewModel(assetName: "logo_bitcoin", market: "BTC", side: .long, leverage: 10.80, notionalValue: 100000, positionSize: 10000, token: "BTC", tokenUnitPrecision: 6, pnlAmount: 1000, pnlPercentage: 10, sparklineValues: (0..<10).map { _ in Double.random(in: 0.0...1.0) }),
            dydxVaultPositionViewModel(assetName: "logo_ethereum", market: "ETH", side: .short, leverage: 88.88, notionalValue: 50000, positionSize: 10000, token: "ETH", tokenUnitPrecision: -1, pnlAmount: -500, pnlPercentage: -1, sparklineValues: (0..<10).map { _ in Double.random(in: 0.0...1.0) }),
            dydxVaultPositionViewModel(assetName: "logo_bitcoin", market: "BTC", side: .long, leverage: 10.80, notionalValue: 100000, positionSize: 10000, token: "BTC", tokenUnitPrecision: 6, pnlAmount: 1000, pnlPercentage: 10, sparklineValues: (0..<10).map { _ in Double.random(in: 0.0...1.0) }),
            dydxVaultPositionViewModel(assetName: "logo_ethereum", market: "ETH", side: .short, leverage: 88.88, notionalValue: 50000, positionSize: 10000, token: "ETH", tokenUnitPrecision: -1, pnlAmount: -500, pnlPercentage: -1, sparklineValues: (0..<10).map { _ in Double.random(in: 0.0...1.0) }),
            dydxVaultPositionViewModel(assetName: "logo_bitcoin", market: "BTC", side: .long, leverage: 10.80, notionalValue: 100000, positionSize: 10000, token: "BTC", tokenUnitPrecision: 6, pnlAmount: 1000, pnlPercentage: 10, sparklineValues: (0..<10).map { _ in Double.random(in: 0.0...1.0) }),
            dydxVaultPositionViewModel(assetName: "logo_ethereum", market: "ETH", side: .short, leverage: 88.88, notionalValue: 50000, positionSize: 10000, token: "ETH", tokenUnitPrecision: -1, pnlAmount: -500, pnlPercentage: -1, sparklineValues: (0..<10).map { _ in Double.random(in: 0.0...1.0) }),
            dydxVaultPositionViewModel(assetName: "logo_bitcoin", market: "BTC", side: .long, leverage: 10.80, notionalValue: 100000, positionSize: 10000, token: "BTC", tokenUnitPrecision: 6, pnlAmount: 1000, pnlPercentage: 10, sparklineValues: (0..<10).map { _ in Double.random(in: 0.0...1.0) }),
            dydxVaultPositionViewModel(assetName: "logo_ethereum", market: "ETH", side: .short, leverage: 88.88, notionalValue: 50000, positionSize: 10000, token: "ETH", tokenUnitPrecision: -1, pnlAmount: -500, pnlPercentage: -1, sparklineValues: (0..<10).map { _ in Double.random(in: 0.0...1.0) })
        ]

    }
}
