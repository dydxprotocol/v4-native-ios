//
//  CalendarAuthorizationAction.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 8/10/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import Utilities

public class BluetoothAuthorizationAction: PrivacyPermissionAction {
    public override var path: String? {
        return "/authorization/bluetooth"
    }

    public override func authorization() -> PrivacyPermission? {
        return BluetoothPermission.shared
    }
}
