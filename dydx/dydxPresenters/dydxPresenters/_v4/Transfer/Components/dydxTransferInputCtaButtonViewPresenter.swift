//
//  dydxTransferInputCtaButtonViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 4/17/23.
//

import Abacus
import Combine
import dydxStateManager
import dydxViews
import ParticlesKit
import PlatformParticles
import PlatformUI
import RoutingKit
import Utilities
import dydxAnalytics

protocol dydxTransferInputCtaButtonViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTradeInputCtaButtonViewModel? { get }
}

class dydxTransferInputCtaButtonViewPresenter: HostedViewPresenter<dydxTradeInputCtaButtonViewModel>, dydxTransferInputCtaButtonViewPresenterProtocol {
    enum TransferType {
        case deposit, withdrawal, transferOut

        var transferInstanceType: dydxTransferInstance.TransferType {
            switch self {
            case .deposit:
                return .deposit
            case .withdrawal:
                return .withdrawal
            case .transferOut:
                return .transferOut
            }
        }
    }

    private let transferType: TransferType
    private let onboardingAnalytics = OnboardingAnalytics()
    private let transferAnalytics = TransferAnalytics()

    init(transferType: TransferType) {
        self.transferType = transferType
        super.init()

        viewModel = dydxTradeInputCtaButtonViewModel()
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest3(
                AbacusStateManager.shared.state.transferInput,
                AbacusStateManager.shared.state.validationErrors,
                AbacusStateManager.shared.state.onboarded)
            .sink { [weak self] transferInput, tradeErrors, isOnboarded in
                self?.update(transferInput: transferInput, tradeErrors: tradeErrors, isOnboarded: isOnboarded)
            }
            .store(in: &subscriptions)
    }

    private func update(transferInput: TransferInput, tradeErrors: [ValidationError], isOnboarded: Bool) {
        updateCtaAction(transferInput: transferInput, isOnboarded: isOnboarded)
        updateCtaButtonState(transferInput: transferInput, tradeErrors: tradeErrors, isOnboarded: isOnboarded)
    }

    private func updateCtaButtonState(transferInput: TransferInput, tradeErrors: [ValidationError], isOnboarded: Bool) {
        if !isOnboarded {
            viewModel?.ctaButtonState = .enabled(DataLocalizer.localize(path: "APP.GENERAL.CONNECT_WALLET"))
        } else if hasValidSize(transferInput: transferInput) {
            let firstBlockingError = tradeErrors.first { $0.type == ErrorType.required || $0.type == ErrorType.error }
            let transferError = transferInput.errors
            if let firstBlockingError = firstBlockingError {
                if (transferType == .deposit || transferType == .withdrawal) && transferInput.requestPayload == nil {
                    viewModel?.ctaButtonState = .thinking
                } else {
                    viewModel?.ctaButtonState = .disabled(firstBlockingError.resources.action?.localizedString)
                }
            } else if transferError != nil {
                viewModel?.ctaButtonState = .disabled(DataLocalizer.localize(path: "APP.GENERAL.ERROR"))
            } else {
                switch transferType {
                case .deposit:
                    viewModel?.ctaButtonState = transferInput.requestPayload != nil ?
                        .enabled(DataLocalizer.localize(path: "APP.GENERAL.CONFIRM_DEPOSIT")) : .thinking
                case .withdrawal:
                    viewModel?.ctaButtonState = transferInput.requestPayload != nil ?
                        .enabled(DataLocalizer.localize(path: "APP.GENERAL.CONFIRM_WITHDRAW")) : .thinking
                case .transferOut:
                    viewModel?.ctaButtonState = .enabled(DataLocalizer.localize(path: "APP.DIRECT_TRANSFER_MODAL.CONFIRM_TRANSFER"))
                }
            }
        } else {
            switch transferType {
            case .deposit:
                viewModel?.ctaButtonState = .disabled(DataLocalizer.localize(path: "APP.DEPOSIT_MODAL.ENTER_DEPOSIT_AMOUNT"))
            case .withdrawal:
                viewModel?.ctaButtonState = .disabled(DataLocalizer.localize(path: "APP.WITHDRAW_MODAL.ENTER_WITHDRAW_AMOUNT"))
            case .transferOut:
                viewModel?.ctaButtonState = .disabled(DataLocalizer.localize(path: "APP.DIRECT_TRANSFER_MODAL.ENTER_TRANSFER_AMOUNT"))
            }
        }
    }

