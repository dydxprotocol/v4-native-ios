//
//  dydxFiatDepositViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 29/09/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxFormatter
import dydxStateManager
import dydxFiatRamp
import Abacus

public class dydxFiatDepositViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxFiatDepositViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxFiatDepositViewController(presenter: presenter, view: view, configuration: .fullScreenSheet) as? T
    }
}

private class dydxFiatDepositViewController: HostingViewController<PlatformView, dydxFiatDepositViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/transfer/deposit/fiat" {
            return true
        }
        return false
    }
}

private protocol dydxFiatDepositViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxFiatDepositViewModel? { get }
}

private class dydxFiatDepositViewPresenter: HostedViewPresenter<dydxFiatDepositViewModel>, dydxFiatDepositViewPresenterProtocol {
    private let feePercent = dydxFiatDepositParam.moonpay_fee_percent.value
    private let minAmount = dydxFiatDepositParam.moonpay_min_deposit.value

    private var depositAmount: Double?

    private let moonPayRamp = dydxMoonPayRamp(isSandbox: !AbacusStateManager.shared.isMainNet,
                                              moonPayPk: CredientialConfig.shared.credential(for: "moonpayPk") ?? "Invalid Key",
                                              moonPaySk: CredientialConfig.shared.credential(for: "moonpaySk"),
                                              moonPaySignUrl: CredientialConfig.shared.credential(for: "moonpaySignUrl"),
                                              isDarkTheme: dydxThemeSettings.shared.currentThemeType == .dark)

    override init() {
        super.init()

        viewModel = dydxFiatDepositViewModel()

        viewModel?.cancelAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }
        viewModel?.ctaAction = { [weak self] in
            self?.showMoonPayUI()
        }

        viewModel?.providerName = "MoonPay"
        viewModel?.providerIcon = "logo_moonpay"
        viewModel?.providerSubtitle = DataLocalizer.localize(path: "APP.DEPOSIT_WITH_FIAT.MOONPAY_SUPPORT")
        viewModel?.fee = dydxFormatter.shared.percent(number: feePercent / 100.0, digits: 2)
        let minDollar = dydxFormatter.shared.dollar(number: minAmount, digits: 2)
        viewModel?.amountSubtitle = DataLocalizer.localize(path: "APP.DEPOSIT_WITH_FIAT.MINIMUM_MOONPAY_DEPOSIT",
                                                           params: ["MIN": minDollar ?? "-"])
        viewModel?.amountTextInput.onEdited = { [weak self] amount in
            let amountValue: Double
            if let amount {
                amountValue = Double(amount) ?? 0
            } else {
                amountValue = 0
            }
            self?.depositAmount = amountValue
            self?.viewModel?.ctaEnabled = amountValue >= self?.minAmount ?? 0
        }
    }

    private func showMoonPayUI() {
        guard let depositAmount, depositAmount >= minAmount else {
            return
        }

        AbacusStateManager.shared.state.currentWallet
            .prefix(1)
            .sink { [weak self] wallet in
                guard let self, let cosmosAddress = wallet?.cosmoAddress,
                let nobleAddress = AbacusStringUtils().toNobleAddress(dydxAddress: cosmosAddress) else {
                    return
                }

                self.showMoonPayUI(targetAddress: nobleAddress, usdAmount: depositAmount)
            }
            .store(in: &subscriptions)
    }

    private func showMoonPayUI(targetAddress: String, usdAmount: Double) {
        // Route to root because MoonPay SDK only works when there is no presented VC
        navigate(to: RoutingRequest(path: "/"), animated: true) { [weak self] _, _ in
            self?.moonPayRamp.show(targetAddress: targetAddress, usdAmount: usdAmount)
        }
    }
}
