//
//  dydxTransferNobleAddressViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 14/05/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager
import Combine
import Abacus

public class dydxTransferNobleAddressViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxTransferNobleAddressViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxTransferNobleAddressViewController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxTransferNobleAddressViewController: HostingViewController<PlatformView, dydxTransferNobleAddressViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/transfer/deposit/noble" {
            return true
        }
        return false
    }
}

private protocol dydxTransferNobleAddressViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTransferNobleAddressViewModel? { get }
}

private class dydxTransferNobleAddressViewPresenter: HostedViewPresenter<dydxTransferNobleAddressViewModel>, dydxTransferNobleAddressViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxTransferNobleAddressViewModel()
        viewModel?.cancelAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.currentWallet
            .sink { [weak self] wallet in
                guard let self else { return }
                if let address = wallet?.cosmoAddress {
                    let nobleAddress = AbacusStringUtils().toNobleAddress(dydxAddress: address)
                    self.viewModel?.address = nobleAddress
                    self.viewModel?.copyAction = {
                        UIPasteboard.general.string = nobleAddress
                        ErrorInfo.shared?.info(title: nil,
                                               message: DataLocalizer.localize(path: "APP.V4.NOBLE_ADDRESS_COPIED"),
                                               type: .info,
                                               error: nil, time: 3)
                    }
                } else {
                    self.viewModel?.address = nil
                    self.viewModel?.copyAction = nil
                }
             }
            .store(in: &subscriptions)
    }
}
