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
import dydxStateManager

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
            var eventMetaData = dydxRatingService.shared?.stateData ?? [:]
            if let shareSource = request?.params?["context"] as? String {
                eventMetaData["source_context"] = shareSource
            }
            Tracking.shared?.log(event: "PrepromptedForRating", data: eventMetaData)
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
            Tracking.shared?.log(event: "NegativeRatingIntentFollowed", data: dydxRatingService.shared?.stateData)
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true) { (_, _) in
                Router.shared?.navigate(to: RoutingRequest(path: "/action/collect_feedback"), animated: true, completion: nil)
            }
        }

        viewModel?.positiveRatingIntentAction = {
            Tracking.shared?.log(event: "PositiveRatingIntentFollowed", data: dydxRatingService.shared?.stateData)
            #if DEBUG
                Console.shared.log("log prompt for rating")
            #else
                SKStoreReviewController.requestReview()
            #endif
            dydxRatingService.shared?.disablePreprompting()
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }

        viewModel?.deferAction = {
            Tracking.shared?.log(event: "DeferRatingIntentFollowed", data: dydxRatingService.shared?.stateData)
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }
    }
}
