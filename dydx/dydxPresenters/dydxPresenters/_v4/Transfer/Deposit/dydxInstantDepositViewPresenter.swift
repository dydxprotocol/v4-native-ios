//
//  dydxInstantDepositViewPresenter.swift
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

protocol dydxInstantDepositViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxInstantDepositViewModel? { get }
}

class dydxInstantDepositViewPresenter: HostedViewPresenter<dydxInstantDepositViewModel>, dydxInstantDepositViewPresenterProtocol {
    private var currentSize: Double?

    private let validationPresenter = dydxValidationViewPresenter(receiptType: .transfer)
    private let ctaButtonPresenter = dydxTransferInputCtaButtonViewPresenter(transferType: .deposit)

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        validationPresenter,
        ctaButtonPresenter
    ]

    private let staticSelector = true       // turn it to off to let user select

    override init() {
        let viewModel = dydxInstantDepositViewModel()

        validationPresenter.$viewModel.assign(to: &viewModel.$validationViewModel)
        ctaButtonPresenter.$viewModel.assign(to: &viewModel.$ctaButton)

        super.init()

        self.viewModel = viewModel

        viewModel.connectWalletAction = {
            let request = RoutingRequest(path: "/onboard/wallets",
                                         params: ["mobileOnly": "true"])
            Router.shared?.navigate(to: request, animated: true, completion: nil)
        }

        attachChildren(workers: childPresenters)
    }

    override func start() {
        super.start()

        guard let transferTokenDetails = TransferTokenDetails.shared else {
            return
        }

        Publishers
            .CombineLatest4(
                AbacusStateManager.shared.state.transferInput,
                transferTokenDetails.$defaultToken,
                transferTokenDetails.$selectedToken,
                AbacusStateManager.shared.state.currentWallet
                    .map(\.?.ethereumAddress)
                )
            .sink { [weak self] transferInput, defaultToken, selectedToken, sourceAddress in
                if transferInput.type != .deposit {
                    AbacusStateManager.shared.startDeposit()
                }

                let token = selectedToken ?? defaultToken
                if let tokenDecimals = self?.parser.asString(token?.decimals) {
                    AbacusStateManager.shared.transfer(input: tokenDecimals, type: .decimals)
                }
                self?.updateInputToken(transferInput: transferInput, token: token)

                self?.updateSelector(transferInput: transferInput)

                if transferInput.chain != token?.chainId {
                    AbacusStateManager.shared.transfer(input: token?.chainId, type: .chain)
                }
                if transferInput.token != token?.tokenAddress {
                    AbacusStateManager.shared.transfer(input: token?.tokenAddress, type: .token)
                }

                if let sourceAddress = sourceAddress,
                   sourceAddress.starts(with: "dydx") == false {
                    self?.viewModel?.showConnectWallet = false
                } else {
                    self?.viewModel?.showConnectWallet = true
                }
            }
            .store(in: &subscriptions)
    }

    private func updateSelector(transferInput: TransferInput) {
        if let duration = transferInput.summary?.estimatedRouteDurationSeconds?.doubleValue,
           let minutes = parser.asString(Int(ceil(duration / 60))) {
            let minutesLocalized = DataLocalizer.localize(path: "APP.GENERAL.TIME_STRINGS.X_MINUTES", params: ["X": minutes])
            viewModel?.selector?.regularTime = minutesLocalized
        } else {
            if staticSelector {
                viewModel?.selector?.regularTime = nil
            } else {
                viewModel?.selector?.regularTime = "< " + DataLocalizer.localize(path: "APP.GENERAL.TIME_STRINGS.30MIN")
            }
        }

        if let fees = transferInput.summary?.bridgeFee?.doubleValue,
           let amount = dydxFormatter.shared.dollar(number: parser.asNumber(fees)) {
            viewModel?.selector?.regularFee = amount
        } else {
            if staticSelector {
                viewModel?.selector?.regularFee = nil
            } else {
                viewModel?.selector?.regularFee = DataLocalizer.localize(path: "APP.ONBOARDING.SKIP_SLOW_ROUTE_DESC")
            }
        }

        if staticSelector {
            if shouldShowInstantDeposit(transferInput: transferInput) {
                viewModel?.selector?.selection = .instant
                TransferRouteSelectionInfo.shared.selected = .instant
            } else {
                viewModel?.selector?.selection = .regular
                TransferRouteSelectionInfo.shared.selected = .regular
            }
        } else {
            if let fees = transferInput.goFastSummary?.bridgeFee?.doubleValue,
               let amount = dydxFormatter.shared.dollar(number: parser.asNumber(fees)) {
                viewModel?.selector?.instantFee = amount
                if TransferRouteSelectionInfo.shared.allSelections != [.regular, .instant] {
                    viewModel?.selector?.selection = .instant
                    TransferRouteSelectionInfo.shared.allSelections = [.regular, .instant]
                    TransferRouteSelectionInfo.shared.selected = .instant
                }
            } else {
                viewModel?.selector?.instantFee = DataLocalizer.localize(path: "APP.GENERAL.UNAVAILABLE")
                if TransferRouteSelectionInfo.shared.allSelections != [.regular] {
                    viewModel?.selector?.selection = .regular
                    TransferRouteSelectionInfo.shared.allSelections = [.regular]
                    TransferRouteSelectionInfo.shared.selected = .regular
                }
            }
            viewModel?.selector?.selectionAction = { [weak self] selected in
                if TransferRouteSelectionInfo.shared.allSelections.contains(selected) {
                    TransferRouteSelectionInfo.shared.selected = selected
                    self?.viewModel?.selector?.selection = selected
                }
            }
        }

        viewModel?.freeDepositWarningMessage = staticSelector ? shouldShowInstantDepositWarning(transferInput: transferInput) : nil
    }

    private func shouldShowInstantDeposit(transferInput: TransferInput) -> Bool {
        guard transferInput.goFastRequestPayload != nil else {
            return false
        }

        return shouldShowInstantDepositWarning(transferInput: transferInput) == nil
    }

    private func shouldShowInstantDepositWarning(transferInput: TransferInput) -> String? {
        let usdcSize: Double = transferInput.goFastSummary?.usdcSize?.doubleValue ?? transferInput.summary?.usdcSize?.doubleValue ?? 0
        let minAmount = dydxNumberFeatureFlag.skip_ga_fast_transfer_min.value
        let maxAmount = dydxNumberFeatureFlag.skip_go_fast_transfer_max.value
        if usdcSize > 0,
           let minAmountString = dydxFormatter.shared.localFormatted(number: minAmount, digits: 0),
            let maxAmountString = dydxFormatter.shared.localFormatted(number: maxAmount, digits: 0) {
            if usdcSize < minAmount {
                return DataLocalizer.localize(path: "APP.DEPOSIT_MODAL.FREE_INSTANT_DEPOSIT_MIN", params: ["MIN_AMOUNT": minAmountString])
            } else if usdcSize > maxAmount {
                return DataLocalizer.localize(path: "APP.DEPOSIT_MODAL.FREE_INSTANT_DEPOSIT_MAX", params: ["MAX_AMOUNT": maxAmountString])
            }
        }
        return nil
    }

    private func updateInputToken(transferInput: TransferInput, token: TransferTokenInfo?) {
        let input = viewModel?.input

        input?.maxAmount = token?.amount
        input?.maxAmountString = dydxFormatter.shared.raw(number: token?.amount, digits: 4)
        input?.token = token?.token.rawValue
        if let tokenLogoUrl = token?.tokenLogoUrl {
            input?.tokenIcon = URL(string: tokenLogoUrl)
        }
        if let chainLogoUrl = token?.chainLogoUrl {
            input?.chainIcon = URL(string: chainLogoUrl)
        }
        input?.assetAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/transfer/deposit/search", params: nil), animated: true, completion: nil)
        }
        let placholder = dydxFormatter.shared.raw(number: 0.0, digits: 4)
        input?.value = transferInput.size?.size
        input?.placeHolder = placholder
        input?.onEdited = { [weak self] amount in
            var amountDouble = Parser.standard.asNumber(amount?.unlocalizedNumericValue)?.doubleValue ?? 0
            amountDouble = min(amountDouble, token?.amount ?? 0)
            if amountDouble != self?.currentSize {
                AbacusStateManager.shared.transfer(input: Parser.standard.asString(amountDouble), type: .size)
            }
        }
        let size: Double = parser.asNumber(transferInput.size?.size)?.doubleValue ?? 0
        if size > 0 {
             input?.value = dydxFormatter.shared.raw(number: NSNumber(value: size), size: "0.001")
        } else {
             input?.value = nil
        }
        input?.maxAction = {
            AbacusStateManager.shared.transfer(input: Parser.standard.asString(token?.amount), type: .size)
        }
        currentSize = size
    }
}
