//
//  CalendarAuthorizationAction.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 8/10/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Utilities

public class CalendarAuthorizationAction: PrivacyPermissionAction {
    public override var path: String? {
        return "/authorization/calendar"
    }

    public override func authorization() -> PrivacyPermission? {
        return CalendarPermission.shared
    }
}
