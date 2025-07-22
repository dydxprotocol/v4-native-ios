//
//  dydxTurnkeyLoginViewConntroller.swift
//  dydxPresenters
//
//  Created by Rui Huang on 16/07/2025.
//

import UIKit
import React
import React_RCTAppDelegate
import dydxTurnkey

class dydxTurnkeyLoginViewConntroller: ReactNativeHostingController {
    init() {
        guard let appScheme = Bundle.main.scheme else {
            fatalError((#file as NSString).lastPathComponent + ": Bundle.main.scheme is nil")
        }
        let initialProperties: [String: Any] = [
            // From https://console.cloud.google.com/auth/clients?inv=1&invt=Ab1olg&project=dydx-v4
            "googleClientId": "441463123744-a02e7s84okic2ggqgdo7e7hlgpvkj3p8.apps.googleusercontent.com",
            "appScheme": appScheme,
            "turnkeyUrl": "https://api.turnkey.com",
            // From Turnkey console
            "turnkeyOrgId": "3174ac51-1637-47d8-9456-19549963e2ed"
        ]
        super.init(moduleName: "TurnkeyLogin", initialProperties: initialProperties)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        TurnkeyBridgeManager.shared.testFunction()
    }
}
