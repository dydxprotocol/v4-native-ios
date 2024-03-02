//
//  dydxRateAppViewBuilder.swift
//  dydxUI
//
//  Created by Michael Maguire on 2/28/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import StoreKit

public class dydxRateAppViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxRateAppViewBuilderPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxRateAppViewBuilderController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxRateAppViewBuilderController: HostingViewController<PlatformView, dydxRateAppViewModel> {

    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/rate_app" {
            return true
        }
        return false
    }
}

private protocol dydxRateAppViewBuilderPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxRateAppViewModel? { get }
}

private class dydxRateAppViewBuilderPresenter: HostedViewPresenter<dydxRateAppViewModel>, dydxRateAppViewBuilderPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxRateAppViewModel()

        viewModel?.negativeRatingIntentAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true) { (_, _) in
                Router.shared?.navigate(to: RoutingRequest(path: "/action/collect_feedback"), animated: true, completion: nil)
            }
        }

        viewModel?.positiveRatingIntentAction = {
            #if DEBUG
            #else
                SKStoreReviewController.requestReview()
            #endif
            RatingService.shared?.disablePrompting()
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }

        viewModel?.deferAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }
    }
}
