//
//  dydxVaultTosViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 31/10/2024.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager

public class dydxVaultTosViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxVaultTosViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxVaultTosViewController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxVaultTosViewController: HostingViewController<PlatformView, dydxVaultTosViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/vault/tos" {
            return true
        }
        return false
    }
}

private protocol dydxVaultTosViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxVaultTosViewModel? { get }
}

private class dydxVaultTosViewPresenter: HostedViewPresenter<dydxVaultTosViewModel>, dydxVaultTosViewPresenterProtocol {
    override init() {
        super.init()

        let operatorName = AbacusStateManager.shared.environment?.megavaultOperatorName ?? "-"
        let vaultLearnMoreUrl = AbacusStateManager.shared.environment?.links?.vaultLearnMore
        let operatorLearnMoreUrl = AbacusStateManager.shared.environment?.links?.vaultOperatorLearnMore

        viewModel = dydxVaultTosViewModel()
        viewModel?.vaultDesc = DataLocalizer.localize(path: "APP.VAULTS.VAULT_DESCRIPTION", params: nil)
        viewModel?.operatorDesc = DataLocalizer.localize(path: "APP.VAULTS.VAULT_OPERATOR_DESCRIPTION",
                                                         params: ["OPERATOR_NAME": operatorName])
        viewModel?.operatorLearnMore = DataLocalizer.localize(path: "APP.VAULTS.LEARN_MORE_ABOUT_OPERATOR",
                                                              params: ["OPERATOR_NAME": operatorName])
        viewModel?.ctaAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }
        viewModel?.operatorAction = {
            if let operatorLearnMoreUrl = operatorLearnMoreUrl,
                let url = URL(string: operatorLearnMoreUrl), URLHandler.shared?.canOpenURL(url) ?? false {
                URLHandler.shared?.open(url, completionHandler: nil)
            }
        }
        viewModel?.vaultAction = {
            if let vaultLearnMoreUrl = vaultLearnMoreUrl,
               let url = URL(string: vaultLearnMoreUrl), URLHandler.shared?.canOpenURL(url) ?? false {
                URLHandler.shared?.open(url, completionHandler: nil)
            }
        }
    }
}
