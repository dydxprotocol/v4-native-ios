//
//  Installation.swift
//  Utilities
//
//  Created by Qiang Huang on 8/23/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

public class Installation {
    public static var appStore: Bool = {
        if let receipt: URL = Bundle.main.appStoreReceiptURL {
            var error: NSError?
            if (receipt as NSURL).checkResourceIsReachableAndReturnError(&error), error == nil {
                return true
            }
        }
        return false
    }()

    public static var jailBroken: Bool = {
        #if targetEnvironment(simulator)
            return false
        #else
            if FileManager.default.fileExists(atPath: "/Applications/Cydia.app")
                || FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib")
                || FileManager.default.fileExists(atPath: "/bin/bash")
                || FileManager.default.fileExists(atPath: "/usr/sbin/sshd")
                || FileManager.default.fileExists(atPath: "/etc/apt")
                || FileManager.default.fileExists(atPath: "/private/var/lib/apt/")
                || URLHandler.shared?.canOpenURL(URL(string: "cydia://package/com.example.package")!) ?? false {
                return true
            }

            let stringToWrite = "Something to test"
            let file = "/private/poikjkt.txt"
            try? FileManager.default.removeItem(atPath: file)
            do {
                try stringToWrite.write(toFile: file, atomically: true, encoding: String.Encoding.utf8)

                return true
            } catch {
                return false
            }
        #endif
    }()

    public static var isSimulator: Bool = {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }()
}
