//
//  KeyValueStoreProtocol.swift
//  Utilities
//
//  Created by Rui Huang on 3/21/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import Foundation

public protocol KeyValueStoreProtocol {
    func value(forKey: String) -> Any?
    func setValue(_ value: Any?, forKey: String)
    func reset()
}
