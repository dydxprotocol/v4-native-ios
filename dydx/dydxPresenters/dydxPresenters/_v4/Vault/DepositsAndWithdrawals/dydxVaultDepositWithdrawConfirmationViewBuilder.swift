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
    var transferType: VaultTransferType { get set }
}

private class dydxVaultDepositWithdrawConfirmationViewPresenter: HostedViewPresenter<dydxVaultDepositWithdrawConfirmationViewModel>, dydxVaultDepositWithdrawConfirmationViewPresenterProtocol {
    var transferType: VaultTransferType = .deposit {
        didSet {
            viewModel?.transferType = transferType
        }
    }

    override init() {

        super.init()

        let viewModel = dydxVaultDepositWithdrawConfirmationViewModel(transferType: transferType)

        viewModel.cancelAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }  
        
        //TODO: replace
        viewModel.elevatedSlippageAmount = 4.20
        viewModel.requiresAcknowledgeHighSlippage = true
        
        self.viewModel = viewModel
    }
    
    override func start() {
        super.start()
                
        //TODO: replace with real hooks from abacus
        update()
    }
    
    //TODO: replace with real data from abacus
    func update() {
        let crossFreeCollateralReceiptItem = dydxReceiptChangeItemView(title: DataLocalizer.localize(path: "APP.GENERAL.CROSS_FREE_COLLATERAL"),
                                                                      value: AmountChangeModel(before: AmountTextModel(amount: 30.01),
                                                                                               after: AmountTextModel(amount: 30.02)))
        let yourVaultBalanceReceiptItem = dydxReceiptChangeItemView(title: DataLocalizer.localize(path: "APP.VAULTS.YOUR_VAULT_BALANCE"),
                                                                    value: AmountChangeModel(before: AmountTextModel(amount: 30.01),
                                                                                             after: AmountTextModel(amount: 30.02)))
        let estSlippageReceiptItem = dydxReceiptChangeItemView(title: DataLocalizer.localize(path: "APP.VAULTS.EST_SLIPPAGE"),
                                                              value: AmountChangeModel(before: AmountTextModel(amount: 30.01),
                                                                                       after: AmountTextModel(amount: 30.02)))
        let expectedAmountReceivedItem = dydxReceiptChangeItemView(title: DataLocalizer.localize(path: "APP.WITHDRAW_MODAL.EXPECTED_AMOUNT_RECEIVED"),
                                                                   value: AmountChangeModel(before: AmountTextModel(amount: 30.01),
                                                                                            after: AmountTextModel(amount: 30.02)))
        let crossMarginUsageItem = dydxReceiptChangeItemView(title: DataLocalizer.localize(path: "APP.GENERAL.CROSS_MARGIN_USAGE"),
                                                             value: AmountChangeModel(before: AmountTextModel(amount: 30.01),
                                                                                      after: AmountTextModel(amount: 30.02)))
        
        switch transferType {
            case .deposit:
                viewModel?.receiptItems = [crossFreeCollateralReceiptItem, crossMarginUsageItem, yourVaultBalanceReceiptItem]
            case .withdraw:
                viewModel?.receiptItems = [crossFreeCollateralReceiptItem, yourVaultBalanceReceiptItem, estSlippageReceiptItem, expectedAmountReceivedItem]
        }
    }
}
