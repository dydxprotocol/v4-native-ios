//
//  SecureStoreProtocol.swift
//  Utilities
//
//  Created by Rui Huang on 5/19/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import Foundation

public protocol SecureStoreProtocol {
    func save(_ data: Data, service: String, account: String)
    func read(service: String, account: String) -> Data?
    func delete(service: String, account: String)

    func save<T>(_ item: T, service: String, account: String) where T: Codable
    func read<T>(service: String, account: String, type: T.Type) -> T? where T: Codable
}
