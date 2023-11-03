//
//  Scanners.swift
//  UIToolkits
//
//  Created by Qiang Huang on 6/1/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import UIKit
import Utilities

public final class Scanners: NSObject, SingletonProtocol {
    public static var shared: Scanners = Scanners()

    private var scanners: [String: ScannerProtocol] = [:]

    public func install(scanner: ScannerProtocol, type: String) {
        scanners[type] = scanner
    }

    public func scanner(type: String) -> ScannerProtocol? {
        return scanners[type]
    }
}
