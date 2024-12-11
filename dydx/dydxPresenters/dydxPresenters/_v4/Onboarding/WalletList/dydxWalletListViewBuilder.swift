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

public class dydxWalletListViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxWalletListViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        let configuration = HostingViewControllerConfiguration(fixedHeight: UIScreen.main.bounds.height)
        return dydxWalletListViewController(presenter: presenter, view: view, configuration: configuration) as? T
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

    override init() {
        super.init()

        viewModel = dydxWalletListViewModel()

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
        if mobileOnly {
            viewModel?.items = [wcModalViewModel] + installedWalletViewModels + uninstalledWalletViewModels
        } else {
            viewModel?.items = [desktopSyncViewModel] + debugScan + [wcModalViewModel] + installedWalletViewModels + uninstalledWalletViewModels
        }
    }
}
