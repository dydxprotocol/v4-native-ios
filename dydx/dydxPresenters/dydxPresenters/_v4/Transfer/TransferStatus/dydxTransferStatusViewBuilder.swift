//
//  dydxTransferStatusViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 4/18/23.
//
import Abacus
import Combine
import dydxFormatter
import dydxStateManager
import dydxViews
import ParticlesKit
import PlatformParticles
import PlatformUI
import RoutingKit
import Utilities

public class dydxTransferStatusViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxTransferStatusViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxTransferStatusViewController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxTransferStatusViewController: HostingViewController<PlatformView, dydxTransferStatusViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/transfer/status" {
            (presenter as? dydxTransferStatusViewPresenter)?.transactionHash = request?.params?["hash"] as? String
            (presenter as? dydxTransferStatusViewPresenter)?.transferInput = request?.params?["transferInput"] as? TransferInput
            return true
        }
        return false
    }
}

private protocol dydxTransferStatusViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTransferStatusViewModel? { get }
}

private class dydxTransferStatusViewPresenter: HostedViewPresenter<dydxTransferStatusViewModel>, dydxTransferStatusViewPresenterProtocol {
    fileprivate var transactionHash: String?
    fileprivate var transferInput: TransferInput?

    private let receiptPresenter = dydxTransferReceiptViewPresenter()

    private let step1 = ProgressStepViewModel(title: nil,
                                              subtitle: nil,
                                              status: .custom("1"),
                                              tapAction: nil)

    private let step2 = ProgressStepViewModel(title: DataLocalizer.localize(path: "APP.ONBOARDING.BRIDGING_TOKENS"),
                                              subtitle: nil,
                                              status: .custom("2"),
                                              tapAction: nil)

    private let step3 = ProgressStepViewModel(title: nil,
                                              subtitle: nil,
                                              status: .custom("3"),
                                              tapAction: nil)

    override init() {
        let viewModel = dydxTransferStatusViewModel()

        receiptPresenter.$viewModel.assign(to: &viewModel.$receipt)

        super.init()

        self.viewModel = viewModel
        viewModel.steps = [
            step1, step2, step3
        ]

        attachChildren(workers: [receiptPresenter])
    }

    override func start() {
        super.start()

        viewModel?.receipt = nil // hide the receipt for now

        AbacusStateManager.shared.state.transferState
            .prefix(1)
            .sink { [weak self] transferState in
                if let transferInstance = transferState.transfers.first(where: { $0.transactionHash == self?.transactionHash }) {
                    self?.updateTransferInstance(transfer: transferInstance)
                }
            }
            .store(in: &subscriptions)
    }

