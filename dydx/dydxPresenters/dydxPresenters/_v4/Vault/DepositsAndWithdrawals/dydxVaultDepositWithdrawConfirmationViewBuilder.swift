//
//  dydxVaultDepositWithdrawConfirmationViewBuilder.swift
//  dydxPresenters
//
//  Created by Michael Maguire on 9/6/24.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager
import FloatingPanel
import PlatformRouting
import dydxFormatter
import Combine
import dydxAnalytics
import class Abacus.Subaccount
import class Abacus.Vault
import class Abacus.VaultFormValidationResult
import class Abacus.VaultFormAccountData
import class Abacus.VaultFormData
import class Abacus.VaultDepositWithdrawFormValidator
import class Abacus.VaultAccount
import class Abacus.OnChainTransactionSuccessResponse
import class Abacus.ChainError

public class dydxVaultDepositWithdrawConfirmationViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxVaultDepositWithdrawConfirmationViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        let viewController = dydxVaultDepositWithdrawConfirmationViewController(presenter: presenter, view: view, configuration: .default)
        return viewController as? T
    }
}

private class dydxVaultDepositWithdrawConfirmationViewController: HostingViewController<PlatformView, dydxVaultDepositWithdrawConfirmationViewModel> {

    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        let presenter = presenter as? dydxVaultDepositWithdrawConfirmationViewPresenterProtocol
        presenter?.amount = request?.params?["amount"] as? Double
        if request?.path == "/vault/deposit_confirm" {
            presenter?.transferType = .deposit
            return true
        } else if request?.path == "/vault/withdraw_confirm" {
            presenter?.transferType = .withdraw
            return true
        } else {
            return false
        }
    }
}

private protocol dydxVaultDepositWithdrawConfirmationViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxVaultDepositWithdrawConfirmationViewModel? { get }
    var transferType: VaultTransferType? { get set }
    var amount: Double? { get set }
}

private class dydxVaultDepositWithdrawConfirmationViewPresenter: HostedViewPresenter<dydxVaultDepositWithdrawConfirmationViewModel>, dydxVaultDepositWithdrawConfirmationViewPresenterProtocol {
    static let slippageAcknowledgementThreshold = 0.01

    var transferType: VaultTransferType?
    var amount: Double?
    private var formValidationRequest: Task<Void, Never>?

    override init() {
        super.init()

        viewModel = dydxVaultDepositWithdrawConfirmationViewModel()
    }

    override func start() {
        super.start()

        guard let viewModel else { return }

        viewModel.amount = amount
        viewModel.faqUrl = AbacusStateManager.shared.environment?.links?.vaultLearnMore
        viewModel.transferType = transferType

        initializeSubmitState()

        viewModel.cancelAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }

        // transfer types determin throttling/debounce config
        // do not need debouncing/throttling for deposit since there are no slippage fetches
        // for withdrawal, refetch slippage every ~2 seconds if subaccount or vault changes during a 2 second period
        // for withdrawal, refetch slippage after input changes (debounced)
        let vaultAndSubaccountPublisher = Publishers.CombineLatest(AbacusStateManager.shared.state.selectedSubaccount,
                                                                   AbacusStateManager.shared.state.vault.compactMap({ $0 }))
            .map { (subaccount: $0, vault: $1) }
            .throttle(for: transferType == .deposit ? 0 : 2, scheduler: DispatchQueue.main, latest: true)

        let hasAcknowledgedHighSlippagePublisher = viewModel.$hasAcknowledgedHighSlippage
            .removeDuplicates()

        Publishers.CombineLatest(vaultAndSubaccountPublisher, hasAcknowledgedHighSlippagePublisher)
            .sink(receiveValue: { [weak self] vaultAndSubaccount, hasAcknowledgedHighSlippage in
                guard self?.viewModel?.submitState != .submitting else { return }
                self?.update(subaccount: vaultAndSubaccount.subaccount, vault: vaultAndSubaccount.vault, hasAcknowledgedHighSlippage: hasAcknowledgedHighSlippage)
            })
            .store(in: &subscriptions)

