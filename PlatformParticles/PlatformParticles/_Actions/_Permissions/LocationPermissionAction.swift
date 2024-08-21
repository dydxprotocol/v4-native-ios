//
//  LocationAuthorizationAction.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 8/10/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import ParticlesKit
import Utilities

public class LocationPermissionAction: PrivacyPermissionAction {
    override public var path: String? {
        return "/authorization/location"
    }

    override public func authorization() -> PrivacyPermission? {
        return LocationPermission.shared
    }
}
