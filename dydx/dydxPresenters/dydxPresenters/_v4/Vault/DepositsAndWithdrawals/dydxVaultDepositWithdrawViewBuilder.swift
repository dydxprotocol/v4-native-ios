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
            presenter?.transferType = .deposit
            return true
        } else if request?.path == "/vault/withdraw" {
            presenter?.transferType = .withdraw
            return true
        } else {
            return false
        }
    }
}

private protocol dydxVaultDepositWithdrawViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxVaultDepositWithdrawViewModel? { get }
    var transferType: VaultTransferType { get set }
}

private class dydxVaultDepositWithdrawViewPresenter: HostedViewPresenter<dydxVaultDepositWithdrawViewModel>, dydxVaultDepositWithdrawViewPresenterProtocol {
    var transferType: VaultTransferType = .deposit

    override init() {
        let viewModel = dydxVaultDepositWithdrawViewModel(selectedTransferType: transferType, submitState: .disabled)

        super.init()

        self.viewModel = viewModel
    }
    
    override func start() {
        super.start()
                
        //TODO: replace with real hooks from abacus
        update()
    }
    
    //TODO: replace with real data from abacus
    func update() {
        var newInputReceiptChangeItems = [dydxReceiptChangeItemView]()
        var newButtonReceiptChangeItems = [dydxReceiptChangeItemView]()
        
        newInputReceiptChangeItems.append(dydxReceiptChangeItemView(title: DataLocalizer.localize(path: "APP.VAULTS.YOUR_VAULT_BALANCE"),
                                                         value: AmountChangeModel(before: AmountTextModel(amount: 30.01),
                                                                      after: AmountTextModel(amount: 30.02))))
        
        newButtonReceiptChangeItems.append(.init(title: DataLocalizer.localize(path: "APP.GENERAL.CROSS_FREE_COLLATERAL"),
                                                         value: AmountChangeModel(before: AmountTextModel(amount: 30.01),
                                                                      after: AmountTextModel(amount: 30.02))))
        
        newButtonReceiptChangeItems.append(.init(title: DataLocalizer.localize(path: "APP.VAULTS.EST_SLIPPAGE"),
                                                         value: AmountChangeModel(before: AmountTextModel(amount: 30.01),
                                                                      after: AmountTextModel(amount: 30.02))))
        
        newButtonReceiptChangeItems.append(.init(title: DataLocalizer.localize(path: "APP.WITHDRAW_MODAL.EXPECTED_AMOUNT_RECEIVED"),
                                                         value: AmountChangeModel(before: AmountTextModel(amount: 30.01),
                                                                      after: AmountTextModel(amount: 30.02))))
        
        viewModel?.inputReceiptChangeItems = newInputReceiptChangeItems
        viewModel?.buttonReceiptChangeItems = newButtonReceiptChangeItems
        
        viewModel?.inputInlineAlert = InlineAlertViewModel(InlineAlertViewModel.Config.init(title: "test alert",
                                                                                            body: "test bodytest bodytest bodytest bodytest bodytest bodytest bodytest bodytest bodytest bodytest bodytest bodytest bodytest bodytest bodytest bodytest body",
                                                                                            level: .error))
    }
}
