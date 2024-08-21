//
//  dydxGasTokenViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 10/06/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import PlatformUIJedio
import Utilities
import dydxStateManager
import Abacus

public class dydxGasTokenViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxGasTokenViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        let viewController = SettingsViewController(presenter: presenter, view: view, configuration: .default)
        viewController.requestPath = "/settings/gas_token"
        return viewController as? T
    }
}

private class dydxGasTokenViewPresenter: FieldSettingsViewPresenter {
    init() {
        super.init(definitionFile: "settings_gas_token.json", fieldName: "gas_token", keyValueStore: SettingsStore.shared)

        let header = SettingHeaderViewModel()
        header.text = DataLocalizer.localize(path: "APP.GENERAL.PAY_GAS_WITH")
        header.dismissAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }
        viewModel?.headerViewModel = header
    }

    override func onOptionSelected(option: [String: Any], changed: Bool) {
        if changed, let value = option["value"] as? String {
            if let token = GasToken.from(tokenName: value) {
                AbacusStateManager.shared.setGasToken(token: token)
                Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
            } else {
                ErrorLogging.shared?.e(tag: "dydxGasTokenViewPresenter",
                                       message: "Invalid token: \(value)")
            }
        }
    }

    override func textForOption(option: [String: Any]) -> String? {
        GasTokenOptionTransformer().textForOption(option: option) ?? super.textForOption(option: option)
    }
}

class GasTokenOptionTransformer: SettingsOptionTransformProtocol {
    func textForOption(option: [String: Any]) -> String? {
        switch option["value"] as? String {
        case "USDC":
            return AbacusStateManager.shared.environment?.usdcTokenInfo?.name
        case "NATIVE":
            return AbacusStateManager.shared.environment?.nativeTokenInfo?.name
        default:
            return nil
        }
    }
}
