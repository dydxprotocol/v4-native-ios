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
import dydxAnalytics

public class dydxSimpleUITradeStatusViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxSimpleUITradeStatusViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxSimpleUITradeStatusViewController(presenter: presenter, view: view, configuration: .fullScreenSheet) as? T
    }
}

private class dydxSimpleUITradeStatusViewController: HostingViewController<PlatformView, dydxSimpleUITradeStatusViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        guard let presenter = presenter as? dydxSimpleUITradeStatusViewPresenter else {
            return false
        }
        if request?.path == "/trade/simple/status" {
            presenter.tradeType = .trade
            return true
        } else if request?.path == "/closePosition/simple/status" {
            presenter.tradeType = .closePosition
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
    @Published var tradeType: TradeSubmission.TradeType = .trade

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
                self?.navigate(to: RoutingRequest(path: "/authorization/notification", params: nil), animated: true, completion: nil)
            }
        } else {
            self?.dismissView(completion: nil)
        }
    }

    private func dismissView(completion: (() -> Void)?) {
        navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true) { _, _ in
            completion?()
        }
    }

    private lazy var tryAgainAction: (() -> Void) = { [weak self] in
        self?.submitOrder()
    }

    private var orderSidePublisher: AnyPublisher<Abacus.OrderSide?, Never> {
        $tradeType
            .flatMapLatest { tradeType in
                switch tradeType {
                case .trade:
                    AbacusStateManager.shared.state.tradeInput
                        .map {  $0?.side }
                        .eraseToAnyPublisher()
                case .closePosition:
                    AbacusStateManager.shared.state.closePositionInput
                        .map {  $0?.side }
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    private var marketIdPublisher: AnyPublisher<String?, Never> {
        $tradeType
            .flatMapLatest { tradeType in
                switch tradeType {
                case .trade:
                    AbacusStateManager.shared.state.tradeInput
                        .map {  $0?.marketId }
                        .eraseToAnyPublisher()
                case .closePosition:
                    AbacusStateManager.shared.state.closePositionInput
                        .map {  $0?.marketId }
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    private var tradeSummaryPublisher: AnyPublisher<TradeInputSummary?, Never> {
        $tradeType
            .flatMapLatest { tradeType in
                switch tradeType {
                case .trade:
                    AbacusStateManager.shared.state.tradeInput
                        .map {  $0?.summary }
                        .eraseToAnyPublisher()
                case .closePosition:
                    AbacusStateManager.shared.state.closePositionInput
                        .map {  $0?.summary }
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    // last order of the current submission
    private var validLastOrderPublisher: AnyPublisher<SubaccountOrder?, Never> {
        Publishers.CombineLatest(
            AbacusStateManager.shared.state.lastOrder,
            $submissionStatus
        )
        .map { subaccountOrder, status in
            if status != nil {
                if let subaccountOrder = subaccountOrder,
                   subaccountOrder.createdAtHeight != nil || subaccountOrder.goodTilBlock != nil {
                    return subaccountOrder
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
        .eraseToAnyPublisher()
    }

    override init() {
        super.init()

        viewModel = dydxSimpleUITradeStatusViewModel()
    }

    override func start() {
        super.start()

        _ = submitOrderOnce

        observeStatus()

        orderSidePublisher
            .sink { [weak self] side in
                switch side {
                case .buy:
                    self?.viewModel?.side = AppOrderSide.BUY
                case .sell:
                    self?.viewModel?.side = AppOrderSide.SELL
                default:
                    self?.viewModel?.side = nil
                }
            }
            .store(in: &subscriptions)
    }

    private func observeStatus() {
        Publishers
            .CombineLatest4(
                validLastOrderPublisher,
                marketIdPublisher,
                AbacusStateManager.shared.state.configsAndAssetMap,
                tradeSummaryPublisher
            )
            .sink { [weak self] validLastOrder, marketId, configsAndAssetMap, inputSummary in
                if let validLastOrder = validLastOrder {
                    self?.update(lastOrder: validLastOrder, configsAndAssetMap: configsAndAssetMap)
                } else {
                    self?.update(marketId: marketId, configsAndAssetMap: configsAndAssetMap, inputSummary: inputSummary)
                }
            }
            .store(in: &subscriptions)
    }

    private func update(lastOrder: SubaccountOrder, configsAndAssetMap: [String: MarketConfigsAndAsset]) {
        guard let configsAndAsset = configsAndAssetMap[lastOrder.marketId] else {
            return
        }

        let marketConfigs = configsAndAsset.configs
        let asset = configsAndAsset.asset

        viewModel?.size = dydxFormatter.shared.raw(number: lastOrder.size, digits: marketConfigs?.displayStepSizeDecimals?.intValue ?? 3)

        viewModel?.assetId = asset?.displayableAssetId

        // Market order uses the limit price, so let's hide it for now
//        viewModel?.price = dydxFormatter.shared.dollar(number: lastOrder.price, digits: marketConfigs?.displayTickSizeDecimals?.intValue ?? 3)

        viewModel?.totalFees = nil
        viewModel?.totalAmount = dydxFormatter.shared.dollar(number: lastOrder.price * lastOrder.size, digits: 3)
    }

    private func update(marketId: String?, configsAndAssetMap: [String: MarketConfigsAndAsset], inputSummary: TradeInputSummary?) {
        guard let marketId, let configsAndAsset = configsAndAssetMap[marketId] else { return }

        let marketConfigs = configsAndAsset.configs
        let asset = configsAndAsset.asset

        viewModel?.size = dydxFormatter.shared.raw(number: inputSummary?.size?.doubleValue, digits: marketConfigs?.displayStepSizeDecimals?.intValue ?? 3)

        viewModel?.assetId = asset?.displayableAssetId

        viewModel?.price = dydxFormatter.shared.dollar(number: inputSummary?.price?.doubleValue, digits: marketConfigs?.displayTickSizeDecimals?.intValue ?? 3)

        let tradeAmount = abs(inputSummary?.total?.doubleValue ?? 0)
        if tradeAmount > 0 {
            let tradeFees = inputSummary?.fee?.doubleValue ?? 0
            let slippage = inputSummary?.slippage?.doubleValue ?? 0
            let totalFees = tradeFees + slippage
            viewModel?.totalFees = dydxFormatter.shared.dollar(number: totalFees, digits: 3)
            viewModel?.totalAmount = dydxFormatter.shared.dollar(number: tradeAmount, digits: 3)
        } else {
            viewModel?.totalFees = nil
            viewModel?.totalAmount = nil
        }
    }

    private func submitOrder() {
        submissionStatus = nil
        viewModel?.status = .submitting
        viewModel?.ctaButtonViewModel.ctaButtonState = .waiting
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
