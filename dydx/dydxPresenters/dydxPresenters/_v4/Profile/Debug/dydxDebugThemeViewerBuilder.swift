//
//  dydxDebugThemeViewer.swift
//  dydxUI
//
//  Created by Michael Maguire on 7/24/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

// Move the builder code to the dydxPresenters module for v4

import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit

public class dydxDebugThemeViewerBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxDebugThemeViewerPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxDebugThemeViewerController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxDebugThemeViewerController: HostingViewController<PlatformView, dydxDebugThemeViewerViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/settings/debug_theme_viewer" {
            return true
        }
        return false
    }
}

private protocol dydxDebugThemeViewerPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxDebugThemeViewerViewModel? { get }
}

private class dydxDebugThemeViewerPresenter: HostedViewPresenter<dydxDebugThemeViewerViewModel>, dydxDebugThemeViewerPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxDebugThemeViewerViewModel()

        viewModel?.onBackButtonTap = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }
    }
}
