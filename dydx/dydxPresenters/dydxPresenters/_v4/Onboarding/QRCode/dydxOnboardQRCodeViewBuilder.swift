//
//  dydxOnboardQRCodeViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 3/22/23.
//

import Utilities
import dydxStateManager
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxCartera

public class dydxOnboardQRCodeViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxOnboardQRCodeViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        let configuration = HostingViewControllerConfiguration(fixedHeight: UIScreen.main.bounds.height)
        return dydxOnboardQRCodeViewController(presenter: presenter, view: view, configuration: configuration) as? T
    }
}

private class dydxOnboardQRCodeViewController: HostingViewController<PlatformView, dydxOnboardQRCodeViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/onboard/qrcode" {
            return true
        } else {
            return false
        }
    }
}

private protocol dydxOnboardQRCodeViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxOnboardQRCodeViewModel? { get }
}

private class dydxOnboardQRCodeViewPresenter: HostedViewPresenter<dydxOnboardQRCodeViewModel>, dydxOnboardQRCodeViewPresenterProtocol {
    private let walletSetup = dydxV4WalletSetup()

    override init() {
        super.init()

        viewModel = dydxOnboardQRCodeViewModel()

        let chainId = AbacusStateManager.shared.ethereumChainId
        walletSetup.startDebugLink(chainId: chainId) { [weak self] info, error in
            if let chainId = info?.chainId,
               let action = AbacusStateManager.shared.environment?.walletConnection?.signTypedDataAction,
               let domain = AbacusStateManager.shared.environment?.walletConnection?.signTypedDataDomainName {
                self?.walletSetup.start(walletId: info?.wallet?.id,
                                        ethereumChainId: chainId,
                                        signTypedDataAction: action,
                                        signTypedDataDomainName: domain,
                                        useModal: false)
            } else if let error = error {
                self?.showError(error: error)
                self?.walletSetup.stop()
                Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
            }
        }
    }

    override func start() {
        super.start()

        walletSetup.$debugLink
            .compactMap { $0 }
            .sink { [weak self] debugLink in
                self?.viewModel?.qrCode = debugLink
            }
            .store(in: &subscriptions)

        walletSetup.$status
            .sink { [weak self] status in
                self?.updateStatus(status: status)
            }
            .store(in: &subscriptions)
    }

    private func updateStatus(status: dydxWalletSetup.Status) {
        switch status {
        case .signed(let result):
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let cosmoAddress = result.cosmoAddress, let mnemonic = result.mnemonic {
                    Router.shared?.navigate(to: RoutingRequest(path: "/action/post_onboarding", params: ["ethereumAddress": result.ethereumAddress, "cosmoAddress": cosmoAddress, "mnemonic": mnemonic, "walletId": result.walletId ?? ""]), animated: true, completion: nil)
                }
            }

        case .error(let error):
            showError(error: error)
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)

        default:
            break
        }
    }

    private func showError(error: Error) {
        let error = error as NSError
        let title = error.userInfo["title"] as? String ?? ""
        let message = error.userInfo["message"] as? String ?? error.localizedDescription
        ErrorInfo.shared?.info(title: title,
                               message: message,
                               type: .error,
                               error: nil, time: nil)
    }
}
