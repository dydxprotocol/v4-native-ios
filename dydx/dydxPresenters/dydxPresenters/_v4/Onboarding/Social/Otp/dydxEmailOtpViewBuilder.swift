//
//  dydxEmailOtpViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 06/05/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

public class dydxEmailOtpViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxEmailOtpViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxEmailOtpViewController(presenter: presenter, view: view, configuration: .fullScreenSheet) as? T
    }
}

private class dydxEmailOtpViewController: HostingViewController<PlatformView, dydxEmailOtpViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/onboard/social/otp" {
            return true
        }
        return false
    }
}

private protocol dydxEmailOtpViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxEmailOtpViewModel? { get }
}

private class dydxEmailOtpViewPresenter: HostedViewPresenter<dydxEmailOtpViewModel>, dydxEmailOtpViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxEmailOtpViewModel()
    }
}
