//
//  dydxSimpleUITradeInputViewModelPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 27/12/2024.
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

public class dydxSimpleUITradeInputViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxSimpleUITradeInputViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        let viewController = dydxSimpleUITradeInputViewController(presenter: presenter, view: view, configuration: .fullScreenSheet)
        return viewController as? T
    }
}

class dydxSimpleUITradeInputViewController: HostingViewController<PlatformView, dydxSimpleUITradeInputViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        guard let presenter = presenter as? dydxSimpleUITradeInputViewPresenter else {
            return false
        }
        if request?.path == "/trade/simple" {
            guard let side = request?.params?["side"] as? String else {
                return false
            }

            AbacusStateManager.shared.startTrade()
            AbacusStateManager.shared.trade(input: "MARKET", type: .type)
            AbacusStateManager.shared.trade(input: "0", type: .size)
            AbacusStateManager.shared.trade(input: "0", type: .usdcsize)
            AbacusStateManager.shared.trade(input: nil, type: .size)
            AbacusStateManager.shared.trade(input: nil, type: .usdcsize)

            AbacusStateManager.shared.trade(input: side.uppercased(), type: TradeInputField.side)

            presenter.tradeType = .trade
            return true

        } else if request?.path == "/trade/simple/close", let marketId = parser.asString(request?.params?["marketId"]) {

            AbacusStateManager.shared.setMarket(market: marketId)
            AbacusStateManager.shared.startClosePosition(marketId: marketId)

            presenter.tradeType = .closePosition
            return true
        }

        return false
    }
}

private protocol dydxSimpleUITradeInputViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUITradeInputViewModel? { get }
}

private class dydxSimpleUITradeInputViewPresenter: HostedViewPresenter<dydxSimpleUITradeInputViewModel>, dydxSimpleUITradeInputViewPresenterProtocol {
    @Published var tradeType: TradeSubmission.TradeType = .trade {
        didSet {
            headerPresenter.tradeType = tradeType
            ctaButtonPresenter.tradeType = tradeType
            sizeViewPresenter.tradeType = tradeType
            feesPresenter.tradeType = tradeType
        }
    }

    private let ctaButtonPresenter = dydxSimpleUITradeInputCtaButtonViewPresenter()
    private let sizeViewPresenter = dydxSimpleUITradeInputSizeViewPresenter()
    private let buyingPowerPresenter = dydxSimpleUIBuyingPowerViewPresenter()
    private let feesPresenter = dydxSimpleUIFeesViewPresenter()
    private let marginUsagePreesnter = dydxSimpleUIMarginUsageViewPresenter()
    private let validationErrorPresenter = dydxSimpleUITradeInputValidationViewPresenter()
    private let headerPresenter = dydxSimpleUITradeInputHeaderViewPresenter()
    private let positionPresenter = dydxSimpleUITradeInputPositionViewPresenter()

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        ctaButtonPresenter,
        sizeViewPresenter,
        buyingPowerPresenter,
        feesPresenter,
        marginUsagePreesnter,
        validationErrorPresenter,
        headerPresenter,
        positionPresenter
    ]

    override init() {
        let viewModel = dydxSimpleUITradeInputViewModel()

        ctaButtonPresenter.$viewModel.assign(to: &viewModel.$ctaButtonViewModel)
        sizeViewPresenter.$viewModel.assign(to: &viewModel.$sizeViewModel)
        marginUsagePreesnter.$viewModel.assign(to: &viewModel.$marginUsageViewModel)
        feesPresenter.$viewModel.assign(to: &viewModel.$feesViewModel)
        validationErrorPresenter.$viewModel.assign(to: &viewModel.$validationErrorViewModel)
        headerPresenter.$viewModel.assign(to: &viewModel.$header)

        super.init()

        self.viewModel = viewModel

        attachChildren(workers: childPresenters)
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest3(
                $tradeType,
                buyingPowerPresenter.$viewModel,
                positionPresenter.$viewModel)
            .sink { [weak self] tradeType, buyingPowerViewModel, positionViewModel in
                switch tradeType {
                case .trade:
                    self?.viewModel?.buyingPowerViewModel = buyingPowerViewModel
                    self?.viewModel?.positionViewModel = nil
                case .closePosition:
                    self?.viewModel?.buyingPowerViewModel = nil
                    self?.viewModel?.positionViewModel = positionViewModel
                }
            }
            .store(in: &subscriptions)

    }
}
