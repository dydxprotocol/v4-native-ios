//
//  dydxMarketInfoViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 10/6/22.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Combine
import dydxStateManager
import Abacus
import dydxFormatter

public class dydxMarketInfoViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        if dydxBoolFeatureFlag.simple_ui.isEnabled, AppMode.current == .simple {
            let viewController: dydxSimpleUIMarketInfoViewController? = dydxSimpleUIMarketInfoViewBuilder().build()
            return viewController as? T
        } else {
            let presenter = dydxMarketInfoViewPresenter()
            let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
            let viewController = dydxMarketInfoViewController(presenter: presenter, view: view, configuration: .default)
            viewController.hidesBottomBarWhenPushed = true
            return viewController as? T
        }
    }
}

private class dydxMarketInfoViewController: HostingViewController<PlatformView, dydxMarketInfoViewModel> {
    private var hidePredictionMarketsNotice: Bool {
        SettingsStore.shared?.value(forKey: dydxSettingsStoreKey.hidePredictionMarketsNoticeKey.rawValue) as? Bool ?? false
    }

    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/trade" || request?.path == "/market", let presenter = presenter as? dydxMarketInfoViewPresenter {
            let selectedMarketId = request?.params?["market"] as? String ?? dydxSelectedMarketsStore.shared.lastSelectedMarket
            dydxSelectedMarketsStore.shared.lastSelectedMarket = selectedMarketId
            presenter.marketId = selectedMarketId
            presenter.shouldDisplayFullTradeInputOnAppear = request?.path == "/trade"
            if let sectionRaw = request?.params?["currentSection"] as? String {
                let section = PortfolioSection(rawValue: sectionRaw) ?? .positions
                let preselectedSection = Section.allSections.map(\.key).firstIndex(of: section) ?? 0
                presenter.viewModel?.sections.onSelectionChanged?(preselectedSection)
            }
            return true
        }
        return false
    }
}

private protocol dydxMarketInfoViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxMarketInfoViewModel? { get }
}

private class dydxMarketInfoViewPresenter: HostedViewPresenter<dydxMarketInfoViewModel>, dydxMarketInfoViewPresenterProtocol {
    @Published var marketId: String?
    var shouldDisplayFullTradeInputOnAppear: Bool = false

