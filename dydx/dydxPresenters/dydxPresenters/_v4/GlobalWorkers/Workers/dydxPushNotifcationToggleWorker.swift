//
//  dydxPushNotifcationToggleWorker.swift
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

public final class dydxPushNotifcationToggleWorker: BaseWorker {

    public override func start() {
        super.start()

        changeObservation(from: nil, to: NotificationService.shared, keyPath: #keyPath(NotificationHandler.permission)) {  _, _, _, _ in
            let pushNotificationEnabled = NotificationService.shared?.permission == .authorized
            SettingsStore.shared?.setValue(pushNotificationEnabled, forKey: dydxSettingsStoreKey.shouldDisplayInAppNotifications.rawValue)
        }
    }
}
