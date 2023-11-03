//
//  CameraAuthorizationAction.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 8/5/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import Utilities

public class PhotoAlbumsPermissionAction: PrivacyPermissionAction {
    override public var primer: String? {
        return nil
//        return "/primer/album"
    }

    override public var path: String? {
        return "/authorization/album"
    }

    override public func authorization() -> PrivacyPermission? {
        return PhotoAlbumsPermission.shared
    }
}
