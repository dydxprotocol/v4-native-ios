//
//  Logging.swift
//  Utilities
//
//  Created by Rui Huang on 13/05/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import Foundation

public protocol Logging {
    func e(tag: String, message: String)
    func d(tag: String, message: String)
}
