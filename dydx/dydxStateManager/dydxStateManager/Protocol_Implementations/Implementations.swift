//
//  Implementations.swift
//  dydxStateManager
//
//  Created by John Huang on 7/27/23.
//

import Abacus

extension IOImplementations {
    public static let shared = IOImplementations(rest: AbacusRestImp(),
                                                 webSocket: AbacusWebSocketImp(),
                                                 chain: AbacusChainImp(),
                                                 tracking: AbacusTrackingImp(),
                                                 threading: AbacusThreadingImp(),
                                                 timer: AbacusTimerImp(),
                                                 fileSystem: AbacusFileSystemImp(),
                                                 logging: nil)
}

extension UIImplementations {
    public static var shared: UIImplementations?

    public static func reset(language: String?) {
        let systemLanguage = language ?? Locale.preferredLanguages.first
        #if DEBUG
            let loadLocalOnly = true
        #else
            let loadLocalOnly = false
        #endif
        let localizer = shared?.localizer ?? DynamicLocalizer(ioImplementations: IOImplementations.shared,
                                                             systemLanguage: systemLanguage ?? "en",
                                                             path: "/config",
                                                             endpoint: "https://dydx-v4-shared-resources.vercel.app/config",
                                                             loadLocalOnly: loadLocalOnly)
        let formatter = shared?.formatter ?? AbacusFormatterImp()
        shared = UIImplementations(localizer: localizer, formatter: formatter)
    }
}
