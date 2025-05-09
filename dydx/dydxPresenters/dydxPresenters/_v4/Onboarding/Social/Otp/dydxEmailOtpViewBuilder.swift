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
import dydxCartera
import PrivySDK
import dydxStateManager
import Abacus

public class dydxEmailOtpViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxEmailOtpViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxEmailOtpViewController(presenter: presenter, view: view, configuration: .fullScreenSheet) as? T
    }
}

private class dydxEmailOtpViewController: HostingViewController<PlatformView, dydxEmailOtpViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/onboard/social/otp",
           let email = request?.params?["email"] as? String {
            let presenter = presenter as? dydxEmailOtpViewPresenterProtocol
            presenter?.email = email
            return true
        }
        return false
    }
}

private protocol dydxEmailOtpViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxEmailOtpViewModel? { get }
    var email: String { get set }
}

private class dydxEmailOtpViewPresenter: HostedViewPresenter<dydxEmailOtpViewModel>, dydxEmailOtpViewPresenterProtocol {
    var email: String = "" {
        didSet {
            viewModel?.email = email
        }
    }

    private let walletSetup = dydxPrivyWalletSetup(privy: PrivyAuthManager.shared?.privy)

    override init() {
        super.init()

        viewModel = dydxEmailOtpViewModel()
        viewModel?.resendAction = { [weak self] in
            self?.resentEmail()
        }
        viewModel?.onOtpChanged = { [weak self] otp in
            if otp.length == 6 {
                self?.validateOtpCode(otp: otp)
            }
        }
        viewModel?.headerViewModel?.backButtonAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss", params: nil), animated: true) {_, _ in
            }
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

    private func resentEmail() {
        Task {
            let success = await PrivyAuthManager.shared?.sendEmailCode(email: email)
            if success != true {
                DispatchQueue.main.async {
                    ErrorInfo.shared?.info(title: DataLocalizer.localize(path: "APP.GENERAL.FAILED"),
                                           message: nil,
                                           type: .error,
                                           error: nil)
                }
            } else {
                let email = self.email
                DispatchQueue.main.async {
                    ErrorInfo.shared?.info(title: DataLocalizer.localize(path: "APP.ONBOARDING.CODE_SENT"),
                                           message: DataLocalizer.localize(path: "APP.ONBOARDING.CHECK_EMAIL_FOR_OTP_CODE",
                                                                           params: ["EMAIL": email]),
                                           type: .info,
                                           error: nil)
                }
            }
        }
    }

    private func validateOtpCode(otp: String?) {
        guard let otp else {
            ErrorInfo.shared?.info(title: DataLocalizer.localize(path: "APP.GENERAL.FAILED"),
                                   message: "Invalid OTP code",
                                   type: .error,
                                   error: nil)
            return
        }

        Task {
            let ret = await PrivyAuthManager.shared?.loginWithEmail(email: email, code: otp)
            if let error = ret?.error {
                DispatchQueue.main.async {
                    ErrorInfo.shared?.info(title: DataLocalizer.localize(path: "APP.GENERAL.FAILED"),
                                           message: DataLocalizer.localize(path: "APP.ONBOARDING.INVALID_CODE"),
                                           type: .error,
                                           error: error)
                }
            } else {
                let status = await PrivyAuthManager.shared?.getEmbeddedWallet()
                if let status {
                    if let wallet = status.wallet {
                        setupWallet(wallet: wallet, walletId: "email")
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

    private func setupWallet(wallet: PrivySDK.EmbeddedWallet, walletId: String) {
        if let action = AbacusStateManager.shared.environment?.walletConnection?.signTypedDataAction,
           let domain = AbacusStateManager.shared.environment?.walletConnection?.signTypedDataDomainName {
            DispatchQueue.main.async { [weak self] in
                self?.walletSetup.start(wallet: wallet, walletId: walletId, signTypedDataAction: action, signTypedDataDomainName: domain)
            }
        }
    }
}
