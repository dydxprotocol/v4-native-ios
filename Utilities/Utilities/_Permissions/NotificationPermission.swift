//
//  NotificationPermission.swift
//  Utilities
//
//  Created by Qiang Huang on 7/18/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import UserNotifications

@objc public class NotificationPermission: PrivacyPermission {
    private static var _shared: NotificationPermission?
    public static var shared: NotificationPermission {
        get {
            if _shared == nil {
                _shared = NotificationPermission()
            }
            return _shared!
        }
        set {
            _shared = newValue
        }
    }

    public override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        if type(of: self)._shared == nil {
            type(of: self)._shared = super.awakeAfter(using: aDecoder) as? NotificationPermission
        }
        return type(of: self).shared
    }

    public override var requestMessage: String? {
        return "Please enable notifications in your app settings."
    }

    public override func currentAuthorizationStatus(completion: @escaping PermissionStatusCompletionHandler) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            var status: EPrivacyPermission = .notDetermined
            switch settings.authorizationStatus {
            case .authorized:
                status = .authorized
            case .denied:
                status = .denied
            case .notDetermined:
                status = .notDetermined
            default:
                status = .notDetermined
            }
            completion(status, nil)
        }
    }

    public override func promptToAuthorize() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] _, _ in
            DispatchQueue.main.async { [weak self] in
                self?.refreshStatus()
            }
        }
    }
}
