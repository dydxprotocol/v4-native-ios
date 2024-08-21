//
//  PhotoAlbumPermission.swift
//  Utilities
//
//  Created by Qiang Huang on 7/18/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Foundation
import Photos

@objc public class PhotoAlbumsPermission: PrivacyPermission {
    private static var _shared: PhotoAlbumsPermission?
    public static var shared: PhotoAlbumsPermission {
        get {
            if _shared == nil {
                _shared = PhotoAlbumsPermission()
            }
            return _shared!
        }
        set {
            _shared = newValue
        }
    }

    public override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        if type(of: self)._shared == nil {
            type(of: self)._shared = super.awakeAfter(using: aDecoder) as? PhotoAlbumsPermission
        }
        return type(of: self).shared
    }

    public override var requestMessage: String? {
        return "Please enable Photo Albums in your app settings."
    }

    public override func currentAuthorizationStatus(completion: @escaping PermissionStatusCompletionHandler) {
        let authorizationStatus: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
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
        PHPhotoLibrary.requestAuthorization({ [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                if let self = self {
                    self.refreshStatus()
                }
            }
        })
    }
}
