//
//  dydxPushNotificationToggleWorker.swift
//  dydxPresenters
//
//  Created by Rui Huang on 13/09/2024.
//

import Foundation
import Combine
import dydxStateManager
import ParticlesKit
import RoutingKit
import Utilities

public final class dydxPushNotificationToggleWorker: BaseWorker {

    public override func start() {
        super.start()

        // Sync the app settings value to the system notification settings
        changeObservation(from: nil, to: NotificationService.shared, keyPath: #keyPath(NotificationHandler.permission)) {  _, _, _, _ in
            let pushNotificationEnabled = NotificationService.shared?.permission == .authorized
            SettingsStore.shared?.setValue(pushNotificationEnabled, forKey: dydxSettingsStoreKey.shouldDisplayInAppNotifications.rawValue)
        }
    }
}
