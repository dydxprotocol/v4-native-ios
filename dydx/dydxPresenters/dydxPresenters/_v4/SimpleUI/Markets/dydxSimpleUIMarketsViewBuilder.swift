//
//  dydxSimpleUIMarketsViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 17/12/2024.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

public class dydxSimpleUIMarketsViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxSimpleUIMarketsViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxSimpleUIMarketsViewController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

public class dydxSimpleUIMarketsViewController: HostingViewController<PlatformView, dydxSimpleUIMarketsViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/" {
            return true
        }
        return false
    }
}

public protocol dydxSimpleUIMarketsViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUIMarketsViewModel? { get }
}

public class dydxSimpleUIMarketsViewPresenter: HostedViewPresenter<dydxSimpleUIMarketsViewModel>, dydxSimpleUIMarketsViewPresenterProtocol {

    override init() {
        super.init()

        viewModel = dydxSimpleUIMarketsViewModel()
        viewModel?.onSettingTapped = {
            Router.shared?.navigate(to: RoutingRequest(path: "/settings/app_mode"), animated: true, completion: nil)
        }
    }
}
