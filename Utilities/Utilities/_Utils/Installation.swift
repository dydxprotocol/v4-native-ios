//
//  Installation.swift
//  Utilities
//
//  Created by Qiang Huang on 8/23/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

public class Installation {
    public enum Source {
        case debug
        case testFlight
        case appStore
        case jailBroken // potentially side-loaded
    }

    // This is private because the use of 'appConfiguration' is preferred.
    private static let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"

    private static let isAppStore = {
        // Keep this code for reference. In case "sandboxReceipt" changes in later iOS
        if let receipt: URL = Bundle.main.appStoreReceiptURL {
            var error: NSError?
            if (receipt as NSURL).checkResourceIsReachableAndReturnError(&error), error == nil {
                return true
            }
        }
        return false
    }()

    // This can be used to add debug statements.
    static var isDebug: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }

    private static var isJailBroken: Bool = {
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

    public static var source: Source {
        if isJailBroken {
            return .jailBroken
        } else if isDebug {
            return .debug
        } else if isTestFlight {
            return .testFlight
        } else {
            return .appStore
        }
    }

    public static var isSimulator: Bool = {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }()
}