    private func updateTransferInstance(transfer: dydxTransferInstance) {
        fetchTransferStatus(transfer: transfer)

        updateStepTitles(transfer: transfer)
        switch transfer.transferType {
        case .deposit:
            subscribeToDepositStatus(transfer: transfer)
        case .withdrawal:
            subscribeToWithdrawalStatus(transfer: transfer)
            case .transferOut:
            subscribeToTransferOutStatus(transfer: transfer)
        }

        let maxTimeLapsedInSeconds = 3600.0
        if Date().timeIntervalSince(transfer.date) > maxTimeLapsedInSeconds {
            viewModel?.deleteAction = {
                AbacusStateManager.shared.removeTransferInstance(transfer: transfer)
                Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
            }
        } else {
            viewModel?.deleteAction = nil
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

    private func updateStepTitles(transfer: dydxTransferInstance) {
        switch transfer.transferType {
        case .deposit:
            step1.title = DataLocalizer.localize(path: "APP.ONBOARDING.INITIATED_DEPOSIT")
            step3.title = DataLocalizer.localize(path: "APP.ONBOARDING.DEPOSIT_TO_DYDX")
        case .withdrawal:
            step1.title = DataLocalizer.localize(path: "APP.ONBOARDING.INITIATED_WITHDRAWAL")
            step3.title = DataLocalizer.localize(path: "APP.ONBOARDING.DEPOSIT_TO_DESTINATION",
                                                 params: ["DESTINATION_CHAIN": transfer.toChainName ?? ""])
                                                 case .transferOut:
            step1.title = DataLocalizer.localize(path: "APP.ONBOARDING.INITIATED_TRANSFEROUT")
        }
    }

    private func subscribeToDepositStatus(transfer: dydxTransferInstance) {
        let size = parser.asNumber(transfer.usdcSize ?? transferInput?.size?.usdcSize)?.doubleValue
        if transferInput != nil {
            viewModel?.title = DataLocalizer.localize(path: "APP.V4_DEPOSIT.IN_PROGRESS_TITLE")
            let params = ["AMOUNT_ELEMENT": dydxFormatter.shared.dollar(number: size) ?? ""]
            viewModel?.text = DataLocalizer.localize(path: "APP.V4_DEPOSIT.IN_PROGRESS_TEXT", params: params)
        } else {
            viewModel?.title = DataLocalizer.localize(path: "APP.V4_DEPOSIT.CHECK_STATUS_TITLE")
            viewModel?.text = DataLocalizer.localize(path: "APP.V4_DEPOSIT.CHECK_STATUS_TEXT")
        }

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
                viewModel?.text = DataLocalizer.localize(path: "APP.V4_DEPOSIT.COMPLETED_TEXT")

                step1.status = .completed
                step2.status = .completed
                step3.status = .completed
                viewModel?.completed = true
                deleteTransferInstance(transactionHash: transactionHash)
            } else {
                let size = parser.asNumber(transfer.usdcSize ?? transferInput?.size?.usdcSize)?.doubleValue
                let params = ["AMOUNT_ELEMENT": dydxFormatter.shared.dollar(number: size) ?? ""]
                viewModel?.title = DataLocalizer.localize(path: "APP.V4_DEPOSIT.IN_PROGRESS_TITLE")
                viewModel?.text = DataLocalizer.localize(path: "APP.V4_DEPOSIT.IN_PROGRESS_TEXT", params: params) + " " + status.statusText

                if status.routeStatuses?.first?.status == "success" {
                    step1.status = .completed
                    step2.status = .inProgress
                } else {
                    step1.status = .inProgress
                }

                if let error = status.error {
                    // Skip error on the first status fetch because transaction might not have reached Squid
                    if Date().timeIntervalSince(transfer.date) > 15 {
                        showApiError(error: error)
                    }
                }
            }

            step1.tapAction = createUrlAction(url: status.fromChainStatus?.transactionUrl)
            step2.tapAction = createUrlAction(url: status.axelarTransactionUrl)
            step3.tapAction = createUrlAction(url: status.toChainStatus?.transactionUrl)
        } else {
            step1.status = .inProgress
        }
    }

    private func subscribeToWithdrawalStatus(transfer: dydxTransferInstance) {
        let size = parser.asNumber(transfer.usdcSize ?? transferInput?.size?.usdcSize)?.doubleValue
        if transferInput != nil {
            viewModel?.title = DataLocalizer.localize(path: "APP.V4_WITHDRAWAL.IN_PROGRESS_TITLE")
            let params = ["AMOUNT_ELEMENT": dydxFormatter.shared.dollar(number: size) ?? ""]
            viewModel?.text = DataLocalizer.localize(path: "APP.V4_WITHDRAWAL.IN_PROGRESS_TEXT", params: params)
        } else {
            viewModel?.title = DataLocalizer.localize(path: "APP.V4_WITHDRAWAL.CHECK_STATUS_TITLE")
            viewModel?.text = DataLocalizer.localize(path: "APP.V4_WITHDRAWAL.CHECK_STATUS_TEXT")
        }

        AbacusStateManager.shared.state.transferStatuses
            .sink { [weak self] (statuses: [String: Abacus.TransferStatus]?) in
                let mintscanUrl = AbacusStateManager.shared.environment?.links?.mintscan
                self?.updateWithWithdrawalStatus(transfer: transfer, statuses: statuses, mintscanUrl: mintscanUrl)
            }
            .store(in: &subscriptions)
    }