    private func updateCtaAction(transferInput: TransferInput, isOnboarded: Bool) {
        if !isOnboarded {
            self.viewModel?.ctaAction = {
                Router.shared?.navigate(to: RoutingRequest(path: "/onboard", params: nil), animated: true, completion: nil)
            }
        } else {
            viewModel?.ctaAction = { [weak self] in
                guard let self = self else { return }
                self.viewModel?.ctaButtonState = .disabled(DataLocalizer.localize(path: "APP.TRADE.SUBMITTING_ORDER"))
                switch self.transferType {
                case .deposit:
                    self.deposit()
                case .withdrawal:
                    self.withdrawal()
                case .transferOut:
                    self.transferOut()
                }
            }
        }
    }

    private func hasValidSize(transferInput: TransferInput) -> Bool {
        let size = parser.asDecimal(transferInput.size?.size)?.doubleValue ?? 0
        let usdcSize = parser.asDecimal(transferInput.size?.usdcSize)?.doubleValue ?? 0
        switch transferType {
        case .deposit:
            return size > 0
        case .withdrawal:
            return usdcSize > 0
        case .transferOut:
            return size > 0 || usdcSize > 0
        }
    }

    private func deposit() {
        Publishers.Zip(AbacusStateManager.shared.state.transferInput,
                       AbacusStateManager.shared.state.currentWallet.compactMap { $0 })
            .prefix(1)
            .flatMap { input, wallet in
                DepositTransaction(transferInput: input, walletAddress: wallet.ethereumAddress, walletId: wallet.walletId)
                    .run()
            }
            .withLatestFrom(AbacusStateManager.shared.state.transferInput)
            .sink { [weak self] event, transferInput in
                switch event {
                case let .result(hash, error):
                    if let error = error {
                        self?.showError(error: error)
                    } else if let hash = hash {
                        self?.sendOnboardingAnalytics()
                        self?.transferAnalytics.logDeposit(transferInput: transferInput)
                        self?.addTransferHash(hash: hash,
                                              fromChainName: transferInput.chainName ?? transferInput.networkName,
                                              toChainName: AbacusStateManager.shared.environment?.chainName,
                                              transferInput: transferInput)
                        self?.showTransferStatus(hash: hash, transferInput: transferInput)
                        self?.resetInputFields()
                    } else {
                        ErrorInfo.shared?.info(title: DataLocalizer.localize(path: "APP.GENERAL.ERROR"),
                                               message: DataLocalizer.localize(path: "APP.V4.NO_HASH"),
                                               type: .error,
                                               error: nil, time: nil)
                    }
                    self?.viewModel?.ctaButtonState = .enabled(DataLocalizer.localize(path: "APP.GENERAL.CONFIRM_DEPOSIT"))
                case .progress:
                    break
                }
            }
            .store(in: &subscriptions)
    }

    // screen the specified addresses for sanctions
    private func screen(originationAddress: String, destinationAddress: String, completion: @escaping (Bool) -> Void) {
        AbacusStateManager.shared.screen(addresses: [destinationAddress, originationAddress]) { [weak self] addressRestrictionPairs in
            guard let self = self else {
                completion(false)
                return
            }
            for addressRestrictionPair in addressRestrictionPairs {
                switch addressRestrictionPair.restriction {
                case .noRestriction:
                    // if no restrictions, continue iterating restrictions
                    continue
                case .userRestricted:
                    // custom user (address) restriction handling for withdraw/transfer flow
                    let errorTitle = DataLocalizer.shared?.localize(path: "ERRORS.ONBOARDING.WALLET_RESTRICTED_ERROR_TITLE", params: nil)
                    let errorBody: String
                    switch self.transferType {
                    case .transferOut, .withdrawal:
                        if destinationAddress == addressRestrictionPair.address {
                            errorBody = DataLocalizer.shared?.localize(path: "ERRORS.ONBOARDING.WALLET_RESTRICTED_WITHDRAWAL_TRANSFER_DESTINATION_ERROR_MESSAGE", params: nil) ?? ""
                        } else {
                            errorBody = DataLocalizer.shared?.localize(path: "ERRORS.ONBOARDING.WALLET_RESTRICTED_WITHDRAWAL_TRANSFER_ORIGINATION_ERROR_MESSAGE", params: nil) ?? ""
                        }
                    case .deposit:
                        assertionFailure("should not screen address for deposit")
                        return
                    }
                    DispatchQueue.runInMainThread {
                        ErrorInfo.shared?.info(title: errorTitle, message: errorBody, type: .error, error: nil)
                    }
                default:
                    dydxRestrictionsWorker.handle(restriction: addressRestrictionPair.restriction)
                }
                // there was a restriction in this iteration, complete as unsuccessful
                completion(false)
                return
            }
            // no restrictions detected, complete successfully
            completion(true)
        }
    }

