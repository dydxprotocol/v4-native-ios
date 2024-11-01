//
//  dydxVaultDepositWithdrawViewBuilder.swift
//  dydxPresenters
//
//  Created by Michael Maguire on 8/22/24.
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
import Abacus
import dydxAnalytics

public class dydxVaultDepositWithdrawViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxVaultDepositWithdrawViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        let viewController = dydxVaultDepositWithdrawViewController(presenter: presenter, view: view, configuration: .default)
        return viewController as? T
    }
}

private class dydxVaultDepositWithdrawViewController: HostingViewController<PlatformView, dydxVaultDepositWithdrawViewModel> {

    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        let presenter = presenter as? dydxVaultDepositWithdrawViewPresenterProtocol
        if request?.path == "/vault/deposit" {
            presenter?.viewModel?.selectedTransferType = .deposit
            return true
        } else if request?.path == "/vault/withdraw" {
            presenter?.viewModel?.selectedTransferType = .withdraw
            return true
        } else {
            return false
        }
    }
}

private protocol dydxVaultDepositWithdrawViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxVaultDepositWithdrawViewModel? { get }
}

private class dydxVaultDepositWithdrawViewPresenter: HostedViewPresenter<dydxVaultDepositWithdrawViewModel>, dydxVaultDepositWithdrawViewPresenterProtocol {
    private var formValidationRequest: Task<Void, Never>?
    private var aggregatePublisherCancellable: AnyCancellable?

    override init() {
        super.init()

        let viewModel = dydxVaultDepositWithdrawViewModel()

        self.viewModel = viewModel
    }

    override func start() {
        super.start()
        guard let viewModel = viewModel else { return }

        viewModel.$selectedTransferType
            .removeDuplicates()
            .sink { [weak self] transferType in
                self?.aggregatePublisherCancellable?.cancel()

                // transfer types determin throttling/debounce config
                // do not need debouncing/throttling for deposit since there are no slippage fetches
                // for withdrawal, refetch slippage every ~2 seconds if subaccount or vault changes during a 2 second period
                // for withdrawal, refetch slippage after input changes (debounced)
                let vaultAndSubaccountPublisher = Publishers.CombineLatest(AbacusStateManager.shared.state.selectedSubaccount,
                                                                           AbacusStateManager.shared.state.vault.compactMap({ $0 }))
                    .map { (subaccount: $0, vault: $1) }
                    .throttle(for: transferType == .deposit ? 0 : 2, scheduler: DispatchQueue.main, latest: true)

                let amountPublisher = viewModel.$amount
                    .debounce(for: transferType == .deposit ? 0 : 0.5, scheduler: DispatchQueue.main).removeDuplicates()

                self?.aggregatePublisherCancellable = Publishers.CombineLatest3(vaultAndSubaccountPublisher, AbacusStateManager.shared.state.onboarded, amountPublisher)
                    .sink(receiveValue: { vaultAndSubaccount, onboarded, amount in
                        self?.update(subaccount: vaultAndSubaccount.subaccount, vault: vaultAndSubaccount.vault, hasOnboarded: onboarded, amount: amount ?? 0, transferType: transferType)
                    })
            }
            .store(in: &subscriptions)

    }

    private func update(subaccount: Subaccount?, vault: Abacus.Vault, hasOnboarded: Bool, amount: Double, transferType: dydxViews.VaultTransferType) {
        formValidationRequest?.cancel()

        let accountData = Abacus.VaultFormAccountData(marginUsage: subaccount?.marginUsage?.current ?? 0,
                                                      freeCollateral: subaccount?.freeCollateral?.current ?? 0,
                                                      canViewAccount: hasOnboarded.asKotlinBoolean)

        let formData = VaultFormData(action: transferType.formAction,
                                     amount: KotlinDouble(value: amount),
                                     acknowledgedSlippage: false,
                                     acknowledgedTerms: false,
                                     inConfirmationStep: false)

        switch transferType {
        case .deposit:
            let formValidationResult = Abacus.VaultDepositWithdrawFormValidator.shared.validateVaultForm(formData: formData,
                                                                                         accountData: accountData,
                                                                                         vaultAccount: vault.account,
                                                                                         slippageResponse: nil,
                                                                                         localizer: DataLocalizer.shared?.asAbacusLocalizer)
            self.update(subaccount: subaccount,
                        vault: vault,
                        hasOnboarded: hasOnboarded,
                        amount: amount,
                        transferType: transferType,
                        formValidationResult: formValidationResult)
        case .withdraw:
            fetchSlippageAndUpdate(formData: formData,
                                   accountData: accountData,
                                   subaccount: subaccount,
                                   hasOnboarded: hasOnboarded,
                                   vault: vault,
                                   amount: amount,
                                   transferType: transferType)
        }
    }

