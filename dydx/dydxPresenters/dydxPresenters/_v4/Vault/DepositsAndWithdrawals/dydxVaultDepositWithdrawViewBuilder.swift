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
// import single class due to VaultTransferType collision
import class Abacus.Subaccount

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
    override init() {
        super.init()

        let viewModel = dydxVaultDepositWithdrawViewModel()

        self.viewModel = viewModel
    }

    override func start() {
        super.start()
        guard let viewModel = viewModel else { return }
        
        Publishers.CombineLatest3(AbacusStateManager.shared.state.selectedSubaccount, viewModel.$amount, viewModel.$selectedTransferType)
            .sink { [weak self] selectedSubaccount, amount, transferType in
                self?.update(subaccount: selectedSubaccount, amount: amount ?? 0, transferType: transferType)
            }
            .store(in: &subscriptions)
    }

    // TODO: replace with real data from abacus
    func update(subaccount: Subaccount?, amount: Double, transferType: VaultTransferType) {
        viewModel?.maxAmount = subaccount?.freeCollateral?.current?.doubleValue ?? 0

        updateSubmitState(amount: amount)
        updateReceiptItems(subaccount: subaccount, amount: amount, transferType: transferType)
        updateSubmitAction(amount: amount, transferType: transferType)

        viewModel?.inputInlineAlert = InlineAlertViewModel(InlineAlertViewModel.Config.init(title: "test alert",
                                                                                            body: "test bodytest bodytest bodytest bodytest bodytest bodytest bodytest bodytest bodytest bodytest bodytest bodytest bodytest bodytest bodytest bodytest body",
                                                                                            level: .error))
    }
    
    private func updateSubmitState(amount: Double) {
        if amount > 0 {
            viewModel?.submitState = .enabled
        } else {
            viewModel?.submitState = .disabled
        }
    }
    
    private func updateReceiptItems(subaccount: Subaccount?, amount: Double, transferType: VaultTransferType) {
        guard let curVaultBalance = Optional(420.0),
              let curFreeCollateral = subaccount?.freeCollateral?.current?.doubleValue,
              let curMarginUsage = subaccount?.marginUsage?.current?.doubleValue
        else { return }
        
        var newInputReceiptChangeItems = [dydxReceiptChangeItemView]()
        var newButtonReceiptChangeItems = [dydxReceiptChangeItemView]()

        let preTransferVaultBalance = AmountTextModel(amount: curVaultBalance.asNsNumber)
        let preTransferFreeCollateral = AmountTextModel(amount: curFreeCollateral.asNsNumber)
        let preTransferMarginUsage = AmountTextModel(amount: curMarginUsage.asNsNumber)
        
        let postTransferVaultBalance: AmountTextModel?
        let postTransferFreeCollateral: AmountTextModel?
        let postTransferMarginUsage: AmountTextModel?
        
        if amount > 0 {
            switch transferType {
            case .deposit:
                postTransferVaultBalance = AmountTextModel(amount: (curVaultBalance + amount).asNsNumber)
                postTransferFreeCollateral = AmountTextModel(amount: (curFreeCollateral - amount).asNsNumber)
                //TODO: this is wrong calculation
                postTransferMarginUsage = AmountTextModel(amount: (curMarginUsage - amount).asNsNumber)
            case .withdraw:
                postTransferVaultBalance = AmountTextModel(amount: (curVaultBalance - amount).asNsNumber)
                postTransferFreeCollateral = AmountTextModel(amount: (curFreeCollateral + amount).asNsNumber)
                //TODO: this is wrong calculation
                postTransferMarginUsage = AmountTextModel(amount: (curMarginUsage + amount).asNsNumber)
            }
        } else {
            postTransferVaultBalance = nil
            postTransferFreeCollateral = nil
            postTransferMarginUsage = nil
        }
        
        let vaultBalanceReceiptItem = dydxReceiptChangeItemView(title: DataLocalizer.localize(path: "APP.VAULTS.YOUR_VAULT_BALANCE"),
                                                                    value: AmountChangeModel(before: preTransferVaultBalance, after: postTransferVaultBalance))
        let freeCollateralReceiptItem = dydxReceiptChangeItemView(title: DataLocalizer.localize(path: "APP.GENERAL.FREE_COLLATERAL"),
                                                                    value: AmountChangeModel(before: preTransferFreeCollateral, after: postTransferFreeCollateral))
        let marginUsageReceiptItem = dydxReceiptChangeItemView(title: DataLocalizer.localize(path: "APP.GENERAL.MARGIN_USAGE"),
                                                                    value: AmountChangeModel(before: preTransferMarginUsage, after: postTransferMarginUsage))
        
        switch transferType {
        case .deposit:
            newInputReceiptChangeItems.append(freeCollateralReceiptItem)
            newButtonReceiptChangeItems.append(marginUsageReceiptItem)
            newButtonReceiptChangeItems.append(vaultBalanceReceiptItem)
        case .withdraw:
            newInputReceiptChangeItems.append(vaultBalanceReceiptItem)
            newButtonReceiptChangeItems.append(freeCollateralReceiptItem)
            newButtonReceiptChangeItems.append(marginUsageReceiptItem)
        }

//        newButtonReceiptChangeItems.append(dydxReceiptChangeItemView(title: DataLocalizer.localize(path: "APP.VAULTS.EST_SLIPPAGE"),
//                                                         value: AmountChangeModel(before: AmountTextModel(amount: 30.01),
//                                                                      after: AmountTextModel(amount: 30.02))))

//        newButtonReceiptChangeItems.append(dydxReceiptChangeItemView(title: DataLocalizer.localize(path: "APP.WITHDRAW_MODAL.EXPECTED_AMOUNT_RECEIVED"),
//                                                         value: AmountChangeModel(before: AmountTextModel(amount: 30.01),
//                                                                      after: AmountTextModel(amount: 30.02))))

        viewModel?.inputReceiptChangeItems = newInputReceiptChangeItems
        viewModel?.buttonReceiptChangeItems = newButtonReceiptChangeItems
    }
        
    private func updateSubmitAction(amount: Double, transferType: VaultTransferType) {
        viewModel?.submitAction = {
            Router.shared?.navigate(to: RoutingRequest(path: transferType.confirmScreenPath, params: ["amount": amount]), animated: true, completion: nil)
        }
    }
}

private extension VaultTransferType {    
    var confirmScreenPath: String {
        switch self {
        case .deposit: return "/vault/deposit_confirm"
        case .withdraw: return "/vault/withdraw_confirm"
        }
    }
}
