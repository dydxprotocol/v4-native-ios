//
//  dydxSimpleUIMenuAccountViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 19/04/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Abacus
import dydxStateManager
import dydxFormatter
import Combine

protocol dydxSimpleUIMenuAccountViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUIMenuAccountViewModel? { get }
}

class dydxSimpleUIMenuAccountViewPresenter: HostedViewPresenter<dydxSimpleUIMenuAccountViewModel>, dydxSimpleUIMenuAccountViewPresenterProtocol {

    private var currentWallet: dydxWalletInstance?

    private var currentAddressType: dydxSimpleUIMenuAccountViewModel.AddressType = .dydx {
        didSet {
            updateAddress()
        }
    }

    override init() {
        super.init()

        viewModel = dydxSimpleUIMenuAccountViewModel()
    }

    override func start() {
        super.start()

        Publishers.CombineLatest(
            AbacusStateManager.shared.state.walletState,
            AbacusStateManager.shared.state.selectedSubaccount
                .map(\.?.freeCollateral?.current)
                .removeDuplicates()
        )
        .sink { [weak self] wallets, freeCollateral in
            self?.updateViewModel(wallets: wallets, freeCollateral: freeCollateral?.doubleValue)
        }
        .store(in: &subscriptions)
    }

    private func updateViewModel(wallets: dydxWalletState?, freeCollateral: Double?) {
        currentWallet = wallets?.currentWallet
        viewModel?.balance = dydxFormatter.shared.dollar(number: freeCollateral, digits: 2)
        viewModel?.switchAction = { [weak self] in
            guard let self else { return }
            switch self.currentAddressType {
            case .dydx:
                currentAddressType = .source
            case .source:
                currentAddressType = .dydx
            }
        }
        viewModel?.addressAction = { [weak self] in
            guard let self else { return }
            let address: String?
            let message: String?
            switch currentAddressType {
            case .dydx:
                address = currentWallet?.cosmoAddress
                message = DataLocalizer.localize(path: "APP.V4.DYDX_ADDRESS_COPIED")
            case .source:
                address = currentWallet?.ethereumAddress
                message = DataLocalizer.localize(path: "APP.V4.SOURCE_ADDRESS_COPIED")
            }
            if let address, let message {
                UIPasteboard.general.string = address
                ErrorInfo.shared?.info(title: nil,
                                       message: message,
                                       type: .info,
                                       error: nil, time: 3)
            }
        }

        updateAddress()
    }

    private func updateAddress() {
        viewModel?.addressType = currentAddressType
        switch currentAddressType {
        case .dydx:
            viewModel?.address = currentWallet?.cosmoAddress
        case .source:
            viewModel?.address = currentWallet?.ethereumAddress
        }
    }
}