    /// only necessary for withdrawals
    private func fetchSlippageAndUpdate(formData: Abacus.VaultFormData,
                                        accountData: Abacus.VaultFormAccountData,
                                        subaccount: Abacus.Subaccount?,
                                        hasOnboarded: Bool,
                                        vault: Abacus.Vault,
                                        amount: Double,
                                        transferType: dydxViews.VaultTransferType
    ) {
        formValidationRequest = Task {
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
                self.update(subaccount: subaccount,
                            vault: vault,
                            hasOnboarded: hasOnboarded,
                            amount: amount,
                            transferType: transferType,
                            formValidationResult: formValidationResult)
            }
        }
    }

    private func update(subaccount: Subaccount?, vault: Abacus.Vault, hasOnboarded: Bool, amount: Double, transferType: dydxViews.VaultTransferType, formValidationResult: VaultFormValidationResult) {
        updateMaxAmount(subaccount: subaccount, vault: vault, transferType: transferType)
        updateSubmitState(formValidationResult: formValidationResult)
        updateReceiptItems(formValidationResult: formValidationResult, subaccount: subaccount, vault: vault, amount: amount, transferType: transferType)
        updateSubmitAction(amount: amount, transferType: transferType)
        updateErrorAlert(formValidationResult: formValidationResult)
    }

    private func updateMaxAmount(subaccount: Abacus.Subaccount?, vault: Abacus.Vault?, transferType: dydxViews.VaultTransferType) {
        switch transferType {
        case .deposit:
            viewModel?.maxAmount = subaccount?.roundedFreeCollateral ?? 0
        case .withdraw:
            viewModel?.maxAmount = vault?.account?.roundedWithdrawableUsdc ?? 0
        }
    }

    private func updateSubmitState(formValidationResult: VaultFormValidationResult) {
        viewModel?.submitState = formValidationResult.errors.isEmpty ? .enabled : .disabled
    }

    private func updateReceiptItems(formValidationResult: VaultFormValidationResult, subaccount: Abacus.Subaccount?, vault: Abacus.Vault, amount: Double, transferType: dydxViews.VaultTransferType) {
        viewModel?.curVaultBalance = vault.account?.roundedWithdrawableUsdc ?? 0
        viewModel?.curFreeCollateral = subaccount?.roundedFreeCollateral ?? 0
        viewModel?.curMarginUsage = subaccount?.marginUsage?.current?.doubleValue ?? 0

        viewModel?.postVaultBalance =
            dydxFormatter.shared.raw(number: vault.account?.roundedWithdrawableUsdc, digits: 2) ==
            dydxFormatter.shared.raw(number: formValidationResult.summaryData.vaultBalance?.doubleValue, digits: 2)
            ? nil : formValidationResult.summaryData.vaultBalance?.doubleValue
        viewModel?.postFreeCollateral =
            dydxFormatter.shared.raw(number: subaccount?.roundedFreeCollateral, digits: 2) ==
            dydxFormatter.shared.raw(number: formValidationResult.summaryData.freeCollateral?.doubleValue, digits: 2)
            ? nil : formValidationResult.summaryData.freeCollateral?.doubleValue
        viewModel?.postMarginUsage = viewModel?.curMarginUsage == formValidationResult.summaryData.marginUsage?.doubleValue ? nil : formValidationResult.summaryData.marginUsage?.doubleValue

        viewModel?.slippage = formValidationResult.summaryData.estimatedSlippage?.doubleValue
        viewModel?.expectedAmountReceived = formValidationResult.summaryData.estimatedAmountReceived?.doubleValue
    }

    private func updateSubmitAction(amount: Double, transferType: dydxViews.VaultTransferType) {
        viewModel?.submitAction = {
            Tracking.shared?.log(event: AnalyticsEventV2.VaultFormPreviewStep(amount: amount, type: transferType.analyticsInputType))
            Router.shared?.navigate(to: RoutingRequest(path: transferType.confirmScreenPath, params: ["amount": amount]), animated: true, completion: nil)
        }
    }

    private func updateErrorAlert(formValidationResult: VaultFormValidationResult) {
        guard let error = formValidationResult.errors.first, viewModel?.amount != nil else {
            viewModel?.inputInlineAlert = nil
            return
        }
        viewModel?.inputInlineAlert = InlineAlertViewModel(.init(title: error.resources.title?.localizedString, body: error.resources.text?.localizedString, level: .error))
    }
}

extension dydxViews.VaultTransferType {
    fileprivate var confirmScreenPath: String {
        switch self {
        case .deposit: return "/vault/deposit_confirm"
        case .withdraw: return "/vault/withdraw_confirm"
        }
    }

    var formAction: Abacus.VaultFormAction {
        switch self {
        case .deposit: return .deposit
        case .withdraw: return .withdraw
        }
    }
}

extension VaultAccount {
    var roundedWithdrawableUsdc: Double? {
        withdrawableUsdc?.doubleValue.round(to: 2, rule: .towardZero)
    }
}

extension Abacus.Subaccount {
    var roundedFreeCollateral: Double? {
        freeCollateral?.current?.doubleValue.round(to: 2, rule: .towardZero)
    }
}
