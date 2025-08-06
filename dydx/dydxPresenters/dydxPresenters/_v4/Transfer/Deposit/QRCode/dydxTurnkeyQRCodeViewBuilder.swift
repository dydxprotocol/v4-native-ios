//
//  dydxTurnkeyQRCodeViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 06/08/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

public class dydxTurnkeyQRCodeViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxTurnkeyQRCodeViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxTurnkeyQRCodeViewController(presenter: presenter, view: view, configuration: .fullScreenSheet) as? T
    }
}

private class dydxTurnkeyQRCodeViewController: HostingViewController<PlatformView, dydxTurnkeyQRCodeViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/transfer/deposit/qr_code" {
            if let presenter = self.presenter as? dydxTurnkeyQRCodeViewPresenter {
                presenter.chain = request?.params?["chain"] as? String
            }
            return true
        }
        return false
    }
}

private protocol dydxTurnkeyQRCodeViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTurnkeyQRCodeViewModel? { get }
}

private class dydxTurnkeyQRCodeViewPresenter: HostedViewPresenter<dydxTurnkeyQRCodeViewModel>, dydxTurnkeyQRCodeViewPresenterProtocol {

    @Published var chain: String?

    override init() {
        super.init()

        viewModel = dydxTurnkeyQRCodeViewModel()
    }
}
