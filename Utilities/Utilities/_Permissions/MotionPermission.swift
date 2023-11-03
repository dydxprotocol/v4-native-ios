//
//  MotionPermission.swift
//  Utilities
//
//  Created by Qiang Huang on 9/15/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import CoreMotion

@objc public class MotionPermission: PrivacyPermission {
    private static var _shared: MotionPermission?
    public static var shared: MotionPermission {
        get {
            if _shared == nil {
                _shared = MotionPermission()
            }
            return _shared!
        }
        set {
            _shared = newValue
        }
    }

    private var motion: CMMotionActivityManager = CMMotionActivityManager()

    override public func awakeAfter(using aDecoder: NSCoder) -> Any? {
        if type(of: self)._shared == nil {
            type(of: self)._shared = super.awakeAfter(using: aDecoder) as? MotionPermission
        }
        return type(of: self).shared
    }

    override public var requestMessage: String? {
        return "Please enable motion in your app settings."
    }

    override public func currentAuthorizationStatus(completion: @escaping PermissionStatusCompletionHandler) {
        let authorization = CMMotionActivityManager.authorizationStatus()
        switch authorization {
        case .notDetermined:
            completion(.notDetermined, nil)

        case .authorized:
            completion(.authorized, nil)

        case .restricted:
            completion(.restricted, nil)

        case .denied:
            fallthrough
        default:
            completion(.denied, nil)
        }
    }

    override public func promptToAuthorize() {
        let now = Date()
        motion.queryActivityStarting(from: now, to: now, to: .main) { [weak self] _, _ in
            self?.refreshStatus()
        }
    }
}
