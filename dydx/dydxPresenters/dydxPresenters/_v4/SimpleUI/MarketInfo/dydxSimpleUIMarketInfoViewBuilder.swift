import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

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
    @Published var marketId: String?
    @Published var shouldDisplayFullTradeInputOnAppear: Bool = false

    private let headerPresenter = dydxSimpleUIMarketInfoHeaderViewPresenter()
    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        headerPresenter
    ]

    override init() {
        let viewModel = dydxSimpleUIMarketInfoViewModel()

        headerPresenter.$viewModel.assign(to: &viewModel.$header)

        super.init()

        self.viewModel = viewModel

        $marketId.assign(to: &headerPresenter.$marketId)

        attachChildren(workers: childPresenters)
    }

}
