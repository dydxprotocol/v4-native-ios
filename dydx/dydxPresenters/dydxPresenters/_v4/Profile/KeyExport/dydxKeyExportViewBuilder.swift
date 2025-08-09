//
//  dydxKeyExportViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 5/22/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Abacus
import dydxStateManager

public class dydxKeyExportViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxKeyExportViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxKeyExportViewController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxKeyExportViewController: HostingViewController<PlatformView, dydxKeyExportViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/my-profile/keyexport" {
            if let presenter = self.presenter as? dydxKeyExportViewPresenter {
                presenter.mnemonic = request?.params?["mnemonic"] as? String
            }
            return true
        }
        return false
    }
}

private protocol dydxKeyExportViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxKeyExportViewModel? { get }
}

private class dydxKeyExportViewPresenter: HostedViewPresenter<dydxKeyExportViewModel>, dydxKeyExportViewPresenterProtocol {
    @Published var mnemonic: String?

    override init() {
        super.init()

        viewModel = dydxKeyExportViewModel()
    }

    override func start() {
        super.start()

        $mnemonic
            .sink { [weak self] mnemonic in
                self?.viewModel?.phrase = mnemonic
                self?.viewModel?.copyAction = {
                    let pasteboard = UIPasteboard.general
                    pasteboard.string = mnemonic

                    ErrorInfo.shared?.info(title: nil,
                                           message: DataLocalizer.localize(path: "APP.V4.DYDX_MNEMONIC_COPIED"),
                                           type: .success,
                                           error: nil, time: 3)
                }
            }
            .store(in: &subscriptions)
    }
}
