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
    var viewModel: dydxSimpleUITradeStatusViewModel? { get }
}

private class dydxSimpleUITradeStatusViewPresenter: HostedViewPresenter<dydxSimpleUITradeStatusViewModel>, dydxSimpleUITradeStatusViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxSimpleUITradeStatusViewModel()
    }
}
