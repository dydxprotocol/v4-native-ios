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
        super.init(moduleName: "TurnkeyLogin", initialProperties: nil)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        TurnkeyBridgeManager.shared.testFunction()
    }
}
