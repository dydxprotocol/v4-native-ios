//
//  dydxSimpleUITradeStatusViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 20/01/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Abacus
import dydxStateManager
import FloatingPanel
import PlatformRouting
import Combine
import dydxFormatter

public class dydxSimpleUITradeStatusViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxSimpleUITradeStatusViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxSimpleUITradeStatusViewController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxSimpleUITradeStatusViewController: HostingViewController<PlatformView, dydxSimpleUITradeStatusViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/trade/simple/status" {
            return true
        }
        return false
    }
}

private protocol dydxSimpleUITradeStatusViewPresenterProtocol: HostedViewPresenterProtocol {
    var tradeType: TradeSubmission.TradeType { get set }
    var viewModel: dydxSimpleUITradeStatusViewModel? { get }
}

private class dydxSimpleUITradeStatusViewPresenter: HostedViewPresenter<dydxSimpleUITradeStatusViewModel>, dydxSimpleUITradeStatusViewPresenterProtocol {
    var tradeType: TradeSubmission.TradeType = .trade

    private var submissionDate: Date?
    @Published private var submissionStatus: AbacusStateManager.SubmissionStatus?

    private lazy var submitOrderOnce: () = {
        submissionDate = Date()
        submitOrder()
    }()

    private lazy var doneAction: (() -> Void) = { [weak self] in
        let notificationPermission = NotificationService.shared?.authorization
        if notificationPermission?.authorization == .notDetermined {
            self?.dismissView {
                Router.shared?.navigate(to: RoutingRequest(path: "/authorization/notification", params: nil), animated: true, completion: nil)
            }
        } else {
            self?.dismissView(completion: nil)
        }
    }

    private func dismissView(completion: (() -> Void)?) {
        Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true) { _, _ in
            completion?()
        }

//        switch tradeType {
//            case .trade:
//            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true) {
//                _, _ in
//                completion?()
//            }
//        case .closePosition:
//            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true) {
//                _, _ in
//                Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true) { _, _ in
//                    completion?()
//                }
//            }
//        }
    }

    private lazy var tryAgainAction: (() -> Void) = { [weak self] in
        self?.submitOrder()
    }

    override init() {
        super.init()

        viewModel = dydxSimpleUITradeStatusViewModel()
        viewModel = .previewValue
    }

    private func submitOrder() {
        submissionStatus = nil
        viewModel?.status = .submitting
        viewModel?.ctaButtonViewModel.ctaButtonState = .cancel
        viewModel?.ctaButtonViewModel.ctaAction = doneAction

        switch tradeType {
        case .trade:
            AbacusStateManager.shared.placeOrder(callback: update(status:))
        case .closePosition:
            AbacusStateManager.shared.closePosition(callback: update(status:))
        }
    }

    private func update(status: AbacusStateManager.SubmissionStatus) {
        submissionStatus = status
        switch status {
        case .success:
            viewModel?.status = .success
            viewModel?.ctaButtonViewModel.ctaButtonState = .done
            viewModel?.ctaButtonViewModel.ctaAction = doneAction
            AbacusStateManager.shared.trade(input: nil, type: .size)

            HapticFeedback.shared?.notify(type: .success)

        case .failed(let error):
            viewModel?.status = .failed
            viewModel?.ctaButtonViewModel.ctaButtonState = .tryAgain
            viewModel?.ctaButtonViewModel.ctaAction = tryAgainAction

            HapticFeedback.shared?.notify(type: .error)
            ErrorInfo.shared?.info(title: DataLocalizer.localize(path: "APP.GENERAL.FAILED"),
                                   message: error?.message,
                                   type: .error,
                                   error: nil,
                                   time: 10.0)
        }
    }
}
