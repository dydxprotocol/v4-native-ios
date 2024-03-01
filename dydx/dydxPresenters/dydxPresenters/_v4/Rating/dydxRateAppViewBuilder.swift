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

public class dydxRateAppViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxRateAppViewBuilderPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxRateAppViewBuilderController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxRateAppViewBuilderController: HostingViewController<PlatformView, dydxRateAppViewModel> {
    override func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        super.navigate(to: request, animated: animated, completion: completion)
        // Create the alert controller
        let alertController = UIAlertController(title: "Your Title", message: "Your Message", preferredStyle: .alert)

        // Create the "Yes" action
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            // Handle the user's response here
            print("The user selected 'Yes'")
            // stop requesting review after user says "yes" the first time
            RatingService.shared?.shouldStopPrompting = true
        }

        // Create the "No" action
        let noAction = UIAlertAction(title: "No", style: .cancel) { _ in
            // Handle the user's response here
            print("The user selected 'No'")
        }

        // Add the actions to the alert controller
        alertController.addAction(yesAction)
        alertController.addAction(noAction)

        // Present the alert
        UIViewController.topmost()?.present(alertController, animated: true) {
            alertController.dismiss(animated: true)
        }
    }

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
    }
}
