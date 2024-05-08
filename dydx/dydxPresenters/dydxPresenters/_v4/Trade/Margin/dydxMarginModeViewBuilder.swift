//
//  dydxMarginModeViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 07/05/2024.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

public class dydxMarginModeViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxMarginModeViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxMarginModeViewController(presenter: presenter, view: view, configuration: .default) as? T
        // return HostingViewController(presenter: presenter, view: view) as? T
    }
}

private class dydxMarginModeViewController: HostingViewController<PlatformView, dydxMarginModeViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/trade/margin_type" {
            return true
        }
        return false
    }
}

private protocol dydxMarginModeViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxMarginModeViewModel? { get }
}

private class dydxMarginModeViewPresenter: HostedViewPresenter<dydxMarginModeViewModel>, dydxMarginModeViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxMarginModeViewModel()
    }
}
