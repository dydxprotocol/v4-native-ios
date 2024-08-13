//
//  dydxPredictionMarketsNoticeViewBuilder.swift
//  dydxPresenters
//
//  Created by Michael Maguire on 8/9/24.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Abacus
import dydxStateManager
import dydxAnalytics

public class dydxPredictionMarketsNoticeViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxPredictionMarketsNoticeViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxPredictionMarketsNoticeViewController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxPredictionMarketsNoticeViewController: HostingViewController<PlatformView, dydxPredictionMarketsNoticeViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/trade/prediction_markets_notice" {
            return !dydxPredictionMarketsNoticeViewPresenter.hidePredictionMarketsNotice
        }
        return false
    }
}

private protocol dydxPredictionMarketsNoticeViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxPredictionMarketsNoticeViewModel? { get }
}

private class dydxPredictionMarketsNoticeViewPresenter: HostedViewPresenter<dydxPredictionMarketsNoticeViewModel>, dydxPredictionMarketsNoticeViewPresenterProtocol {
    
    fileprivate static var hidePredictionMarketsNotice: Bool {
        get { SettingsStore.shared?.value(forKey: dydxSettingsStoreKey.hidePredictionMarketsNoticeKey.rawValue) as? Bool ?? false }
        set { SettingsStore.shared?.setValue(newValue, forKey: dydxSettingsStoreKey.hidePredictionMarketsNoticeKey.rawValue) }
    }
    
    override init() {
        super.init()

        viewModel = dydxPredictionMarketsNoticeViewModel()
        viewModel?.continueAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }
        
        viewModel?.hidePredictionMarketsNotice = Self.hidePredictionMarketsNotice
        viewModel?.$hidePredictionMarketsNotice
            .sink { Self.hidePredictionMarketsNotice = $0 }
            .store(in: &subscriptions)
    }
}