    private func withdrawal() {
        Publishers.CombineLatest4(
            AbacusStateManager.shared.state.transferInput,
            AbacusStateManager.shared.state.currentWallet,
            AbacusStateManager.shared.state.selectedSubaccount.compactMap { $0 },
            AbacusStateManager.shared.state.accountBalance(of: AbacusStateManager.shared.environment?.usdcTokenInfo?.denom)
        )
        .prefix(1)
        .sink { [weak self] transferInput, currentWallet, selectedSubaccount, usdcBalanceInWallet in
            guard let self = self,
                  let destinationAddress = transferInput.address,
                  let originationAddress = currentWallet?.cosmoAddress else { return }
            self.screen(originationAddress: originationAddress, destinationAddress: destinationAddress) { success in
                guard success else { return }
                guard let data = transferInput.requestPayload?.data,
                      let amount = transferInput.size?.usdcSize, (self.parser.asDecimal(amount)?.doubleValue ?? 0) > 0.0 else {
                    return
                }
                if transferInput.isCctp {
                    AbacusStateManager.shared.commitCCTPWithdraw { [weak self] success, error, result in
                        if success {
                            self?.transferAnalytics.logWithdrawal(transferInput: transferInput)
                            self?.postTransaction(result: result, transferInput: transferInput)
                        } else {
                            ErrorInfo.shared?.info(title: DataLocalizer.localize(path: "APP.GENERAL.ERROR"),
                                                   message: error?.localizedDescription,
                                                   type: .error,
                                                   error: nil, time: nil)
                        }
                        self?.viewModel?.ctaButtonState = .enabled(DataLocalizer.localize(path: "APP.GENERAL.CONFIRM_WITHDRAW"))
                    }
                } else {
                    let gasFee = transferInput.summary?.gasFee?.doubleValue ?? 0
                    let usdcBalanceInWallet = usdcBalanceInWallet ?? 0
                    if usdcBalanceInWallet >= gasFee {
                        CosmoJavascript.shared.withdrawToIBC(subaccount: Int(selectedSubaccount.subaccountNumber), amount: amount, payload: data) { [weak self] result in
                            self?.transferAnalytics.logWithdrawal(transferInput: transferInput)
                            self?.postTransaction(result: result, transferInput: transferInput)
                            self?.viewModel?.ctaButtonState = .enabled(DataLocalizer.localize(path: "APP.GENERAL.CONFIRM_WITHDRAW"))
                        }
                    } else {
                        self.showNoGas()
                        self.viewModel?.ctaButtonState = .enabled(DataLocalizer.localize(path: "APP.GENERAL.CONFIRM_WITHDRAW"))
                    }
                }
            }
        }
        .store(in: &subscriptions)
    }

