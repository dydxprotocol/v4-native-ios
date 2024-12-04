//
//  dydxTradeStatusViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 1/26/23.
//

import Abacus
import Combine
import dydxStateManager
import dydxViews
import ParticlesKit
import PlatformParticles
import PlatformUI
import RoutingKit
import Utilities
import dydxFormatter

public struct TradeSubmission {
    public enum TradeType: Int {
        case trade
        case closePosition
    }
}

public class dydxTradeStatusViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxTradeStatusViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxTradeStatusViewController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxTradeStatusViewController: HostingViewController<PlatformView, dydxTradeStatusViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/trade/status" {
            (presenter as? dydxTradeStatusViewPresenter)?.tradeType = .trade
            return true
        } else if request?.path == "/closePosition/status" {
            (presenter as? dydxTradeStatusViewPresenter)?.tradeType = .closePosition
            return true
        }
        return false
    }
}

private protocol dydxTradeStatusViewPresenterProtocol: HostedViewPresenterProtocol {
    var tradeType: TradeSubmission.TradeType { get set }
    var viewModel: dydxTradeStatusViewModel? { get }
}

private class dydxTradeStatusViewPresenter: HostedViewPresenter<dydxTradeStatusViewModel>, dydxTradeStatusViewPresenterProtocol {
    var tradeType: TradeSubmission.TradeType = .trade

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
        switch tradeType {
            case .trade:
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true) {
                _, _ in
                completion?()
            }
        case .closePosition:
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true) {
                _, _ in
                Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true) { _, _ in
                    completion?()
                }
            }
        }
    }

    private lazy var tryAgainAction: (() -> Void) = { [weak self] in
        self?.submitOrder()
    }

    private var submissionDate: Date?

    @Published private var submissionStatus: AbacusStateManager.SubmissionStatus?

    override init() {
        super.init()

        viewModel = dydxTradeStatusViewModel()
    }

    override func start() {
        super.start()

        _ = submitOrderOnce

        observeStatus()
    }

    private func observeStatus() {
        // last order of the current submission
        let validLastOrder: AnyPublisher<SubaccountOrder?, Never> =
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

        switch tradeType {
        case .trade:
            Publishers
                .CombineLatest3(AbacusStateManager.shared.state.tradeInput.compactMap { $0 },
                                validLastOrder,
                                AbacusStateManager.shared.state.configsAndAssetMap)
                .sink { [weak self] tradeInput, lastOrder, configsAndAssetMap in
                    if let lastOrder = lastOrder {
                        self?.update(lastOrder: lastOrder, configsAndAssetMap: configsAndAssetMap)
                    } else {
                        self?.update(tradeInput: tradeInput, configsAndAssetMap: configsAndAssetMap)
                    }
                }
                .store(in: &subscriptions)

        case .closePosition:
            Publishers
                .CombineLatest3(AbacusStateManager.shared.state.closePositionInput,
                                validLastOrder,
                                AbacusStateManager.shared.state.configsAndAssetMap)
                .sink { [weak self] closePositionInput, lastOrder, configsAndAssetMap in
                    if let lastOrder = lastOrder {
                        self?.update(lastOrder: lastOrder, configsAndAssetMap: configsAndAssetMap)
                    } else {
                        self?.update(closePositionInput: closePositionInput, configsAndAssetMap: configsAndAssetMap)
                    }
                }
                .store(in: &subscriptions)
        }
    }

    private func update(lastOrder: SubaccountOrder, configsAndAssetMap: [String: MarketConfigsAndAsset]) {
        guard let configsAndAsset = configsAndAssetMap[lastOrder.marketId],
              let configs = configsAndAsset.configs, let asset = configsAndAsset.asset else {
            return
        }

        if let typeStringKey = lastOrder.resources.typeStringKey {
            viewModel?.orderViewModel.type = DataLocalizer.localize(path: typeStringKey)
        }
        viewModel?.orderViewModel.size = dydxFormatter.shared.localFormatted(number: lastOrder.size, digits: configs.stepSizeDecimals?.intValue ?? 1)
        viewModel?.orderViewModel.token?.symbol = asset.displayableAssetId
        if let createdAt = lastOrder.createdAtMilliseconds?.uint64Value {
            viewModel?.orderViewModel.date = Date(milliseconds: createdAt)
        }
        if let tickSize = configs.tickSizeDecimals?.intValue {
            viewModel?.orderViewModel.price = dydxFormatter.shared.dollar(number: lastOrder.price, digits: tickSize)
        }
        if lastOrder.side == Abacus.OrderSide.buy {
            viewModel?.orderViewModel.sideText.side = .buy
        } else {
            viewModel?.orderViewModel.sideText.side = .sell
        }
        if let url = asset.resources?.imageUrl {
            viewModel?.orderViewModel.logoUrl = URL(string: url)
        }

        updateOrderStatus(order: lastOrder)
    }

    private func update(tradeInput: TradeInput, configsAndAssetMap: [String: MarketConfigsAndAsset]) {
        guard let marketId = tradeInput.marketId else {
            return
        }

        let configsAndAsset = configsAndAssetMap[marketId]
        let configs = configsAndAsset?.configs
        let asset = configsAndAsset?.asset

        viewModel?.orderViewModel.type = tradeInput.selectedTypeText
        if let size = tradeInput.summary?.size {
            viewModel?.orderViewModel.size = dydxFormatter.shared.localFormatted(number: size, digits: configs?.stepSizeDecimals?.intValue ?? 1)
        }
        if let token = asset?.displayableAssetId ?? configsAndAsset?.assetId {
            viewModel?.orderViewModel.token?.symbol = token
        }

        viewModel?.orderViewModel.date = submissionDate
        if let tickSize = configs?.tickSizeDecimals?.intValue {
            if let price = tradeInput.summary?.price {
                viewModel?.orderViewModel.price = dydxFormatter.shared.dollar(number: price, digits: tickSize)
            }
            if let fee = tradeInput.summary?.fee {
                viewModel?.orderViewModel.fee = dydxFormatter.shared.dollar(number: fee, digits: tickSize)
            }
        }
        // viewModel?.orderViewModel.feeLiquidity = DataLocalizer.localize(path: tradeInput.summary. fill.resources.liquidityStringKey ?? "-")
        if tradeInput.side == .buy {
            viewModel?.orderViewModel.sideText.side = .buy
        } else {
            viewModel?.orderViewModel.sideText.side = .sell
        }
        if let url = asset?.resources?.imageUrl {
            viewModel?.orderViewModel.logoUrl = URL(string: url)
        }
    }

    private func update(closePositionInput: ClosePositionInput, configsAndAssetMap: [String: MarketConfigsAndAsset]) {
        guard let marketId = closePositionInput.marketId else {
            return
        }

        let configsAndAsset = configsAndAssetMap[marketId]
        let configs = configsAndAsset?.configs
        let asset = configsAndAsset?.asset

        viewModel?.orderViewModel.type = DataLocalizer.localize(path: "APP.GENERAL.MARKET")
        viewModel?.orderViewModel.size = dydxFormatter.shared.localFormatted(number: closePositionInput.summary?.size, digits: configs?.stepSizeDecimals?.intValue ?? 1)
        if let token = asset?.displayableAssetId ?? configsAndAsset?.assetId {
            viewModel?.orderViewModel.token?.symbol = token
        }
        viewModel?.orderViewModel.date = submissionDate
        if let tickSize = configs?.tickSizeDecimals?.intValue {
            viewModel?.orderViewModel.price = dydxFormatter.shared.dollar(number: closePositionInput.summary?.price, digits: tickSize)
            viewModel?.orderViewModel.fee = dydxFormatter.shared.dollar(number: closePositionInput.summary?.fee, digits: tickSize)
        }
        // viewModel?.orderViewModel.feeLiquidity = DataLocalizer.localize(path: tradeInput.summary. fill.resources.liquidityStringKey ?? "-")
        if closePositionInput.side == .buy {
            viewModel?.orderViewModel.sideText.side = .buy
        } else {
            viewModel?.orderViewModel.sideText.side = .sell
        }
        if let url = asset?.resources?.imageUrl {
            viewModel?.orderViewModel.logoUrl = URL(string: url)
        }
    }

    private func submitOrder() {
        submissionStatus = nil
        viewModel?.logoViewModel.status = .submitting
        viewModel?.logoViewModel.title = DataLocalizer.localize(path: "APP.TRADE.SUBMITTING_ORDER", params: nil)
        viewModel?.logoViewModel.detail = DataLocalizer.localize(path: "APP.TRADE.SUBMITTING_ORDER_DESC", params: nil)
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
            viewModel?.ctaButtonViewModel.ctaButtonState = .done
            viewModel?.ctaButtonViewModel.ctaAction = doneAction
            AbacusStateManager.shared.trade(input: nil, type: .size)
        case .failed(let error):
            viewModel?.logoViewModel.status = .failed
            viewModel?.logoViewModel.title = DataLocalizer.localize(path: "APP.GENERAL.FAILED", params: nil)
            viewModel?.logoViewModel.detail = error?.message ?? error?.localizedDescription ?? ""
            viewModel?.ctaButtonViewModel.ctaButtonState = .tryAgain
            viewModel?.ctaButtonViewModel.ctaAction = tryAgainAction
            HapticFeedback.shared?.notify(type: .error)
        }
    }

    private func updateOrderStatus(order: SubaccountOrder) {
        if let statusIcon = order.status.statusIcon,
           let titleKey = order.resources.statusStringKey {
            viewModel?.logoViewModel.status = statusIcon
            viewModel?.logoViewModel.title = DataLocalizer.localize(path: titleKey, params: nil)
            if let detailKey = order.status.detailKey {
                viewModel?.logoViewModel.detail = DataLocalizer.localize(path: detailKey, params: nil)
            } else {
                viewModel?.logoViewModel.detail = ""
            }
        } else {
            if order.status.statusIcon == nil { assertionFailure("order.status.statusIcon was nil") }
            if order.resources.statusStringKey == nil { assertionFailure("order.resources.statusStringKey was nil") }
        }
    }
}

private extension Abacus.OrderStatus {
    var statusIcon: dydxTradeStatusLogoViewModel.StatusIcon? {
        switch self {
        case .canceled: return .failed
        case .canceling, .pending, .partiallyfilled, .partiallycanceled: return .pending
        case .filled: return .filled
        case .open, .untriggered: return .open
        default: return nil
        }
    }

    var detailKey: String? {
        switch self {
        case .canceled: return "APP.TRADE.ORDER_CANCELED_DESC"
        case .canceling, .pending, .partiallyfilled: return "APP.TRADE.ORDER_PENDING_DESC"
        case .filled: return "APP.TRADE.ORDER_FILLED_DESC"
        case .open: return "APP.TRADE.ORDER_PLACED_DESC"
        case .untriggered: return "APP.TRADE.NOT_TRIGGERED_STATUS_DESC"
        default: return nil
        }
    }
}
