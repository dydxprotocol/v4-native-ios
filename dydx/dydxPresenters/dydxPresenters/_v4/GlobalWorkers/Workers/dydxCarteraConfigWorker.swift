//
//  dydxCarteraConfigWorker.swift
//  dydxPresenters
//
//  Created by Rui Huang on 10/12/23.
//

import Abacus
import Combine
import dydxStateManager
import ParticlesKit
import Utilities
import Cartera

final class dydxCarteraConfigWorker: BaseWorker {

    public override func start() {
        super.start()

        let filePath = "configs/wallets.json"
        #if DEBUG
        let url: String? = nil
        #else
        let url = AbacusStateManager.shared.deploymentUri + "/" + filePath
        #endif
        CachedFileLoader.shared.loadData(filePath: filePath, url: url) { walletJson in
            if let walletJson = walletJson {
                CarteraConfig.shared.registerWallets(configJsonData: walletJson)
            }
        }

        AbacusStateManager.shared.$currentEnvironment
            .removeDuplicates()
            .sink { [weak self]_ in
                if let environment = AbacusStateManager.shared.environment {
                    self?.configureCartera(environment: environment)
                }
            }
            .store(in: &subscriptions)
    }

    private func configureCartera(environment: V4Environment) {
        if let wallets = environment.walletConnection?.walletConnect?.v2?.wallets?.ios {
            CarteraConfig.shared.wcModalWallets = wallets
        }
        let config = WalletProvidersConfig(walletConnectV1: nil,
                                           walletConnectV2: WalletConnectV2Config(environment: environment),
                                           walletSegue: WalletSegueConfig(environment: environment))
        CarteraConfig.shared.walletProvidersConfig = config
    }
}

extension WalletConnectV2Config {
    init?(environment: V4Environment) {
        guard let projectId = environment.walletConnection?.walletConnect?.v2?.projectId,
              let clientName = environment.walletConnection?.walletConnect?.client.name,
              let clientDescription = environment.walletConnection?.walletConnect?.client.description,
              let scheme = Bundle.main.scheme
        else {
            return nil
        }

        let iconUrls = [environment.walletConnection?.walletConnect?.client.iconUrl].filterNils()
        self.init(projectId: projectId,
                  clientName: clientName,
                  clientDescription: clientDescription,
                  clientUrl: AbacusStateManager.shared.deploymentUri,
                  iconUrls: iconUrls,
                  redirectNative: scheme,
                  redirectUniversal: AbacusStateManager.shared.deploymentUri,
                  appGroupIdentifier: "group.exchange.dydx.v4"
        )
    }
}

extension WalletSegueConfig {
    init?(environment: V4Environment) {
        guard let callbackUrl = environment.walletConnection?.walletSegue?.callbackUrl,
                let _ = URL(string: callbackUrl) else {
            return nil
        }

        self.init(callbackUrl: callbackUrl)
    }
}
