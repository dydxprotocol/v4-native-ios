//
//  NotificationPermissionAction.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 8/5/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import Utilities

public class NotificationPermissionActionBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let action = NotificationPermissionAction()
        return action as? T
    }
}

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
