//
//  NotificationPermissionAction.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 8/5/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import Utilities

public class NotificationPermissionAction: PrivacyPermissionAction {
    override public var primer: String? {
        return "/primer/notification"
    }
    
    override public var path: String? {
        return "/authorization/notification"
    }

    override public func authorization() -> PrivacyPermission? {
        return NotificationPermission.shared
    }
}
