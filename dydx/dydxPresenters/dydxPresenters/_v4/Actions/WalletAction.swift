//
//  WalletAction.swift
//  dydxPresenters
//
//  Created by Qiang Huang on 5/1/21.
//

import RoutingKit
import Utilities
import dydxStateManager
import dydxCartera

public class WalletActionBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        WalletAction() as? T
    }
}

public protocol WalletActionProtocol {
    func connect(walletId: String?)
    func disconnect(ethereumAddress: String?)
    func etherscan(ethereumAddress: String?)
}

public class WalletAction: NSObject, NavigableProtocol {
    public static var shared: WalletActionProtocol? = WalletActionImp()
    open func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        switch request?.path {
        case "/action/wallet/connect":
            if let walletId = parser.asString(request?.params?["walletId"]) {
                WalletAction.shared?.connect(walletId: walletId)
            }
            completion?(nil, true)

        case "/action/wallet/disconnect":
            let ethereumAddress = parser.asString(request?.params?["ethereumAddress"])
            WalletAction.shared?.disconnect(ethereumAddress: ethereumAddress)
            completion?(nil, true)

        case "/action/wallet/etherscan":
            WalletAction.shared?.etherscan(ethereumAddress: parser.asString(request?.params?["ethereumAddress"]))
            completion?(nil, true)

        case "/action/wallet/copy":
            completion?(nil, true)

        default:
            completion?(nil, false)
        }
    }
}

private class WalletActionImp: WalletActionProtocol {
    private let walletSetup = dydxV4WalletSetup()

    public func connect(walletId: String?) {
        if let action = AbacusStateManager.shared.environment?.walletConnection?.signTypedDataAction,
           let domain = AbacusStateManager.shared.environment?.walletConnection?.signTypedDataDomainName {
            walletSetup.start(walletId: walletId,
                              ethereumChainId: AbacusStateManager.shared.ethereumChainId,
                              signTypedDataAction: action,
                              signTypedDataDomainName: domain,
                              useModal: walletId == nil)
        }
    }

    public func disconnect(ethereumAddress: String?) {
        let prompter = PrompterFactory.shared?.prompter()
        let signout = PrompterAction(title: DataLocalizer.localize(path: "APP.GENERAL.SIGN_OUT"), style: .destructive, enabled: true) { [weak self] in
            self?.reallyDisconnect()
        }
        let cancel = PrompterAction(title: DataLocalizer.localize(path: "APP.GENERAL.CANCEL"), style: .cancel, enabled: true, selection: nil)
        prompter?.title = DataLocalizer.localize(path: "APP.GENERAL.SIGN_OUT_WARNING")
        prompter?.prompt([signout, cancel])
    }

    private func reallyDisconnect() {
        AbacusStateManager.shared.disconnectAndReplaceCurrentWallet()
        Tracking.shared?.log(event: "DisconnectWallet", data: nil)
    }

    public func etherscan(ethereumAddress: String?) {
        if let ethereumAddress = ethereumAddress {
            let string = "https://ropsten.etherscan.io/address/\(ethereumAddress)"
            Router.shared?.navigate(to: URL(string: string), completion: nil)
        }
    }
}
