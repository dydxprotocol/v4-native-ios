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
        presenter?.viewModel?.amount = request?.params?["amount"] as? Double
        if request?.path == "/vault/deposit_confirm" {
            presenter?.viewModel?.transferType = .deposit
            return true
        } else if request?.path == "/vault/withdraw_confirm" {
            presenter?.viewModel?.transferType = .withdraw
            return true
        } else {
            return false
        }
    }
}

private protocol dydxVaultDepositWithdrawConfirmationViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxVaultDepositWithdrawConfirmationViewModel? { get }
}

private class dydxVaultDepositWithdrawConfirmationViewPresenter: HostedViewPresenter<dydxVaultDepositWithdrawConfirmationViewModel>, dydxVaultDepositWithdrawConfirmationViewPresenterProtocol {
    static let slippageAcknowledgementThreshold = 1.0
    
    override init() {
        super.init()
        self.viewModel = dydxVaultDepositWithdrawConfirmationViewModel(faqUrl: AbacusStateManager.shared.environment?.links?.vaultLearnMore ?? "")
    }

    override func start() {
        super.start()

        guard let viewModel = viewModel else { return }

        viewModel.slippage = 4.20
        
        viewModel.$transferType
            .sink {[weak self] transferType in
                switch transferType {
                case .deposit:
                    viewModel.submitState = .enabled
                case .withdraw:
                    viewModel.submitState = .loading
                    //TO-DO replace fetch slippage and update view model
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                        guard let self = self else { return }
                        let requiresAcknowledgeHighSlippage = transferType == .withdraw && Double.random(in: 0...1.5) > Self.slippageAcknowledgementThreshold // replace random with actual slippage
                        viewModel.requiresAcknowledgeHighSlippage = requiresAcknowledgeHighSlippage
                        if requiresAcknowledgeHighSlippage && !viewModel.hasAcknowledgedHighSlippage {
                            self.viewModel?.submitState = .disabled
                        } else {
                            self.viewModel?.submitState = .enabled
                        }
                    }
                }
            }
            .store(in: &subscriptions)
        
        // handle slippage toggling
        viewModel.$hasAcknowledgedHighSlippage
            .sink {[weak self] hasAcknowledged in
                guard let viewModel = self?.viewModel, viewModel.requiresAcknowledgeHighSlippage else { return }
                switch viewModel.submitState {
                case .enabled, .disabled:
                    viewModel.submitState = hasAcknowledged ? .enabled : .disabled
                case .submitting, .loading:
                    return
                }
            }
            .store(in: &subscriptions)
        
        

        viewModel.cancelAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }
        
        viewModel.submitAction = { [weak self] in
            //TO-DO replace with v4-clients call to submit deposit, this just simulates it
            self?.viewModel?.submitState = .submitting
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if Int.random(in: 1...6) == 1 {
                    // success
                    Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss_presented"), animated: true, completion: nil)
                } else {
                    // failure
                    self?.viewModel?.isFirstSubmission = false
                    self?.viewModel?.submitState = .enabled
                }
            }
        }
        
        // TODO: replace with real hooks from abacus
        update()
    }

    // TODO: replace with real data from abacus
    func update() {
        guard let viewModel = viewModel else { return }
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

        switch viewModel.transferType {
            case .deposit:
                viewModel.receiptItems = [crossFreeCollateralReceiptItem, crossMarginUsageItem, yourVaultBalanceReceiptItem]
            case .withdraw:
                viewModel.receiptItems = [crossFreeCollateralReceiptItem, yourVaultBalanceReceiptItem, estSlippageReceiptItem, expectedAmountReceivedItem]
        }
    }
}
