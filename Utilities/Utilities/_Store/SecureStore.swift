//
//  SecureStore.swift
//  Utilities
//
//  Created by Rui Huang on 5/19/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import Foundation

public class SecureStore: SecureStoreProtocol {
    public static let shared = SecureStore()
    
    private let secClass = kSecClassGenericPassword
      
    private init() {}
    
    public func save(_ data: Data, service: String, account: String) {
        let query  = [
            kSecValueData: data,
            kSecClass: secClass,
            kSecAttrService: service,
            kSecAttrAccount: account,
        ] as [CFString : Any] as CFDictionary
        
        // Add data in query to keychain
        let status = SecItemAdd(query, nil)
        
        if status == errSecDuplicateItem {
            // Item already exist, thus update it.
            let query = [
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecClass: secClass,
            ] as [CFString : Any] as CFDictionary
            
            let attributesToUpdate = [kSecValueData: data] as CFDictionary
            
            // Update existing item
            let status = SecItemUpdate(query, attributesToUpdate)
            if status != errSecSuccess {
                Console.shared.log("SecureStore save() error: \(status)")
            }
            
        } else if status != errSecSuccess {
            Console.shared.log("SecureStore save() error: \(status)")
        }
    }
    
    public func read(service: String, account: String) -> Data? {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: secClass,
            kSecReturnData: true
        ] as [CFString : Any] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        return (result as? Data)
    }
    
    public func delete(service: String, account: String) {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: secClass,
        ] as [CFString : Any] as CFDictionary
        
        // Delete item from keychain
        let status = SecItemDelete(query)
        
        if status != errSecSuccess {
            Console.shared.log("SecureStore delete() error: \(status)")
        }
    }
    
    public func save<T>(_ item: T, service: String, account: String) where T : Codable {
        do {
            let data = try JSONEncoder().encode(item)
            save(data, service: service, account: account)
        } catch {
            Console.shared.log("SecureStore save() error: \(error)")
        }
    }
    
    public func read<T>(service: String, account: String, type: T.Type) -> T? where T : Codable {
        guard let data = read(service: service, account: account) else {
            return nil
        }
        
        do {
            let item = try JSONDecoder().decode(type, from: data)
            return item
        } catch {
            Console.shared.log("SecureStore read() error: \(error)")
            return nil
        }
    }
}
