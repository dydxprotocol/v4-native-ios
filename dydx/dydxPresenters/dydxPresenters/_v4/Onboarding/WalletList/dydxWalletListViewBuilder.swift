//
//  dydxWalletListViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 05/05/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxFormatter
import dydxCartera
import Cartera

public class dydxWalletListViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        if dydxBoolFeatureFlag.privy_ios.isEnabled {
            let presenter = dydxWalletListViewPresenter()
            let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
            return dydxWalletListViewController(presenter: presenter, view: view, configuration: .fullScreenSheet) as? T
        } else {
            let presenter = dydxWalletListViewPresenter_Deprecated()
            let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
            return dydxWalletListViewController_Deprecated(presenter: presenter, view: view, configuration: .fullScreenSheet) as? T
        }
    }
}

private class dydxWalletListViewController: HostingViewController<PlatformView, dydxWalletListViewModel> {
    private var scrollView: UIScrollView?

    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/onboard/wallets" {
            let presenter = presenter as? dydxWalletListViewPresenterProtocol
            presenter?.mobileOnly = (request?.params?["mobileOnly"] as? String) == "true"
            presenter?.viewModel?.onScrollViewCreated = { [weak self] scrollView in
                self?.scrollView = scrollView
            }
            return true
        }
        return false
    }

    // MARK: "half" presentation

    override open var scrollable: UIScrollView? {
        return scrollView
    }
}

private protocol dydxWalletListViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxWalletListViewModel? { get }
    var mobileOnly: Bool { get set }
}

private class dydxWalletListViewPresenter: HostedViewPresenter<dydxWalletListViewModel>, dydxWalletListViewPresenterProtocol {

    var mobileOnly: Bool = false {
        didSet {
            updateWallets()
        }
    }

    private let socialViewModel: dydxSocialViewModel = {
        let viewModel = dydxSocialViewModel()
        viewModel.onTap = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss", params: nil), animated: true) {_, _ in
                Router.shared?.navigate(to: RoutingRequest(path: "/onboard/social", params: nil), animated: true, completion: nil)
            }
        }
        return viewModel
    }()

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

    private let metamaskViewModel = dydxMetamaskViewModel()

    private let phantomViewModel = dydxPhantomViewModel()

    private let coinbaseViewModel = dydxCoinbaseViewModel()

    private let wcModalViewModel: dydxWcModalViewModel = {
        let viewModel = dydxWcModalViewModel()
        viewModel.onTap = {
           Router.shared?.navigate(to: RoutingRequest(path: "/onboard/connect", params: nil), animated: true, completion: nil)
        }
        return viewModel
    }()

    override init() {
        super.init()

        viewModel = dydxWalletListViewModel()
        viewModel?.syncDesktopView = mobileOnly ? nil : desktopSyncViewModel
        viewModel?.debugView = UIDevice.current.isSimulator ? debugScanViewModel : nil
        viewModel?.metamaskView = metamaskViewModel
        viewModel?.phantomView = phantomViewModel
        viewModel?.coinbaseView = coinbaseViewModel
        viewModel?.socialView = socialViewModel
        viewModel?.wcModalView = wcModalViewModel

        updateWallets()
    }

    private func updateWallets() {
        let wallets = CarteraConfig.shared.wallets
        let metamask = wallets.first { $0.id == "c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96" }
        configureWallet(metamask, viewModel: metamaskViewModel)
        let phantom = wallets.first { $0.id == "phantom-wallet" }
        configureWallet(phantom, viewModel: phantomViewModel)
        let coinbase = wallets.first { $0.id == "coinbase-wallet" }
        configureWallet(coinbase, viewModel: coinbaseViewModel)
    }

    private func configureWallet(_ wallet: Wallet?, viewModel: dydxWalletListItemView) {
        guard let wallet else { return }

        let installed = wallet.config?.installed ?? false
        viewModel.isInstall = installed

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
}