    private func transferOut() {
        Publishers.CombineLatest4(
            AbacusStateManager.shared.state.transferInput,
            AbacusStateManager.shared.state.currentWallet,
            AbacusStateManager.shared.state.accountBalance(of: AbacusStateManager.shared.environment?.usdcTokenInfo?.denom),
            AbacusStateManager.shared.state.accountBalance(of: AbacusStateManager.shared.environment?.nativeTokenInfo?.denom)
        )
        .prefix(1)
        .map {
            ($0, $1, $2, $3)
        }
        .withLatestFrom(AbacusStateManager.shared.state.selectedSubaccount)
        .sink { [weak self] (dump: (TransferInput, dydxWalletInstance?, Double?, Double?), selectedSubaccount: Subaccount?) in
            let transferInput = dump.0
            let currentWallet = dump.1
            let usdcBalanceInWallet = dump.2
            let dydxBalanceInWallet = dump.3

            guard let self = self,
                  let destinationAddress = transferInput.address,
                  let originationAddress = currentWallet?.cosmoAddress else { return }
            self.screen(originationAddress: originationAddress, destinationAddress: destinationAddress) { success in
                guard success else { return }
                guard let address = transferInput.address else {
                    return
                }

                if transferInput.token == dydxTokenConstants.usdcTokenKey {
                    if let selectedSubaccount = selectedSubaccount,
                       let amount = transferInput.size?.usdcSize {
                        let subaccountNumber = selectedSubaccount.subaccountNumber
                        let gasFee = transferInput.summary?.gasFee?.doubleValue ?? 0
                        let usdcBalanceInWallet = usdcBalanceInWallet ?? 0
                        if usdcBalanceInWallet >= gasFee {
                            self.transferOutUSDC(subaccountNumber: Int(subaccountNumber), amount: amount, recipient: address, transferInput: transferInput)
                        } else {
                            self.showNoGas()
                            self.viewModel?.ctaButtonState = .enabled(DataLocalizer.localize(path: "APP.DIRECT_TRANSFER_MODAL.CONFIRM_TRANSFER"))
                        }
                    }
                } else if transferInput.token == dydxTokenConstants.nativeTokenKey,
                          let amount = transferInput.size?.size {
                    let gas = transferInput.summary?.gasFee?.doubleValue ?? 0
                    let numericAmount = self.parser.asDecimal(amount)?.doubleValue ?? 0.0
                    if numericAmount + gas <= dydxBalanceInWallet ?? 0.0 {
                        self.transferOutDYDX(amount: amount, recipient: address, transferInput: transferInput)
                    }
                }
            }
        }
        .store(in: &subscriptions)
    }

    private func transferOutUSDC(subaccountNumber: Int, amount: String, recipient: String, transferInput: TransferInput) {
        let payload: [String: Any] = [
            "subaccountNumber": subaccountNumber,
            "amount": amount,
            "recipient": recipient,
            "memo": transferInput.memo as Any
        ]
        if let paramsInJson = payload.jsonString {
            CosmoJavascript.shared.call(functionName: "withdraw", paramsInJson: paramsInJson) { [weak self] result in
                self?.postTransaction(result: result, transferInput: transferInput)
                self?.viewModel?.ctaButtonState = .enabled(DataLocalizer.localize(path: "APP.DIRECT_TRANSFER_MODAL.CONFIRM_TRANSFER"))
            }
        }
    }

    private func transferOutDYDX(amount: String, recipient: String, transferInput: TransferInput) {
        let payload: [String: Any] = [
            "amount": amount,
            "recipient": recipient,
            "memo": transferInput.memo as Any
        ]
        if let paramsInJson = payload.jsonString {
            CosmoJavascript.shared.call(functionName: "transferNativeToken", paramsInJson: paramsInJson) { [weak self] result in
                self?.postTransaction(result: result, transferInput: transferInput)
                self?.viewModel?.ctaButtonState = .enabled(DataLocalizer.localize(path: "APP.DIRECT_TRANSFER_MODAL.CONFIRM_TRANSFER"))
            }
        }
    }

