//
//  dydxMarketInfoViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 10/6/22.
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

public class dydxMarketInfoViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxMarketInfoViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        let viewController = dydxMarketInfoViewController(presenter: presenter, view: view, configuration: .nav)
        viewController.hidesBottomBarWhenPushed = true
        return viewController as? T
    }
}

private class dydxMarketInfoViewController: HostingViewController<PlatformView, dydxMarketInfoViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/trade" || request?.path == "/market", let presenter = presenter as? dydxMarketInfoViewPresenter {
            presenter.marketId = request?.params?["market"] as? String ?? "ETH-USD"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if request?.path == "/trade" {
                    Router.shared?.navigate(to: RoutingRequest(path: "/trade/input", params: ["full": "true"]), animated: true, completion: nil)
                } else {
                    Router.shared?.navigate(to: RoutingRequest(path: "/trade/input"), animated: true, completion: nil)
                }
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

    private let pagingPresenter = dydxMarketInfoPagingViewPresenter()
    private let statsPresenter = dydxMarketStatsViewPresenter()
    private let configsPresenter = dydxMarketConfigsViewPresenter()
    private let sharedMarketPresenter = SharedMarketPresenter()
    private let favoritePresenter = dydxUserFavoriteViewPresenter()
    private let fillsPresenter: dydxPortfolioFillsViewPresenter
    private let fundingPresenter: dydxPortfolioFundingViewPresenter
    private let positionPresenter: dydxMarketPositionViewPresenter
    private let ordersPresenter: dydxPortfolioOrdersViewPresenter

    private lazy var childPresenters: [HostedViewPresenterProtocol] = {
        if dydxBoolFeatureFlag.enable_spot_experience.isEnabled {
            return [
                pagingPresenter,
                sharedMarketPresenter,
                favoritePresenter
            ]
        } else {
            return [
                pagingPresenter,
                statsPresenter,
                configsPresenter,
                sharedMarketPresenter,
                favoritePresenter
            ]
        }}()

    private lazy var selectionPresenters: [PortfolioSection: HostedViewPresenterProtocol] = {
        if dydxBoolFeatureFlag.enable_spot_experience.isEnabled {
            return [
                .positions: positionPresenter
            ]
        } else {
            return [
                .positions: positionPresenter,
                .orders: ordersPresenter,
                .trades: fillsPresenter,
                .funding: fundingPresenter
            ]
        }
    }()

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

        let sections = dydxBoolFeatureFlag.enable_spot_experience.isEnabled ? [Section.allSections.first!] : Section.allSections
        viewModel.sections.itemTitles = sections.map(\.text)
        viewModel.sections.onSelectionChanged = { [weak self] index in
            if index < sections.count {
                let selectedSection = sections[index]
                viewModel.sectionSelection = selectedSection.key
                viewModel.sections.sectionIndex = index
                self?.resetPresentersForVisibilityChange()
            }
        }
        viewModel.sectionSelection = .positions
        viewModel.sections.sectionIndex = 0

        self.viewModel = viewModel

        attachChildren(workers: childPresenters)
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.setMarket(market: marketId)

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
            }
            .store(in: &subscriptions)

        Publishers
            .CombineLatest(AbacusStateManager.shared.state.selectedSubaccountPositions,
                           $marketId
                               .compactMap { $0 }
                               .removeDuplicates())
            .sink { [weak self] subaccountPositions, marketId in
                let position = subaccountPositions.first { (subaccountPosition: SubaccountPosition) in
                    subaccountPosition.id == marketId
                }
                self?.updatePositionSection(position: position)
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

    private func updatePositionSection(position: SubaccountPosition?) {
        if let position = position, position.side.current != PositionSide.none, let viewModel = viewModel {
            viewModel.showPositionSection = true
            fillsPresenter.filterByMarketId = position.id
            fundingPresenter.filterByMarketId = position.id
            ordersPresenter.filterByMarketId = position.id
            positionPresenter.position = position
            resetPresentersForVisibilityChange()
        } else {
            viewModel?.showPositionSection = false
            for (_, presenter) in selectionPresenters {
                presenter.stop()
            }
        }
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
