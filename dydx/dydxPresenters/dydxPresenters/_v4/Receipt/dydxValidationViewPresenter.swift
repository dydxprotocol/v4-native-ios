//
//  dydxValidationViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 1/25/23.
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

protocol dydxValidationViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxValidationViewModel? { get }
}

class dydxValidationViewPresenter: HostedViewPresenter<dydxValidationViewModel>, dydxValidationViewPresenterProtocol {
    enum TradeReceiptType {
        case open
        case close
    }

    enum ReceiptType {
        case trade(TradeReceiptType), transfer
    }

    private let receiptPresenter: dydxReceiptPresenter
    private let receiptType: ReceiptType

    init(receiptType: ReceiptType) {
        self.receiptType = receiptType
        switch receiptType {
        case let .trade(tradeReceiptType):
            receiptPresenter = dydxTradeReceiptPresenter(tradeReceiptType: tradeReceiptType)
        case .transfer:
            receiptPresenter = dydxTransferReceiptViewPresenter()
        }
        let viewModel = dydxValidationViewModel()

        receiptPresenter.$viewModel.assign(to: &viewModel.$receiptViewModel)

        super.init()

        self.viewModel = viewModel
    }

    override func start() {
        super.start()

        Publishers.CombineLatest3(
            AbacusStateManager.shared.state.selectedSubaccount,
            AbacusStateManager.shared.state.validationErrors,
            AbacusStateManager.shared.state.transferInput
                .removeDuplicates()
        )
        .sink { [weak self] subaccount, validationErrors, transferInput in
            let customErrors = self?.customErrors(subaccount: subaccount) ?? []
            self?.update(errors: customErrors.count > 0 ? customErrors : validationErrors, transferInput: transferInput)
        }
        .store(in: &subscriptions)

        receiptPresenter.start()
    }

    override func stop() {
        super.stop()

        receiptPresenter.stop()
    }

    private func customErrors(subaccount: Subaccount?) -> [ValidationError] {
        if dydxBoolFeatureFlag.enable_spot_experience.isEnabled {
            if (subaccount?.quoteBalance?.postOrder?.doubleValue ?? 0.0) < 0.0 {
                return [
                    ValidationError(
                        code: "ERROR_NOT_ENOUGH_FUND",
                        type: ErrorType.error,
                        fields: ["size.size"],
                        action: nil,
                        link: nil,
                        resources: ErrorResources(
                            title: ErrorString(stringKey: "NOT_ENOUGH_FUND_TITLE", params: nil, localized: "Not enough fund"),
                            text: ErrorString(stringKey: "NOT_ENOUGH_FUND_TEXT", params: nil, localized: "Not enough fund to execute the order"),
                            action: nil)
                    )
                ]
            } else if let shortPosition = subaccount?.openPositions?.first(where: { position in
                    position.side.postOrder == PositionSide.short_
            }) {
                return [
                    ValidationError(
                        code: "ERROR_NOT_ENOUGH_POSITION",
                        type: ErrorType.error,
                        fields: ["size.size"],
                        action: nil,
                        link: nil,
                        resources: ErrorResources(
                            title: ErrorString(stringKey: "ERROR_NOT_ENOUGH_POSITION_TITLE", params: nil, localized: "Overselling"),
                            text: ErrorString(stringKey: "ERROR_NOT_ENOUGH_POSITION_TEXT", params: nil, localized: "You cannot sell more than you have"),
                            action: nil)
                    )
                ]
            } else {
                return []
            }
        } else {
            return []
        }
    }

    private func update(errors: [ValidationError], transferInput: TransferInput?) {
        let transferErrors = transferInput?.errors
        let errorMessage = transferInput?.errorMessage
        let firstBlockingError = errors.first { $0.type == ErrorType.error }
        let firstWarning = errors.first { $0.type == ErrorType.warning }
        if let firstBlockingError = firstBlockingError {
            viewModel?.title = firstBlockingError.resources.title?.localizedString
            viewModel?.text = firstBlockingError.resources.text?.localizedString
            viewModel?.errorType = .error
            if viewModel?.state == .hide {
                viewModel?.state = .showError
            }
        } else if let firstWarning = firstWarning {
            viewModel?.title = firstWarning.resources.title?.localizedString
            viewModel?.text = firstWarning.resources.text?.localizedString
            viewModel?.errorType = .warning
            if viewModel?.state == .hide {
                viewModel?.state = .showError
            }
        } else if let transferErrors = transferErrors, transferErrors.count > 0 {
            viewModel?.title = DataLocalizer.localize(path: "ERRORS.GENERAL.SOMETHING_WENT_WRONG_WITH_MESSAGE",
                                                      params: ["ERROR_MESSAGE": ""])
            viewModel?.text = errorMessage ?? transferErrors
            viewModel?.errorType = .error
            if viewModel?.state == .hide {
                viewModel?.state = .showError
            }
        } else {
            viewModel?.state = .hide
        }
    }
}
