//
//  dydxTurnkeyAddressWorker.swift
//  dydxPresenters
//
//  Created by Rui Huang on 26/08/2025.
//

import Abacus
import Combine
import dydxStateManager
import ParticlesKit
import RoutingKit
import Utilities
import dydxTurnkey

public final class dydxTurnkeyAddressWorker: BaseWorker {

    public override func start() {
        super.start()

        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }

            AbacusStateManager.shared.state.walletState
                .compactMap { $0.currentWallet }
                .sink { [weak self] wallet in
                    guard wallet.walletId == "turnkey" else {
                        return
                    }

                    self?.fetchAndUpdateTurnkeyAddress(wallet: wallet)
                }
                .store(in: &subscriptions)
        }
    }

    private func fetchAndUpdateTurnkeyAddress(wallet: dydxWalletInstance) {
        guard let dydxAddress = wallet.cosmoAddress,
            let indexerUrl = AbacusStateManager.shared.environment?.endpoints.indexers?.first?.api else {
            return
        }

        TurnkeyBridgeManager.shared.fetchDepositAddresses(dydxAddress: dydxAddress, indexerUrl: indexerUrl) { result in
            guard let jsonData = result?.data(using: .utf8) else {
                Console.shared.log("Unable to parse JSON: \(String(describing: result))")
                return
            }

            do {
                let addresses = try JSONDecoder().decode(DepositAddresses.self, from: jsonData)
                if addresses.evmAddress?.isNotEmpty ?? false {
                    dydxDepositAddressesStateManager.shared.state = addresses
                }
            } catch {
                Console.shared.log("Failed to decode JSON: \(error)")
            }
        }
    }
}