    private func updateWithWithdrawalStatus(transfer: dydxTransferInstance,
                                            statuses: [String: Abacus.TransferStatus]?,
                                            mintscanUrl: String?) {
        if let transactionHash = transactionHash,
           let status = statuses?[transactionHash] {
            if routeCompleted(transferStatus: status, chainId: transfer.toChainId) {
                viewModel?.title = DataLocalizer.localize(path: "APP.V4_WITHDRAWAL.COMPLETED_TITLE")
                viewModel?.text = DataLocalizer.localize(path: "APP.V4_WITHDRAWAL.COMPLETED_TEXT")
                step1.status = .completed
                step2.status = .completed
                step3.status = .completed
                viewModel?.completed = true
                deleteTransferInstance(transactionHash: transactionHash)
            } else {
                let size = parser.asNumber(transfer.usdcSize ?? transferInput?.size?.usdcSize)?.doubleValue
                let params = ["AMOUNT_ELEMENT": dydxFormatter.shared.dollar(number: size) ?? ""]
                viewModel?.title = DataLocalizer.localize(path: "APP.V4_WITHDRAWAL.IN_PROGRESS_TITLE")
                viewModel?.text = DataLocalizer.localize(path: "APP.V4_WITHDRAWAL.IN_PROGRESS_TEXT", params: params) + " " + status.statusText

                if status.fromChainStatus?.transactionId != nil {
                    step1.status = .completed
                    step2.status = .inProgress
                } else {
                    step1.status = .inProgress
                }

                if let error = status.error {
                    showApiError(error: error)
                }
            }

            step1.tapAction = createUrlAction(url: status.fromChainStatus?.transactionUrl)
            step2.tapAction = createUrlAction(url: status.axelarTransactionUrl)
            step3.tapAction = createUrlAction(url: status.toChainStatus?.transactionUrl)

            Console.shared.log("Transfer status \(String(describing: status.status)), Gas status \(String(describing: status.gasStatus))")
        } else {
            step1.status = .inProgress
        }
    }

    private func subscribeToTransferOutStatus(transfer: dydxTransferInstance) {
        viewModel?.steps = [
            step1
        ]
        viewModel?.completed = true

        let params: [String: String]
        if let usdcSize = transfer.usdcSize {
            params = [
                "AMOUNT_ELEMENT": dydxFormatter.shared.dollar(number: usdcSize) ?? "",
                "TOKEN": dydxTokenConstants.usdcTokenName
            ]
        } else if let size = transfer.size {
            params = [
                "AMOUNT_ELEMENT": dydxFormatter.shared.raw(number: NSNumber(value: size), digits: 2) ?? "",
                "TOKEN": dydxTokenConstants.nativeTokenName
            ]
        } else {
            params = [:]
        }

        viewModel?.title = DataLocalizer.localize(path: "APP.V4_TRANSFEROUT.COMPLETED_TITLE")
        viewModel?.text = DataLocalizer.localize(path: "APP.V4_TRANSFEROUT.COMPLETED_TEXT", params: params)

        let mintscanUrl = AbacusStateManager.shared.environment?.links?.mintscan
        step1.tapAction = createMintScanUrlAction(transfer: transfer, mintscanUrl: mintscanUrl)
        step1.status = .completed

        if transferInput == nil, let transactionHash = transactionHash {
            deleteTransferInstance(transactionHash: transactionHash)
        }
    }

    private func createMintScanUrlAction(transfer: dydxTransferInstance, mintscanUrl: String?) -> (() -> Void)? {
        if AbacusStateManager.shared.isMainNet {
            return nil // TODO:
        } else if let mintscanUrl = mintscanUrl {
            var hash = transfer.transactionHash
            hash.removeFirst(2) // remove "0x"
            let url = mintscanUrl.replacingOccurrences(of: "{tx_hash}", with: hash)
            return createUrlAction(url: url)
        } else {
            return nil
        }
    }

    private func createUrlAction(url: String?) -> (() -> Void)? {
        guard let url = url, let url = URL(string: url) else {
            return nil
        }

        return {
            if URLHandler.shared?.canOpenURL(url) ?? false {
                URLHandler.shared?.open(url, completionHandler: nil)
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

    private func showApiError(error: String) {
        ErrorInfo.shared?.info(title: DataLocalizer.localize(path: "ERRORS.API_STATUS.UNKNOWN_API_ERROR"),
                               message: error,
                               type: .error,
                               error: nil, time: nil)
    }
}

private extension Abacus.TransferStatus {
    var statusText: String {
        #if DEBUG
            return DataLocalizer.localize(path: "APP.GENERAL.STATUS") + ": \(String(describing: status))"
        #else
            return ""
        #endif
    }
}
