//
//  dydxValidationViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 1/25/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Abacus
import Combine
import dydxStateManager

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
        case .trade(let tradeReceiptType):
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

        Publishers.CombineLatest(
            AbacusStateManager.shared.state.validationErrors,
            AbacusStateManager.shared.state.transferInput
               .removeDuplicates()
        )
        .sink { [weak self] validationErrors, transferInput in
            self?.update(errors: validationErrors, transferInput: transferInput)
        }
        .store(in: &subscriptions)

        receiptPresenter.start()
    }

    override func stop() {
        super.stop()

        receiptPresenter.stop()
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
            if let hyperlinkText = firstBlockingError.linkText,
                let link = firstBlockingError.link {
                viewModel?.hyperlinkText = hyperlinkText
                viewModel?.validationViewDescriptionHyperlinkAction = {
                    Router.shared?.navigate(to: URL(string: link), completion: nil)
                }
            }
            if viewModel?.state == .hide {
                viewModel?.state = .showError
            }
        } else if let firstWarning = firstWarning {
            viewModel?.title = firstWarning.resources.title?.localizedString
            viewModel?.text = firstWarning.resources.text?.localizedString
            viewModel?.errorType = .warning
            viewModel?.hyperlinkText = firstWarning.linkText
            if let hyperlinkText = firstWarning.linkText,
                let link = firstWarning.link {
                viewModel?.hyperlinkText = hyperlinkText
                viewModel?.validationViewDescriptionHyperlinkAction = {
                    Router.shared?.navigate(to: URL(string: link), completion: nil)
                }
            }
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