    private func postTransaction(result: Any?, transferInput: TransferInput) {
        if let result = (result as? String)?.jsonDictionary {
            if let error = result["error"] as? [String: Any] {
                ErrorInfo.shared?.info(title: DataLocalizer.localize(path: "APP.GENERAL.ERROR"),
                                       message: error["message"] as? String,
                                       type: .error,
                                       error: nil, time: nil)
            } else if let hash = result["transactionHash"] as? String {
                let fullHash = "0x" + hash
                addTransferHash(hash: fullHash,
                                fromChainName: AbacusStateManager.shared.environment?.chainName,
                                toChainName: transferInput.chainName ?? transferInput.networkName,
                                transferInput: transferInput)
                showTransferStatus(hash: fullHash, transferInput: transferInput)
                resetInputFields()
            } else if let hash = result["hash"] as? String {
                let fullHash = "0x" + hash
                addTransferHash(hash: fullHash,
                                fromChainName: AbacusStateManager.shared.environment?.chainName,
                                toChainName: transferInput.chainName ?? transferInput.networkName,
                                transferInput: transferInput)
                showTransferStatus(hash: fullHash, transferInput: transferInput)
                resetInputFields()
            } else {
                ErrorInfo.shared?.info(title: DataLocalizer.localize(path: "APP.GENERAL.ERROR"),
                                       message: DataLocalizer.localize(path: "APP.V4.NO_HASH"),
                                       type: .error,
                                       error: nil, time: nil)
            }
        } else {
            ErrorInfo.shared?.info(title: DataLocalizer.localize(path: "APP.GENERAL.ERROR"),
                                   message: DataLocalizer.localize(path: "APP.V4.NO_HASH"),
                                   type: .error,
                                   error: nil, time: nil)
        }
    }

    private func resetInputFields() {
        AbacusStateManager.shared.transfer(input: nil, type: .size)
        AbacusStateManager.shared.transfer(input: nil, type: .usdcsize)
        AbacusStateManager.shared.transfer(input: nil, type: .type)
    }

    private func showError(error: Error) {
        let error = error as NSError
        let title = error.userInfo["title"] as? String ?? ""
        let message = error.userInfo["message"] as? String ?? error.localizedDescription
        ErrorInfo.shared?.info(title: title,
                               message: message,
                               type: .error,
                               error: nil, time: nil)
    }

    private func showNoGas() {
        ErrorInfo.shared?.info(title: DataLocalizer.localize(path: "APP.V4.NO_GAS_TITLE"),
                               message: DataLocalizer.localize(path: "APP.V4.NO_GAS_BODY"),
                               type: .error,
                               error: nil, time: nil)
    }

    private func showTransferStatus(hash: String, transferInput: TransferInput?) {
        Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true) { _, _ in
            Router.shared?.navigate(to: RoutingRequest(path: "/alerts"), animated: true) { _, _ in
                var params = [
                    "hash": hash
                ] as [String: Any]
                if let transferInput = transferInput {
                    params["transferInput"] = transferInput
                }
                Router.shared?.navigate(to: RoutingRequest(path: "/transfer/status", params: params), animated: true, completion: nil)
            }
        }
    }

    private func addTransferHash(hash: String, fromChainName: String?, toChainName: String?, transferInput: TransferInput) {
        let transfer = dydxTransferInstance(transferType: transferType.transferInstanceType,
                                            transactionHash: hash.lowercased(),
                                            fromChainId: transferInput.requestPayload?.fromChainId,
                                            fromChainName: fromChainName,
                                            toChainId: transferInput.requestPayload?.toChainId,
                                            toChainName: toChainName,
                                            date: Date(),
                                            usdcSize: parser.asDecimal(transferInput.size?.usdcSize)?.doubleValue,
                                            size: parser.asDecimal(transferInput.size?.size)?.doubleValue,
                                            isCctp: transferInput.isCctp,
                                            requestId: transferInput.requestPayload?.requestId)
        AbacusStateManager.shared.addTransferInstance(transfer: transfer)
    }

    private func sendOnboardingAnalytics() {
        AbacusStateManager.shared.state.hasAccount
            .prefix(1)
            .sink { [weak self] hasAccount in
                // only log for newly onboarded users (i.e., user without an account)
                if !hasAccount {
                    self?.onboardingAnalytics.log(step: .depositFunds)
                }
            }
            .store(in: &subscriptions)
    }
}

private extension TransferInput {
    var chainName: String? {
        if let chain = chain {
            return resources?.chainResources?[chain]?.chainName
        }
        return nil
    }

    var networkName: String? {
        if let chain = chain {
            return resources?.chainResources?[chain]?.networkName
        }
        return nil
    }
}
