//
//  CameraAuthorizationAction.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 8/5/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import UIAppToolkits
import Utilities

public class CameraPermissionAction: PrivacyPermissionAction {
    override public var primer: String? {
        return nil
//        return "/primer/camera"
    }

    override public var path: String? {
        return "/authorization/camera"
    }

    override public init() {
        super.init()
        required = true
    }

    override public func authorization() -> PrivacyPermission? {
        return CameraPermission.shared
    }
}
