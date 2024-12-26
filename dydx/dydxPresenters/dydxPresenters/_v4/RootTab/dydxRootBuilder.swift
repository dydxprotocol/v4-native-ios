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

public class dydxRootBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        if dydxBoolFeatureFlag.simple_ui.isEnabled, AppMode.current == .simple {
            let presenter = dydxSimpleUIMarketsViewPresenter()
            let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
            let viewController = dydxSimpleUIMarketsViewController(presenter: presenter, view: view, configuration: .default)
            return UINavigationController(rootViewController: viewController) as? T
        } else {
            return dydxProUITabBarController() as? T
        }
    }
}
