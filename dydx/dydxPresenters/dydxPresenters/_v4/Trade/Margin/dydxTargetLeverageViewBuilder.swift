//
//  dydxTargetLeverageViewBuilder.swift
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

public class dydxTargetLeverageViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxTargetLeverageViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxTargetLeverageViewController(presenter: presenter, view: view, configuration: .default) as? T
        // return HostingViewController(presenter: presenter, view: view) as? T
    }
}

private class dydxTargetLeverageViewController: HostingViewController<PlatformView, dydxTargetLeverageViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/trade/target_leverage" {
            return true
        }
        return false
    }
}

private protocol dydxTargetLeverageViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTargetLeverageViewModel? { get }
}

private class dydxTargetLeverageViewPresenter: HostedViewPresenter<dydxTargetLeverageViewModel>, dydxTargetLeverageViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxTargetLeverageViewModel()
    }
}
