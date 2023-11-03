//
//  UIDevice+Utils.swift
//  UIToolkits
//
//  Created by Qiang Huang on 12/16/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import UIKit

extension UIDevice {
    public var systemVersionAsFloat: Double {
        let version = systemVersion
        let versions = version.split(separator: ".")
        var versionAsFloat: Double = 0
        for i in 0 ..< versions.count {
            let element = parser.asNumber(versions[i])?.doubleValue ?? 0
            switch i {
            case 0:
                versionAsFloat = element

            case 1:
                versionAsFloat += element / 100.0

            case 2:
                versionAsFloat += element / 10000.0

            default:
                break
            }
        }
        return versionAsFloat
    }

    public var canSplit: Bool {
        return userInterfaceIdiom == .pad || userInterfaceIdiom == .tv
    }

    public var isSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }
}