        // need a non-debounce for the initial fetch so that UI updates immediately after change
        viewModel.$hasAcknowledgedHighSlippage
            .sink {[weak self] hasAcknowledgedHighSlippage in
                guard let self = self else { return }
                self.update(hasAcknowledgedHighSlippage: hasAcknowledgedHighSlippage)
            }
            .store(in: &subscriptions)
    }

    private func initializeSubmitState() {
        guard let viewModel, let transferType else { return }
        switch transferType {
        case .deposit:
            viewModel.submitState = .enabled
        case .withdraw:
            viewModel.submitState = .loading
        }
    }

    private func update(hasAcknowledgedHighSlippage: Bool) {
        switch self.transferType {
        case .deposit, nil:
            // not applicable for deposits
            break
        case .withdraw:
            self.viewModel?.submitState = .loading
        }
    }

    private func update(subaccount: Subaccount?, vault: Abacus.Vault, hasAcknowledgedHighSlippage: Bool) {
        formValidationRequest?.cancel()

        guard let subaccount = subaccount, let transferType else {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
            return
        }

        let accountData = Abacus.VaultFormAccountData(marginUsage: subaccount.marginUsage?.current,
                                                      freeCollateral: subaccount.freeCollateral?.current,
                                                      canViewAccount: true)

        let formData = VaultFormData(action: transferType.formAction,
                                     amount: amount?.asKotlinDouble,
                                     acknowledgedSlippage: hasAcknowledgedHighSlippage,
                                     inConfirmationStep: true)

        switch transferType {
        case .deposit:

            let formValidationResult = Abacus.VaultDepositWithdrawFormValidator.shared.validateVaultForm(formData: formData,
                                                                                                         accountData: accountData,
                                                                                                         vaultAccount: vault.account,
                                                                                                         slippageResponse: nil,
                                                                                                         localizer: DataLocalizer.shared?.asAbacusLocalizer)
            self.update(subaccount: subaccount,
                        vault: vault,
                        hasAcknowledgedHighSlippage: hasAcknowledgedHighSlippage,
                        formValidationResult: formValidationResult)
        case .withdraw:
            fetchSlippageAndUpdate(formData: formData,
                                   accountData: accountData,
                                   subaccount: subaccount,
                                   vault: vault,
                                   hasAcknowledgedHighSlippage: hasAcknowledgedHighSlippage
            )
        }
    }

    private func update(subaccount: Subaccount?, vault: Abacus.Vault, hasAcknowledgedHighSlippage: Bool, formValidationResult: Abacus.VaultFormValidationResult) {
        let isSlippageAckSatisfied = formValidationResult.summaryData.needSlippageAck?.boolValue == false || hasAcknowledgedHighSlippage
        let submitDataReady = formValidationResult.submissionData != nil
        viewModel?.submitState = isSlippageAckSatisfied && submitDataReady ? .enabled : .disabled
        viewModel?.slippage = formValidationResult.summaryData.estimatedSlippage?.doubleValue
        viewModel?.expectedAmountReceived = formValidationResult.summaryData.estimatedAmountReceived?.doubleValue
        viewModel?.requiresAcknowledgeHighSlippage = formValidationResult.summaryData.needSlippageAck == true

        viewModel?.curMarginUsage = subaccount?.marginUsage?.current?.doubleValue ?? 0
        viewModel?.curFreeCollateral = subaccount?.freeCollateral?.current?.doubleValue ?? 0
        viewModel?.curVaultBalance = vault.account?.balanceUsdc?.doubleValue ?? 0

        viewModel?.postVaultBalance = viewModel?.curVaultBalance == formValidationResult.summaryData.vaultBalance?.doubleValue ? nil : formValidationResult.summaryData.vaultBalance?.doubleValue
        viewModel?.postFreeCollateral = viewModel?.curFreeCollateral == formValidationResult.summaryData.freeCollateral?.doubleValue ? nil : formValidationResult.summaryData.freeCollateral?.doubleValue
        viewModel?.postMarginUsage = viewModel?.curMarginUsage == formValidationResult.summaryData.marginUsage?.doubleValue ? nil : formValidationResult.summaryData.marginUsage?.doubleValue

        viewModel?.submitAction = { [weak self] in
            self?.viewModel?.submitState = .submitting
            Task { [weak self] in
                guard let transferType = self?.transferType else { return }
                let result: Result<Abacus.OnChainTransactionSuccessResponse, ChainError>

                switch transferType {
                case .deposit:
                    guard let subaccountNumber = subaccount?.subaccountNumber, let amount = self?.amount else { return }
                    Tracking.shared?.log(event: AnalyticsEventV2.AttemptVaultOperation(type: transferType.analyticsInputType,
                                                                                       amount: amount,
                                                                                       slippage: nil))
                    result = await CosmoJavascript.shared.depositToMegavault(subaccountNumber: subaccountNumber, amountUsdc: amount)
                case .withdraw:
                    guard let subaccountTo = formValidationResult.submissionData?.withdraw?.subaccountTo,
                          let shares = formValidationResult.submissionData?.withdraw?.shares,
                          let minAmount = formValidationResult.submissionData?.withdraw?.minAmount else { return }
                    Tracking.shared?.log(event: AnalyticsEventV2.AttemptVaultOperation(type: transferType.analyticsInputType,
                                                                                       amount: formValidationResult.summaryData.estimatedAmountReceived?.doubleValue,
                                                                                       slippage: formValidationResult.summaryData.estimatedSlippage?.doubleValue))
                    result = await CosmoJavascript.shared.withdrawFromMegavault(subaccountTo: subaccountTo, shares: shares, minAmount: minAmount)
                }
                DispatchQueue.main.async { [weak self] in
                    switch result {
                    case .success(let chainTransaction):
                        let amount = self?.amount ?? 0
                        let actualAmount = chainTransaction.actualWithdrawalAmount?.doubleValue ?? 0
                        Tracking.shared?.log(event: AnalyticsEventV2.SuccessfulVaultOperation(type: transferType.analyticsInputType,
                                                                                              amount: amount,
                                                                                              amountDiff: actualAmount - amount))
                        Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss", params: ["shouldPrioritizeDismiss": true]), animated: true, completion: nil)
                        AbacusStateManager.shared.refreshVaultAccount()
                    case .failure(let error):
                        self?.viewModel?.submitState = .enabled
                        Tracking.shared?.log(event: AnalyticsEventV2.VaultOperationProtocolError(type: transferType.analyticsInputType))
                        ErrorInfo.shared?.info(title: nil, message: error.message, error: error)
                    }
                }
            }
        }
    }

    /// only necessary for withdrawals
    private func fetchSlippageAndUpdate(formData: Abacus.VaultFormData,
                                        accountData: Abacus.VaultFormAccountData,
                                        subaccount: Abacus.Subaccount,
                                        vault: Abacus.Vault,
                                        hasAcknowledgedHighSlippage: Bool) {
        formValidationRequest = Task { [weak self] in
            guard let self = self, let amount = self.amount else { return }
            let sharesToWithdraw = Abacus.VaultDepositWithdrawFormValidator.shared.calculateSharesToWithdraw(vaultAccount: vault.account, amount: amount)
            let slippageApiResponse = await CosmoJavascript.shared.getMegavaultWithdrawalInfo(sharesToWithdraw: sharesToWithdraw)
            let slippageResponseParsed = Abacus.VaultDepositWithdrawFormValidator.shared.getVaultDepositWithdrawSlippageResponse(apiResponse: slippageApiResponse ?? "")
            let formValidationResult = Abacus.VaultDepositWithdrawFormValidator.shared.validateVaultForm(formData: formData,
                                                                                                         accountData: accountData,
                                                                                                         vaultAccount: vault.account,
                                                                                                         slippageResponse: slippageResponseParsed,
                                                                                                         localizer: DataLocalizer.shared?.asAbacusLocalizer)

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.update(subaccount: subaccount, vault: vault, hasAcknowledgedHighSlippage: hasAcknowledgedHighSlippage, formValidationResult: formValidationResult)
            }
        }
    }
}
