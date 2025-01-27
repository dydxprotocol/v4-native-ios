//
//  dydxRootBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 17/12/2024.
//

import PlatformRouting
import UIKit
import Utilities
import PlatformUI
import ParticlesKit
import dydxFormatter
import dydxViews
import dydxStateManager
import Combine

public class dydxRootBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        nil
    }

    private var subscriptions = [AnyCancellable]()

    public func buildAsync<T>(completion: @escaping ((T?) -> Void)) {
        AbacusStateManager.shared.state.onboarded
            .prefix(1)
            .sink { onboarded in
                Tracking.shared?.setUserProperty(AppMode.current?.rawValue, forUserProperty: .appMode)

                if dydxBoolFeatureFlag.simple_ui.isEnabled {
                    if AppMode.current == nil {
                        if onboarded {
                            let viewController = dydxProUITabBarController() as? T
                            completion(viewController)
                        } else {
                            // first time user
                            let presenter = dydxFirstTimeViewPresenter()
                            let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
                            let viewController = dydxFirstTimeViewController(presenter: presenter, view: view, configuration: .default) as? T
                            completion(viewController)
                        }
                    } else {
                        if AppMode.current == .simple {
                            let presenter = dydxSimpleUIMarketsViewPresenter()
                            let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
                            let viewController = dydxSimpleUIMarketsViewController(presenter: presenter, view: view, configuration: .default)
                            let navController = UINavigationController(rootViewController: viewController) as? T
                            completion(navController)
                        } else {
                            let viewController = dydxProUITabBarController() as? T
                            completion(viewController)
                        }
                    }
                } else {
                    let viewController = dydxProUITabBarController() as? T
                    completion(viewController)
                }
            }
            .store(in: &subscriptions)
    }
}
