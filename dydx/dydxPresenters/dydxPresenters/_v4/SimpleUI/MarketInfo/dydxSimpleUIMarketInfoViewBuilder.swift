import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Combine
import dydxStateManager
import Abacus
import dydxAnalytics

public class dydxSimpleUIMarketInfoViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxSimpleUIMarketInfoViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxSimpleUIMarketInfoViewController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

class dydxSimpleUIMarketInfoViewController: HostingViewController<PlatformView, dydxSimpleUIMarketInfoViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/trade" || request?.path == "/market", let presenter = presenter as? dydxSimpleUIMarketInfoViewPresenter {
            let selectedMarketId = request?.params?["market"] as? String ?? dydxSelectedMarketsStore.shared.lastSelectedMarket
            dydxSelectedMarketsStore.shared.lastSelectedMarket = selectedMarketId
            presenter.marketId = selectedMarketId
            presenter.shouldDisplayFullTradeInputOnAppear = request?.path == "/trade"

            return true
        }
        return false
    }
}

private protocol dydxSimpleUIMarketInfoViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUIMarketInfoViewModel? { get }
}

private class dydxSimpleUIMarketInfoViewPresenter: HostedViewPresenter<dydxSimpleUIMarketInfoViewModel>, dydxSimpleUIMarketInfoViewPresenterProtocol {
    @Published var marketId: String? {
        didSet {
            if marketId != oldValue {
                AbacusStateManager.shared.setMarket(market: marketId)
            }
        }
    }
    @Published var shouldDisplayFullTradeInputOnAppear: Bool = false

    private let headerPresenter = dydxSimpleUIMarketInfoHeaderViewPresenter()
    private let chartPresenter = dydxSimpleUIMarketCandlesViewPresenter()
    private let positionPresenter = dydxSimpleUIMarketPositionViewPresenter()
    private let detailsPresenter = dydxSimpleUIMarketDetailsViewPresenter()
    private let buySellPresenter = dydxSimpleUIMarketBuySellViewPresenter()

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        headerPresenter,
        chartPresenter,
        positionPresenter,
        detailsPresenter,
        buySellPresenter
    ]

    override init() {
        let viewModel = dydxSimpleUIMarketInfoViewModel()

        headerPresenter.$viewModel.assign(to: &viewModel.$header)
        chartPresenter.$viewModel.assign(to: &viewModel.$chart)
        detailsPresenter.$viewModel.assign(to: &viewModel.$details)
        positionPresenter.$viewModel.assign(to: &viewModel.$position)
        buySellPresenter.$viewModel.assign(to: &viewModel.$buySell)

        super.init()

        self.viewModel = viewModel

        $marketId.assign(to: &headerPresenter.$marketId)
        $marketId.assign(to: &chartPresenter.$marketId)
        $marketId.assign(to: &detailsPresenter.$marketId)
        $marketId.assign(to: &positionPresenter.$marketId)
        $marketId.assign(to: &buySellPresenter.$marketId)

        attachChildren(workers: childPresenters)
    }
}