    private let pagingPresenter = dydxMarketInfoPagingViewPresenter()
    private let statsPresenter = dydxMarketStatsViewPresenter()
    private let configsPresenter = dydxMarketConfigsViewPresenter()
    private let sharedMarketPresenter = SharedMarketPresenter()
    private let favoritePresenter = dydxUserFavoriteViewPresenter()
    private let fillsPresenter: dydxPortfolioFillsViewPresenter
    private let fundingPresenter: dydxPortfolioFundingViewPresenter
    private let positionPresenter: dydxMarketPositionViewPresenter
    private let ordersPresenter: dydxPortfolioOrdersViewPresenter

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        pagingPresenter,
        statsPresenter,
        configsPresenter,
        sharedMarketPresenter,
        favoritePresenter
    ]

    private lazy var selectionPresenters: [PortfolioSection: HostedViewPresenterProtocol] = [
        .positions: positionPresenter,
        .orders: ordersPresenter,
        .trades: fillsPresenter,
        .funding: fundingPresenter
    ]

    fileprivate static var hidePredictionMarketsNotice: Bool {
        get { SettingsStore.shared?.value(forKey: dydxSettingsStoreKey.hidePredictionMarketsNoticeKey.rawValue) as? Bool ?? false }
    }

    override init() {
        let viewModel = dydxMarketInfoViewModel()

        fillsPresenter = dydxPortfolioFillsViewPresenter(viewModel: viewModel.fills)
        fundingPresenter = dydxPortfolioFundingViewPresenter(viewModel: viewModel.funding)
        positionPresenter = dydxMarketPositionViewPresenter(viewModel: viewModel.position)
        ordersPresenter = dydxPortfolioOrdersViewPresenter(viewModel: viewModel.orders)

        super.init()

        sharedMarketPresenter.$viewModel.assign(to: &viewModel.header.$sharedMarketViewModel)
        favoritePresenter.$viewModel.assign(to: &viewModel.header.$favoriteViewModel)
        pagingPresenter.$viewModel.assign(to: &viewModel.$paging)
        statsPresenter.$viewModel.assign(to: &viewModel.$stats)
        configsPresenter.$viewModel.assign(to: &viewModel.$configs)
        sharedMarketPresenter.$viewModel.assign(to: &viewModel.resources.$sharedMarketViewModel)

        viewModel.header.onBackButtonTap = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }

        viewModel.header.onMarketSelectorTap = {
            Router.shared?.navigate(to: RoutingRequest(path: "/markets/search",
                                                       params: ["shouldShowResultsForEmptySearch": true]),
                                    animated: true,
                                    completion: nil)
        }

        viewModel.sections.itemTitles = Section.allSections.map(\.text)
        viewModel.sections.onSelectionChanged = { [weak self] index in
            if index <  Section.allSections.count {
                let selectedSection = Section.allSections[index]
                viewModel.sectionSelection = selectedSection.key
                viewModel.sections.sectionIndex = index
                self?.resetPresentersForVisibilityChange()
            }
        }

        self.viewModel = viewModel

        attachChildren(workers: childPresenters)
    }

    override func start() {
        super.start()

        $marketId
            .compactMap { $0 }
            .removeDuplicates()
            .sink { [weak self] marketId in
                AbacusStateManager.shared.setMarket(market: marketId)
                self?.pagingPresenter.marketId = marketId
                self?.statsPresenter.marketId = marketId
                self?.configsPresenter.marketId = marketId
                self?.sharedMarketPresenter.marketId = marketId
                self?.favoritePresenter.marketId = marketId

                self?.fillsPresenter.filterByMarketId = marketId
                self?.fundingPresenter.filterByMarketId = marketId
                self?.ordersPresenter.filterByMarketId = marketId
            }
            .store(in: &subscriptions)

        Publishers
            .CombineLatest3(AbacusStateManager.shared.state.selectedSubaccountPositions,
                            AbacusStateManager.shared.state.selectedSubaccountPendingPositions,
                            $marketId
                .compactMap { $0 }
                .removeDuplicates())
            .sink { [weak self] subaccountPositions, subaccountPendingPositions, marketId in
                let position = subaccountPositions.first { $0.id == marketId }
                let pendingPosition = subaccountPendingPositions.first { $0.marketId == marketId }
                self?.updatePositionSection(position: position, pendingPosition: pendingPosition)
            }
            .store(in: &subscriptions)

        floatTradeInput()

        Publishers.CombineLatest(
            AbacusStateManager.shared.state.marketMap,
            AbacusStateManager.shared.state.assetMap
        )
        .first()
        .sink {[weak self] marketMap, assetMap in
            guard let marketId = self?.marketId,
                  let assetId = marketMap[marketId]?.assetId,
                  let asset = assetMap[assetId] else { return }
            if asset.tags?.contains("Prediction Market") == true && !Self.hidePredictionMarketsNotice {
                Router.shared?.navigate(to: RoutingRequest(path: "/trade/prediction_markets_notice"), animated: true, completion: nil)
            }
        }
        .store(in: &subscriptions)
    }

    override func stop() {
        super.stop()

        for (_, presenter) in selectionPresenters {
            presenter.stop()
        }

        /*
         Comment out for now. Close Position would cause this to trigger and stops orderbook
         */
        //        AbacusStateManager.shared.setMarket(market: nil)
    }

    private func floatTradeInput() {
        if shouldDisplayFullTradeInputOnAppear {
            Router.shared?.navigate(to: RoutingRequest(path: "/trade/input", params: ["full": "true", "market": marketId ?? ""]), animated: true, completion: nil)
        } else {
            Router.shared?.navigate(to: RoutingRequest(path: "/trade/input", params: ["market": marketId ?? ""]), animated: true, completion: nil)
        }
    }

    private func updatePositionSection(position: SubaccountPosition?, pendingPosition: SubaccountPendingPosition?) {
        if let position, position.side.current != PositionSide.none {
            positionPresenter.position = position
            positionPresenter.pendingPosition = nil
        } else if let pendingPosition, pendingPosition.orderCount > 0 {
            positionPresenter.position = nil
            positionPresenter.pendingPosition = pendingPosition
        } else {
            positionPresenter.position = nil
            positionPresenter.pendingPosition = nil
        }
        resetPresentersForVisibilityChange()
    }

    private func resetPresentersForVisibilityChange() {
        for (key, presenter) in selectionPresenters {
            if key == viewModel?.sectionSelection {
                if presenter.isStarted == false {
                    presenter.start()
                }
            } else if presenter.isStarted {
                presenter.stop()
            }
        }
    }
}

private struct Section: Equatable {
    let text: String
    let key: PortfolioSection

    static let allSections: [Self] = [
        Self(text: DataLocalizer.localize(path: "APP.GENERAL.POSITION"), key: .positions),
        Self(text: DataLocalizer.localize(path: "APP.GENERAL.ORDERS"), key: .orders),
        Self(text: DataLocalizer.localize(path: "APP.GENERAL.TRADES"), key: .trades)
        // TODO: add back Funding when ready, see https://github.com/dydxprotocol/native-ios-v4/pull/118/files
    ]
}
