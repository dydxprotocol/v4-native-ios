//
//  dydxSocialLoginViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 01/05/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxCartera
import PrivySDK
import dydxStateManager
import Abacus

public class dydxSocialLoginViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxSocialLoginViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxSocialLoginViewController(presenter: presenter, view: view, configuration: .fullScreenSheet) as? T
    }
}

private class dydxSocialLoginViewController: HostingViewController<PlatformView, dydxSocialLoginViewModel> {
    private var scrollView: UIScrollView?

    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/onboard/social" {
            let presenter = presenter as? dydxSocialLoginViewPresenterProtocol
            presenter?.viewModel?.onScrollViewCreated = { [weak self] scrollView in
                self?.scrollView = scrollView
            }
        }
        return false
    }

    // MARK: "half" presentation

    override open var scrollable: UIScrollView? {
        return scrollView
    }
}

private protocol dydxSocialLoginViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSocialLoginViewModel? { get }
}

private class dydxSocialLoginViewPresenter: HostedViewPresenter<dydxSocialLoginViewModel>, dydxSocialLoginViewPresenterProtocol {

    private let connectWalletViewModel: dydxConnectWalletViewModel = {
        let viewModel = dydxConnectWalletViewModel()
        viewModel.onTap = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss", params: nil), animated: true) {_, _ in
                Router.shared?.navigate(to: RoutingRequest(path: "/onboard/wallets", params: nil), animated: true, completion: nil)
            }
        }
        return viewModel
    }()

    private lazy var googleViewModel: dydxOAuthViewModel = {
        let viewModel = dydxOAuthViewModel(providerName: "Google", providerIcon: "logo_google", iconTemplateColor: nil)
        viewModel.onTap = { [weak self] in
            self?.performAction(type: .google, walletId: "google")
        }
        return viewModel
    }()

    private lazy var twitterViewModel: dydxOAuthViewModel = {
        let viewModel = dydxOAuthViewModel(providerName: "X", providerIcon: "logo_twitter", iconTemplateColor: .textPrimary)
        viewModel.onTap = { [weak self] in
            self?.performAction(type: .twitter, walletId: "twitter")
        }
        return viewModel
    }()

    private let walletSetup = dydxPrivyWalletSetup(privy: PrivyAuthManager.shared?.privy)

    private var email: String?

    override init() {
        super.init()

        viewModel = dydxSocialLoginViewModel()
        viewModel?.connectWallet = connectWalletViewModel
        viewModel?.oauthViews = [googleViewModel, twitterViewModel]
        viewModel?.emailInput?.onEdited = { [weak self] text in
            guard let self = self else { return }
            self.email = text
            if let text = text, self.isValidEmail(text) {
                self.viewModel?.emailInput?.isValid = true
            } else {
                self.viewModel?.emailInput?.isValid = false
            }
            self.viewModel?.objectWillChange.send()
        }
        viewModel?.emailInput?.submitAction = { [weak self] in
            guard let self = self else { return }
            self.performEmail(self.email ?? "")
        }
    }

    override func start() {
        super.start()

        walletSetup.$status
            .sink { [weak self] status in
                self?.updateStatus(status: status)
            }
            .store(in: &subscriptions)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern =
            #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#

        let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
        let range = NSRange(email.startIndex..<email.endIndex, in: email)
        return regex?.firstMatch(in: email, options: [], range: range) != nil
    }

    private func performEmail(_ email: String) {
        Task {
            let success = await PrivyAuthManager.shared?.sendEmailCode(email: email)
            if success == true {
                DispatchQueue.main.async {
                    Router.shared?.navigate(to: RoutingRequest(path: "/onboard/social/otp",
                                                               params: ["email": email]), animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    ErrorInfo.shared?.info(title: DataLocalizer.localize(path: "APP.GENERAL.FAILED"),
                                           message: nil,
                                           type: .error,
                                           error: nil)
                }
            }
        }
    }

    private func performAction(type: OAuthType, walletId: String) {
        Task {
            let ret = await PrivyAuthManager.shared?.loginOAuth(type: type)
            if let error = ret?.error {
//                DispatchQueue.main.async {
//                    ErrorInfo.shared?.info(title: DataLocalizer.localize(path: "APP.GENERAL.FAILED"),
//                                           message: nil,
//                                           type: .error,
//                                           error: error)
//                }
            } else {
                let status = await PrivyAuthManager.shared?.getEmbeddedWallet()
                if let status {
                    if let wallet = status.wallet {
                        setupWallet(wallet: wallet, walletId: walletId)
                    } else {
                        let error = status.error
                        DispatchQueue.main.async {
                            ErrorInfo.shared?.info(title: DataLocalizer.localize(path: "APP.GENERAL.FAILED"),
                                                   message: "No embedded wallet",
                                                   type: .error,
                                                   error: error)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        ErrorInfo.shared?.info(title: DataLocalizer.localize(path: "APP.GENERAL.FAILED"),
                                               message: "No embedded wallet",
                                               type: .error,
                                               error: nil)
                    }
                }
            }
        }
    }

    private func updateStatus(status: dydxWalletSetup.Status) {
        switch status {
        case .idle:
            break

        case .started:
            break

        case .connected:
            break

        case .signed(let result):
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                AbacusStateManager.shared.state.currentWallet
                    .prefix(1)
                    .sink { walletInstance in
                        dydxOnboardCompletion.finish(walletInstance: walletInstance, result: result)
                    }
                    .store(in: &self.subscriptions)
            }

        case .error(let error):
            let error = error as NSError
            let title = error.userInfo["title"] as? String ?? ""
            let message = error.userInfo["message"] as? String ?? error.localizedDescription
            DispatchQueue.main.async {
                ErrorInfo.shared?.info(title: title,
                                       message: message,
                                       type: .error,
                                       error: nil, time: nil)
            }
        }
    }

    private func setupWallet(wallet: PrivySDK.EmbeddedWallet, walletId: String) {
        if let action = AbacusStateManager.shared.environment?.walletConnection?.signTypedDataAction,
           let domain = AbacusStateManager.shared.environment?.walletConnection?.signTypedDataDomainName {
            DispatchQueue.main.async { [weak self] in
                self?.walletSetup.start(wallet: wallet, walletId: walletId, signTypedDataAction: action, signTypedDataDomainName: domain)
            }
        }
    }
}
