//
//  dydxTransferInstantStatusViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 27/02/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Abacus
import Combine
import dydxFormatter
import dydxStateManager
import dydxAnalytics

public class dydxTransferInstantStatusViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxTransferInstantStatusViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxTransferInstantStatusViewController(presenter: presenter, view: view, configuration: .fullScreenSheet) as? T
    }
}

private class dydxTransferInstantStatusViewController: HostingViewController<PlatformView, dydxTransferInstantStatusViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/transfer/status/instant" {
            (presenter as? dydxTransferInstantStatusViewPresenter)?.transactionHash = request?.params?["hash"] as? String
            (presenter as? dydxTransferInstantStatusViewPresenter)?.transferInput = request?.params?["transferInput"] as? TransferInput
            return true
        }
        return false
    }
}

private protocol dydxTransferInstantStatusViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTransferInstantStatusViewModel? { get }
}

private class dydxTransferInstantStatusViewPresenter: HostedViewPresenter<dydxTransferInstantStatusViewModel>, dydxTransferInstantStatusViewPresenterProtocol {
    @Published fileprivate var transactionHash: String?
    @Published fileprivate var transferInput: TransferInput?

    override init() {
        super.init()

        viewModel = dydxTransferInstantStatusViewModel()
        viewModel?.ctaButtonViewModel.ctaAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }
        viewModel?.ctaButtonViewModel.ctaButtonState = .done
        viewModel?.simpleUI = dydxBoolFeatureFlag.simple_ui.isEnabled && AppMode.current == .simple
    }

    override func start() {
        super.start()

        guard let transferTokenDetails = TransferTokenDetails.shared else {
            return
        }

        Publishers
            .CombineLatest(
                transferTokenDetails.infos,
                $transferInput)
            .sink { [weak self] infos, input in
                guard let input = input else { return }
                switch input.type {
                case .deposit:
                    let tokenInfo = infos.first { $0.tokenAddress == input.token && $0.chainId == input.chain }
                    self?.viewModel?.label = DataLocalizer.localize(path: "APP.ONBOARDING.YOUR_DEPOSIT")
                    self?.updateInputToken(transferInput: input, token: tokenInfo)
                default:
                    break
                }
            }
            .store(in: &subscriptions)

        Publishers
            .Zip3(AbacusStateManager.shared.state.transferState.prefix(1),
                                  $transactionHash.compactMap { $0 },
                                  $transferInput.compactMap { $0 })
            .sink { [weak self] transferState, hash, transferInput in
                let size = self?.parser.asNumber(transferInput?.size?.usdcSize)?.doubleValue
                self?.viewModel?.title = DataLocalizer.localize(path: "APP.V4_DEPOSIT.IN_PROGRESS_TITLE")
                let params = ["AMOUNT_ELEMENT": dydxFormatter.shared.dollar(number: size) ?? ""]
                self?.viewModel?.subtitle = DataLocalizer.localize(path: "APP.DEPOSIT_MODAL.YOUR_FUNDS_AVAILABLE_SOON", params: params)

                if let transferInstance = transferState.transfers.first(where: { $0.transactionHash == hash }) {
                    self?.updateTransferInstance(transfer: transferInstance)
                }
            }
            .store(in: &subscriptions)
    }

    private func updateTransferInstance(transfer: dydxTransferInstance) {
        fetchTransferStatus(transfer: transfer)

        switch transfer.transferType {
        case .deposit:
            subscribeToDepositStatus(transfer: transfer)
        default:
            break
        }
    }

    private func updateInputToken(transferInput: TransferInput, token: TransferTokenInfo?) {
        viewModel?.token = token?.token.rawValue
        if let tokenLogoUrl = token?.tokenLogoUrl {
            viewModel?.tokenIcon = URL(string: tokenLogoUrl)
        }
        if let chainLogoUrl = token?.chainLogoUrl {
            viewModel?.chainIcon = URL(string: chainLogoUrl)
        }
        let size: Double = parser.asNumber(transferInput.size?.size)?.doubleValue ?? 0
        if size > 0 {
            viewModel?.amount = dydxFormatter.shared.raw(number: NSNumber(value: size), size: "0.001")
        } else {
            viewModel?.amount = nil
        }
    }

    private func fetchTransferStatus(transfer: dydxTransferInstance) {
        Timer.publish(every: 30, triggerNow: true)
            .sink { _ in
                AbacusStateManager.shared.transferStatus(hash: transfer.transactionHash,
                                                         fromChainId: transfer.fromChainId,
                                                         toChainId: transfer.toChainId,
                                                         isCctp: transfer.isCctp ?? false,
                                                         requestId: transfer.requestId)
            }
            .store(in: &subscriptions)
    }

    private func subscribeToDepositStatus(transfer: dydxTransferInstance) {
        AbacusStateManager.shared.state.transferStatuses
            .sink { [weak self] (statuses: [String: Abacus.TransferStatus]?) in
                self?.updateWithDepositStatus(transfer: transfer, statuses: statuses)
            }
            .store(in: &subscriptions)
    }

    private func updateWithDepositStatus(transfer: dydxTransferInstance,
                                         statuses: [String: Abacus.TransferStatus]?) {
        if let transactionHash = transactionHash,
           let status = statuses?[transactionHash] {
            if routeCompleted(transferStatus: status, chainId: transfer.toChainId) {
                viewModel?.title = DataLocalizer.localize(path: "APP.V4_DEPOSIT.COMPLETED_TITLE")
                viewModel?.subtitle = DataLocalizer.localize(path: "APP.V4_DEPOSIT.COMPLETED_TEXT")
                viewModel?.status = .success
                deleteTransferInstance(transactionHash: transactionHash)

                Tracking.shared?.logSharedEvent(ClientTrackableEventType.DepositFinalizedEvent(status: status))
            }
        }
    }

    private func routeCompleted(transferStatus: Abacus.TransferStatus, chainId: String?) -> Bool {
        if transferStatus.squidTransactionStatus == "success" {
            return true
        }

        if transferStatus.status?.contains("executed") ?? false,
           let lastStatus = transferStatus.routeStatuses?.last,
           lastStatus.chainId == chainId,
           lastStatus.status == "success" {
            return true
        }

        return false
    }

    private func deleteTransferInstance(transactionHash: String) {
        AbacusStateManager.shared.state.transferInstance(transactionHash: transactionHash)
            .prefix(1)
            .sink { transferInstance in
                if let transferInstance = transferInstance {
                    AbacusStateManager.shared.removeTransferInstance(transfer: transferInstance)
                }
            }
            .store(in: &subscriptions)
    }
}
