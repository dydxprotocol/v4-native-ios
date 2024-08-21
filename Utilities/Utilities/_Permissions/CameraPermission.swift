//
//  CameraPermission.swift
//  Utilities
//
//  Created by Qiang Huang on 7/18/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import AVFoundation
import Foundation

@objc public class CameraPermission: PrivacyPermission {
    private static var _shared: CameraPermission?
    public static var shared: CameraPermission {
        get {
            if _shared == nil {
                _shared = CameraPermission()
            }
            return _shared!
        }
        set {
            _shared = newValue
        }
    }

    public override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        if type(of: self)._shared == nil {
            type(of: self)._shared = super.awakeAfter(using: aDecoder) as? CameraPermission
        }
        return type(of: self).shared
    }

    public override var requestMessage: String? {
        return "Please enable Camera in your app settings."
    }

    public override func currentAuthorizationStatus(completion: @escaping PermissionStatusCompletionHandler) {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        var status: EPrivacyPermission = .notDetermined
        switch authorizationStatus {
        case .authorized:
            status = .authorized

        case .denied:
            status = .denied

        case .restricted:
            status = .restricted

        case .notDetermined:
            status = .notDetermined

        default:
            status = .notDetermined
        }
        completion(status, nil)
    }

    public override func promptToAuthorize() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                self?.refreshStatus()
            }
        })
    }
}
