//
//  dydxWalletListViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 2/28/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Cartera
import dydxStateManager
import dydxFormatter

class dydxWalletListViewController_Deprecated: HostingViewController<PlatformView, dydxWalletListViewModel_Deprecated> {
    private var scrollView: UIScrollView?

    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/onboard/wallets" {
            let presenter = presenter as? dydxWalletListViewPresenterProtocol_Deprecated
            presenter?.mobileOnly = (request?.params?["mobileOnly"] as? String) == "true"
            presenter?.viewModel?.onScrollViewCreated = { [weak self] scrollView in
                self?.scrollView = scrollView
            }
            presenter?.backButtonRoute = request?.params?["backButtonRoute"] as? String

            return true
        }
        return false
    }

    // MARK: "half" presentation

    override open var scrollable: UIScrollView? {
        return scrollView
    }
}

protocol dydxWalletListViewPresenterProtocol_Deprecated: HostedViewPresenterProtocol {
    var viewModel: dydxWalletListViewModel_Deprecated? { get }
    var mobileOnly: Bool { get set }
    var backButtonRoute: String? { get set }
}

class dydxWalletListViewPresenter_Deprecated: HostedViewPresenter<dydxWalletListViewModel_Deprecated>, dydxWalletListViewPresenterProtocol_Deprecated {

    var mobileOnly: Bool = false {
        didSet {
            updateWallets()
        }
    }

    var backButtonRoute: String? {
        didSet {
            if let backButtonRoute = backButtonRoute {
                viewModel?.onBackButtonTapped = {
                    Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss", params: nil), animated: true) {_, _ in
                        Router.shared?.navigate(to: RoutingRequest(path: backButtonRoute), animated: true, completion: nil)
                    }
                }
            } else {
                viewModel?.onBackButtonTapped = nil
            }
        }
    }

    private let desktopSyncViewModel: dydxSyncDesktopViewModel = {
        let viewModel = dydxSyncDesktopViewModel()
        viewModel.onTap = {
            Router.shared?.navigate(to: RoutingRequest(path: "/onboard/scan/instructions"), animated: true, completion: nil)
        }
        return viewModel
    }()

    private let debugScanViewModel: dydxDebugScanViewModel = {
        let viewModel = dydxDebugScanViewModel()
        viewModel.onTap = {
            Router.shared?.navigate(to: RoutingRequest(path: "/onboard/qrcode"), animated: true, completion: nil)
        }
        return viewModel
    }()

    private let wcModalViewModel: dydxWcModalViewModel = {
        let viewModel = dydxWcModalViewModel()
        viewModel.onTap = {
           Router.shared?.navigate(to: RoutingRequest(path: "/onboard/connect", params: nil), animated: true, completion: nil)
        }
        return viewModel
    }()

    private let socialViewModel: dydxSocialViewModel = {
        let viewModel = dydxSocialViewModel()
        viewModel.onTap = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss", params: nil), animated: true) {_, _ in
                Router.shared?.navigate(to: RoutingRequest(path: "/onboard/social", params: nil), animated: true, completion: nil)
            }
        }
        return viewModel
    }()

    override init() {
        super.init()

        viewModel = dydxWalletListViewModel_Deprecated()

        updateWallets()
    }

    private func updateWallets() {
        var installedWalletViewModels = [dydxWalletViewModel]()
        var uninstalledWalletViewModels = [dydxWalletViewModel]()

        for wallet: Cartera.Wallet in CarteraConfig.shared.wallets {
            let viewModel = dydxWalletViewModel()
            viewModel.shortName = wallet.metadata?.shortName
            if let imageName = wallet.userFields?["imageName"],
               let folder = AbacusStateManager.shared.environment?.walletConnection?.images {
                viewModel.imageUrl = URL(string: folder + imageName)
            } else {
                viewModel.imageUrl = nil
            }
            let installed =  wallet.config?.installed ?? false
            viewModel.installed = installed
            if installed {
                installedWalletViewModels.append(viewModel)
            } else {
                uninstalledWalletViewModels.append(viewModel)
            }

            viewModel.onTap = {
                guard let walletId = wallet.id else {
                    assertionFailure("wallet.id not found")
                    return
                }
                if installed {
                    let params =  ["walletId": walletId]
                    Router.shared?.navigate(to: RoutingRequest(path: "/onboard/connect", params: params), animated: true, completion: nil)
                } else if let urlString = wallet.app?.ios, let url = URL(string: urlString) {
                    URLHandler.shared?.open(url, completionHandler: nil)
                }
            }
        }

        let debugScan = UIDevice.current.isSimulator ? [debugScanViewModel] : []
        let social = dydxBoolFeatureFlag.privy_ios.isEnabled ? [socialViewModel] : []
        let allWallets = installedWalletViewModels + uninstalledWalletViewModels
        if mobileOnly {
            viewModel?.items = [wcModalViewModel] + social + allWallets
        } else {
            if dydxBoolFeatureFlag.turnkey_ios.isEnabled {
                viewModel?.items = debugScan + [wcModalViewModel] + social + allWallets
            } else {
                viewModel?.items = [desktopSyncViewModel] + debugScan + [wcModalViewModel] + social + allWallets
            }
        }
    }
}
