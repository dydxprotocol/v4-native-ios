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
import Combine
import dydxStateManager

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

        viewModel?.cancelAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest(
                $chain,
                dydxDepositAddressesStateManager.shared.$state
            )
            .sink { [weak self] chain, addresses in
                guard let self = self, let chain = chain,
                      let tokenChain = TransferChain(rawValue: chain) else {
                    return
                }

                let address: String?
                switch tokenChain {
                case .Ethereum, .Arbitrum, .Base, .Optimism, .Polygon:
                    address = addresses?.evmAddress
                case .Avalanche:
                    address = addresses?.avalancheAddress
                case .Solana:
                    address = addresses?.svmAddress
                }
                self.viewModel?.address = address
                self.viewModel?.chainIcon = URL(string: tokenChain.chainLogoUrl)
                self.viewModel?.subtitle = DataLocalizer.localize(path: "APP.DEPOSIT_MODAL.TURNKEY_DEPOSIT_SUBTITLE", params: ["NETWORK": chain])
                self.viewModel?.footer = tokenChain.depositWarningString

                self.viewModel?.onCopyAction = { [weak self] in
                    UIPasteboard.general.string = address
                    self?.viewModel?.copied = true
                }
            }
            .store(in: &subscriptions)
    }
}
