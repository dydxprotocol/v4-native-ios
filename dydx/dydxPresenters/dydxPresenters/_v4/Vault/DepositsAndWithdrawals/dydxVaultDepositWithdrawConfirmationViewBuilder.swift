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
import class Abacus.Subaccount

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
    
    override init() {
        super.init()
        
        viewModel = dydxVaultDepositWithdrawConfirmationViewModel()
    }

    override func start() {
        super.start()

        guard let viewModel else { return }
        
        viewModel.amount = amount
        viewModel.faqUrl = AbacusStateManager.shared.environment?.links?.vaultLearnMore ?? ""
        viewModel.transferType = transferType
        
        initializeSubmitState()

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

        // handle slippage toggling
        viewModel.$hasAcknowledgedHighSlippage
            .sink {[weak self] hasAcknowledged in
                self?.update(newHasAcknowledged: hasAcknowledged)
            }
            .store(in: &subscriptions)
        
        AbacusStateManager.shared.state.selectedSubaccount
            .sink { [weak self] selectedSubaccount in
                self?.update(subaccount: selectedSubaccount)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                //TO-DO replace fetch actual slippage and update view model
                let slippage = Double.random(in: 0...0.02) // replace random with actual slippage
                let requiresAcknowledgeHighSlippage = transferType == .withdraw && slippage >= Self.slippageAcknowledgementThreshold
                viewModel.requiresAcknowledgeHighSlippage = requiresAcknowledgeHighSlippage
                viewModel.slippage = slippage
                if requiresAcknowledgeHighSlippage && !viewModel.hasAcknowledgedHighSlippage {
                    self.viewModel?.submitState = .disabled
                } else {
                    self.viewModel?.submitState = .enabled
                }
            }
        }
    }

    // TODO: replace with real data from abacus
    func update(subaccount: Subaccount?) {
        guard let amount,
              let transferType,
              amount > 0,
              // TODO: replace
              let curVaultBalance = Optional(420.0),
              let curFreeCollateral = subaccount?.freeCollateral?.current?.doubleValue,
              let curMarginUsage = subaccount?.marginUsage?.current?.doubleValue
        else {
            assertionFailure()
            return
        }
        
        viewModel?.curMarginUsage = curMarginUsage
        viewModel?.curFreeCollateral = curFreeCollateral
        viewModel?.curVaultBalance = curVaultBalance
        
        switch transferType {
        case .deposit:
            viewModel?.postVaultBalance = curVaultBalance + amount
            viewModel?.postFreeCollateral = curFreeCollateral - amount
            viewModel?.postMarginUsage = curMarginUsage - amount
        case .withdraw:
            viewModel?.postVaultBalance = curVaultBalance - amount
            viewModel?.postFreeCollateral = curFreeCollateral + amount
            viewModel?.postMarginUsage = curMarginUsage + amount
        }
    }
    
    private func update(newHasAcknowledged: Bool) {
        guard let viewModel, newHasAcknowledged else { return }
        switch viewModel.submitState {
        case .enabled, .disabled:
            viewModel.submitState = newHasAcknowledged ? .enabled : .disabled
        case .submitting, .loading:
            return
        }
    }
    
    private func updateSubmitState(slippage: Double?, transferType: VaultTransferType) {
        switch transferType {
        case .deposit:
            viewModel?.submitState = .enabled
        case .withdraw:
            if let slippage = slippage, viewModel?.requiresAcknowledgeHighSlippage == false || viewModel?.hasAcknowledgedHighSlippage == true {
                viewModel?.submitState = .enabled
            } else {
                viewModel?.submitState = .disabled
            }
        }
    }
}
