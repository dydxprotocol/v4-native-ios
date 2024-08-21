//
//  BluetoothPermission.swift
//  Utilities
//
//  Created by Qiang Huang on 7/18/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import CoreBluetooth
import Foundation

@objc public class BluetoothPermission: PrivacyPermission, CBCentralManagerDelegate {
    private static var _shared: BluetoothPermission?
    public static var shared: BluetoothPermission {
        get {
            if _shared == nil {
                _shared = BluetoothPermission()
            }
            return _shared!
        }
        set {
            _shared = newValue
        }
    }

    public override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        if type(of: self)._shared == nil {
            type(of: self)._shared = super.awakeAfter(using: aDecoder) as? BluetoothPermission
        }
        return type(of: self).shared
    }

    public override var requestMessage: String? {
        return "Please enable Bluetooth in your app settings."
    }

    public var centralManager: CBCentralManager? {
        didSet {
            if centralManager !== oldValue {
                oldValue?.delegate = nil
                centralManager?.delegate = self
            }
        }
    }

    public override func currentAuthorizationStatus(completion: @escaping PermissionStatusCompletionHandler) {
        var status: EPrivacyPermission = .authorized
        if #available(iOS 13.1, *) {
            switch CBManager.authorization {
            case .notDetermined:
                status = .notDetermined

            case .denied:
                status = .denied

            case .allowedAlways:
                status = .authorized

            case .restricted:
                status = .restricted

            default:
                status = .notDetermined
                break
            }
        }
        completion(status, true)
    }

    public override func promptToAuthorize() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        centralManager?.delegate = nil
        centralManager = nil
        refreshStatus()
    }
}
